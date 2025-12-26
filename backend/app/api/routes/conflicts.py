from __future__ import annotations

import random
import time
import uuid
from datetime import datetime, timezone
from typing import Any, Literal

from fastapi import APIRouter, Depends, HTTPException, Query
from pydantic import BaseModel, Field
from sqlalchemy import MetaData, Table, insert, select, update
from sqlalchemy import inspect as sa_inspect
from sqlalchemy.exc import IntegrityError

from app.api.deps import require_admin
from app.core.settings import get_settings
from app.db.clients import DbClient, get_db_clients
from app.services.sync import DbName, apply_change_to_target, apply_direct_change, safe_try_apply_from_change_log

router = APIRouter()


def _mark_related_conflicts_resolved(
    *,
    table_name: str,
    pk_value: str,
    resolved_by: str,
    resolved_at: datetime,
    winner_db: str | None = None,
    resolution_method: str | None = None,
    note: str | None = None,
) -> dict[str, int]:
    """
    Best-effort: when a conflict is resolved, mark all open conflicts with the same (table_name, pk_value)
    across all DBs' `conflicts` tables as resolved.

    Rationale: each DB stores its own conflict rows; UI resolves one row, but we want the *same logical conflict*
    to be closed everywhere to avoid repeated manual work.
    """
    if not table_name or not pk_value:
        return {}

    clients = get_db_clients()
    counts: dict[str, int] = {}
    for dbn, client in clients.items():
        try:
            conflicts = _reflect(client, dbn, "conflicts")
        except Exception:  # noqa: BLE001
            continue

        values: dict[str, Any] = {
            "status": "resolved",
            "resolved_by": resolved_by,
            "resolved_at": resolved_at,
        }
        if winner_db and "resolution_db" in conflicts.c:
            values["resolution_db"] = winner_db
        if resolution_method and "resolution_method" in conflicts.c:
            values["resolution_method"] = resolution_method
        if note and "resolution_note" in conflicts.c:
            values["resolution_note"] = note

        stmt = (
            update(conflicts)
            .where(conflicts.c.status == "open")
            .where(conflicts.c.table_name == table_name)
            .where(conflicts.c.pk_value == pk_value)
            .values(**values)
        )
        try:
            with client.engine.begin() as conn:
                res = conn.execute(stmt)
            counts[str(dbn)] = int(getattr(res, "rowcount", 0) or 0)
        except Exception:  # noqa: BLE001
            continue

    return counts


def _schema_for(db_name: DbName) -> str | None:
    settings = get_settings()
    if db_name == "postgres":
        return "public"
    if db_name == "oracle":
        return (settings.oracle_schema or settings.oracle_user).upper()
    return None


def _resolve_physical_table_name(client: DbClient, db_name: DbName, table_name: str) -> tuple[str, str | None]:
    schema = _schema_for(db_name)
    inspector = sa_inspect(client.engine)
    names = inspector.get_table_names(schema=schema)
    mapping = {n.lower(): n for n in names}
    physical = mapping.get(table_name.lower())
    if not physical:
        raise HTTPException(status_code=404, detail=f"table not found: {table_name}")
    return physical, schema


def _reflect(client: DbClient, db_name: DbName, table_name: str) -> Table:
    physical, schema = _resolve_physical_table_name(client, db_name, table_name)
    meta = MetaData()
    return Table(physical, meta, autoload_with=client.engine, schema=schema)

def _find_column_ci(table: Table, name: str):
    for col_name in table.c.keys():
        if col_name.lower() == name.lower():
            return table.c[col_name]
    return None


def _coerce_id_value(col, value: str):
    try:
        py = col.type.python_type
        if py is int:
            return int(value)
    except Exception:  # noqa: BLE001
        return value
    return value


def _fetch_row_by_pk(client: DbClient, db_name: DbName, *, table_name: str, pk_value: str) -> dict[str, Any] | None:
    table = _reflect(client, db_name, table_name)
    id_col = _find_column_ci(table, "id")
    if id_col is None:
        return None
    rid = _coerce_id_value(id_col, pk_value)
    with client.engine.connect() as conn:
        row = conn.execute(select(table).where(id_col == rid)).mappings().first()
    return dict(row) if row else None


def _fetch_row_by_unique_best_effort(
    client: DbClient,
    db_name: DbName,
    *,
    table_name: str,
    source_row: dict[str, Any] | None,
) -> dict[str, Any] | None:
    if not source_row:
        return None
    table = _reflect(client, db_name, table_name)
    username_col = _find_column_ci(table, "username")
    email_col = _find_column_ci(table, "email")

    username_val = next((v for k, v in source_row.items() if str(k).lower() == "username"), None)
    email_val = next((v for k, v in source_row.items() if str(k).lower() == "email"), None)

    with client.engine.connect() as conn:
        if username_col is not None and username_val is not None:
            row = conn.execute(select(table).where(username_col == username_val).limit(1)).mappings().first()
            if row:
                return dict(row)
        if email_col is not None and email_val is not None:
            row = conn.execute(select(table).where(email_col == email_val).limit(1)).mappings().first()
            if row:
                return dict(row)
    return None


class ConflictResolveRequest(BaseModel):
    action: Literal["mark_resolved", "retry_keep_source", "sync_from_db", "auto_latest"] = Field(..., description="resolve action")
    op: Literal["I", "U", "D"] = Field("U", description="used for retry_keep_source")
    mark_resolved_on_success: bool = True
    force: bool = Field(True, description="force overwrite when retrying (bypass updated_at conflict)")
    winner_db: DbName | None = Field(None, description="winner DB for sync_from_db")
    note: str | None = Field(None, description="optional resolution note")


@router.get("")
def list_conflicts(
    status: Literal["open", "resolved", "all"] = Query("open"),
    source_db: DbName | None = Query(None, description="where conflicts table is stored"),
    limit: int = Query(50, ge=1, le=200),
    _admin: dict = Depends(require_admin),
):
    clients = get_db_clients()
    dbs = [source_db] if source_db else ["mysql", "postgres", "oracle"]

    merged: list[dict[str, Any]] = []
    errors: list[dict[str, Any]] = []
    for db in dbs:
        client = clients[db]
        try:
            conflicts = _reflect(client, db, "conflicts")
        except Exception as exc:  # noqa: BLE001
            errors.append({"store_db": db, "error": str(exc)})
            continue

        stmt = select(conflicts).order_by(conflicts.c.detected_at.desc())
        if status != "all":
            stmt = stmt.where(conflicts.c.status == status)
        stmt = stmt.limit(limit)

        with client.engine.connect() as conn:
            rows = conn.execute(stmt).mappings().all()
        for r in rows:
            item = dict(r)
            item["store_db"] = db
            merged.append(item)

    def sort_key(x: dict[str, Any]):
        dt = x.get("detected_at")
        if isinstance(dt, datetime):
            if dt.tzinfo is None:
                return dt.replace(tzinfo=timezone.utc)
            return dt
        return datetime(1970, 1, 1, tzinfo=timezone.utc)

    merged.sort(key=sort_key, reverse=True)
    return {"conflicts": merged[:limit], "errors": errors}


@router.get("/{store_db}/{conflict_id}")
def get_conflict_detail(store_db: DbName, conflict_id: int, _admin: dict = Depends(require_admin)):
    clients = get_db_clients()
    store = clients[store_db]
    conflicts = _reflect(store, store_db, "conflicts")

    with store.engine.connect() as conn:
        conflict = conn.execute(select(conflicts).where(conflicts.c.id == conflict_id)).mappings().first()
    if not conflict:
        raise HTTPException(status_code=404, detail="conflict not found")

    conflict_dict = dict(conflict)
    source_db = str(conflict_dict.get("source_db") or store_db)
    target_db = str(conflict_dict.get("resolution_db") or "")
    table_name = str(conflict_dict.get("table_name") or "")
    pk_value = str(conflict_dict.get("pk_value") or "")

    out: dict[str, Any] = {"conflict": conflict_dict, "store_db": store_db}
    if table_name and pk_value and pk_value != "*":
        rows_by_db: dict[str, Any] = {}
        for dbn in ("mysql", "postgres", "oracle"):
            if dbn not in clients:
                continue
            try:
                rows_by_db[dbn] = _fetch_row_by_pk(clients[dbn], dbn, table_name=table_name, pk_value=pk_value)
            except Exception as exc:  # noqa: BLE001
                rows_by_db[dbn] = {"_error": str(exc)}
        out["rows_by_db"] = rows_by_db

    if source_db in clients and table_name and pk_value:
        try:
            out["source_row"] = _fetch_row_by_pk(clients[source_db], source_db, table_name=table_name, pk_value=pk_value)
        except Exception as exc:  # noqa: BLE001
            out["source_row_error"] = str(exc)

    if target_db in clients and table_name and pk_value:
        try:
            out["target_row"] = _fetch_row_by_pk(clients[target_db], target_db, table_name=table_name, pk_value=pk_value)
        except Exception as exc:  # noqa: BLE001
            out["target_row_error"] = str(exc)

        try:
            out["target_conflict_row"] = _fetch_row_by_unique_best_effort(
                clients[target_db],
                target_db,
                table_name=table_name,
                source_row=out.get("source_row"),
            )
        except Exception as exc:  # noqa: BLE001
            out["target_conflict_row_error"] = str(exc)

    return out


@router.post("/{source_db}/{conflict_id}/resolve")
def resolve_conflict(
    source_db: DbName,
    conflict_id: int,
    req: ConflictResolveRequest,
    payload: dict = Depends(require_admin),
):
    clients = get_db_clients()
    client = clients[source_db]
    conflicts = _reflect(client, source_db, "conflicts")

    resolved_by = str(payload.get("sub") or "admin")
    resolved_at = datetime.now(tz=timezone.utc)

    conflict_table_name = ""
    conflict_pk_value = ""

    if req.action == "mark_resolved":
        with client.engine.begin() as conn:
            row = conn.execute(select(conflicts).where(conflicts.c.id == conflict_id)).mappings().first()
            if not row:
                raise HTTPException(status_code=404, detail="conflict not found")
            conflict_table_name = str(row.get("table_name") or "")
            conflict_pk_value = str(row.get("pk_value") or "")

            values: dict[str, Any] = {"status": "resolved", "resolved_by": resolved_by, "resolved_at": resolved_at}
            if "resolution_method" in conflicts.c:
                values["resolution_method"] = "manual"
            if "resolution_note" in conflicts.c and req.note:
                values["resolution_note"] = req.note
            conn.execute(update(conflicts).where(conflicts.c.id == conflict_id).values(**values))

        related = _mark_related_conflicts_resolved(
            table_name=conflict_table_name,
            pk_value=conflict_pk_value,
            resolved_by=resolved_by,
            resolved_at=resolved_at,
            resolution_method="manual",
            note=req.note,
        )
        return {"ok": True, "action": "mark_resolved", "related_marked": related}

    if req.action in ("sync_from_db", "auto_latest"):
        winner: str | None = None
        direct: dict[str, Any] | None = None
        ok = False
        resolution_method = "latest" if req.action == "auto_latest" else "manual"

        with client.engine.begin() as conn:
            row = conn.execute(select(conflicts).where(conflicts.c.id == conflict_id)).mappings().first()
            if not row:
                raise HTTPException(status_code=404, detail="conflict not found")

            conflict_table_name = str(row.get("table_name") or "")
            conflict_pk_value = str(row.get("pk_value") or "")
            conflict_source_db = str(row.get("source_db") or source_db)

            winner = req.winner_db
            if req.action == "auto_latest":
                candidates: list[tuple[str, datetime]] = []
                for dbn in ("mysql", "postgres", "oracle"):
                    try:
                        r2 = _fetch_row_by_pk(get_db_clients()[dbn], dbn, table_name=conflict_table_name, pk_value=conflict_pk_value)
                    except Exception:  # noqa: BLE001
                        continue
                    if not r2:
                        continue
                    dt = None
                    for k, v in r2.items():
                        if str(k).lower() == "updated_at" and isinstance(v, datetime):
                            dt = v
                            break
                    if dt is not None and dt.tzinfo is None:
                        dt = dt.replace(tzinfo=timezone.utc)
                    if dt is not None:
                        candidates.append((dbn, dt))
                if candidates:
                    candidates.sort(key=lambda x: x[1], reverse=True)
                    winner = candidates[0][0]
                else:
                    winner = conflict_source_db

            if not winner:
                raise HTTPException(status_code=400, detail="winner_db required")

            direct = apply_direct_change(winner, table_name=conflict_table_name, pk_value=conflict_pk_value, op=req.op)
            ok = (not direct.get("skipped")) and (direct.get("failed") == [])

            values: dict[str, Any] = {
                "status": "resolved" if ok else "open",
                "resolution_db": winner,
                "resolved_by": resolved_by,
                "resolved_at": resolved_at,
            }
            if "resolution_method" in conflicts.c:
                values["resolution_method"] = resolution_method
            if "resolution_note" in conflicts.c and req.note:
                values["resolution_note"] = req.note
            conn.execute(update(conflicts).where(conflicts.c.id == conflict_id).values(**values))

        related = (
            _mark_related_conflicts_resolved(
                table_name=conflict_table_name,
                pk_value=conflict_pk_value,
                resolved_by=resolved_by,
                resolved_at=resolved_at,
                winner_db=str(winner),
                resolution_method=resolution_method,
                note=req.note,
            )
            if ok
            else {}
        )
        return {"ok": True, "action": req.action, "winner_db": winner, "sync": direct, "related_marked": related}

    if req.action == "retry_keep_source":
        resolution_db = None
        with client.engine.begin() as conn:
            row = conn.execute(select(conflicts).where(conflicts.c.id == conflict_id)).mappings().first()
            if not row:
                raise HTTPException(status_code=404, detail="conflict not found")
            resolution_db = row.get("resolution_db")
            conflict_table_name = str(row.get("table_name") or "")
            conflict_pk_value = str(row.get("pk_value") or "")
            conflict_source_db = str(row.get("source_db") or source_db)
            if not resolution_db:
                raise HTTPException(status_code=400, detail="conflict has no resolution_db (target)")

    # apply outside the transaction
    apply_res = apply_change_to_target(
        source_db,
        target_db=str(resolution_db or ""),
        table_name=conflict_table_name,
        pk_value=conflict_pk_value,
        op=req.op,
        force=req.force,
    )

    if apply_res.get("ok") and req.mark_resolved_on_success:
        with client.engine.begin() as conn:
            values: dict[str, Any] = {
                "status": "resolved",
                "resolved_by": resolved_by,
                "resolved_at": resolved_at,
            }
            if "resolution_method" in conflicts.c:
                values["resolution_method"] = "manual"
            if "resolution_note" in conflicts.c and req.note:
                values["resolution_note"] = req.note
            conn.execute(update(conflicts).where(conflicts.c.id == conflict_id).values(**values))

        related = _mark_related_conflicts_resolved(
            table_name=conflict_table_name,
            pk_value=conflict_pk_value,
            resolved_by=resolved_by,
            resolved_at=resolved_at,
            winner_db=conflict_source_db,
            resolution_method="manual",
            note=req.note,
        )
    else:
        related = {}

    return {"ok": True, "action": "retry_keep_source", "apply": apply_res, "related_marked": related}


class DemoConflictCreateRequest(BaseModel):
    source_db: DbName = Field("mysql")
    target_db: DbName = Field("postgres")
    table_name: Literal["users"] = Field("users")
    kind: Literal["updated_at"] = Field("updated_at", description="demo conflict kind")
    run_sync: bool = Field(True, description="run sync once immediately")
    limit: int = Field(50, ge=1, le=200, description="sync run_once limit when run_sync=true")


@router.post("/demo/create")
def create_demo_conflict(req: DemoConflictCreateRequest, _admin: dict = Depends(require_admin)):
    """
    Create a deterministic demo conflict for presentations:
    Default: updated_at conflict (resolvable with any winner_db):
    - Ensure the same user(id) exists in all 3 DBs
    - Update the user in source DB, then update the same user in target DB (target.updated_at becomes newer)
    - Run sync once from source DB -> target, the worker detects updated_at conflict and records it
    """
    if req.source_db == req.target_db:
        raise HTTPException(status_code=400, detail="source_db and target_db must differ")

    clients = get_db_clients()
    source = clients[req.source_db]
    target = clients[req.target_db]

    # Use a highly-unlikely-to-exist identifier to avoid clashing with any real data.
    uid = uuid.uuid4().hex  # 32 chars
    demo_id = 900_000 + int(uid[:6], 16) % 99_000
    username = f"zz__dbss_demo__{uid[:20]}"[:50]
    email = f"{username}@dbss.invalid"[:100]

    users_by_db: dict[str, Table] = {}
    for dbn in ("mysql", "postgres", "oracle"):
        users_by_db[dbn] = _reflect(clients[dbn], dbn, req.table_name)  # type: ignore[index]

    def upsert_user(dbn: DbName, values: dict[str, Any]) -> None:
        tbl = users_by_db[dbn]
        id_col = _find_column_ci(tbl, "id")
        if id_col is None:
            raise HTTPException(status_code=500, detail="users.id not found")
        with clients[dbn].engine.begin() as conn:  # type: ignore[index]
            try:
                conn.execute(insert(tbl), values)
            except IntegrityError:
                upd = {k: v for k, v in values.items() if str(k).lower() != "id"}
                conn.execute(update(tbl).where(id_col == values["id"]).values(**upd))

    base_values = {
        "id": int(demo_id),
        "username": username,
        "email": email,
        "password": "pwd",
        "display_name": f"Demo {uid[:6]}",
        "status": "offline",
    }

    # Ensure the same PK exists in all DBs, so winner_db can be ANY of the 3.
    for dbn in ("mysql", "postgres", "oracle"):
        upsert_user(dbn, base_values)  # type: ignore[arg-type]

    # Create an updated_at conflict: source updated_at < target updated_at.
    src_tbl = users_by_db[req.source_db]
    tgt_tbl = users_by_db[req.target_db]
    src_id_col = _find_column_ci(src_tbl, "id")
    tgt_id_col = _find_column_ci(tgt_tbl, "id")
    if src_id_col is None or tgt_id_col is None:
        raise HTTPException(status_code=500, detail="users.id not found")

    with source.engine.begin() as conn:
        conn.execute(update(src_tbl).where(src_id_col == demo_id).values(display_name=f"Source {uid[:6]}", status="online"))

    # Ensure updated_at is definitely newer in target across all DBs (MySQL timestamp may be second precision).
    time.sleep(1.2)
    with target.engine.begin() as conn:
        conn.execute(update(tgt_tbl).where(tgt_id_col == demo_id).values(display_name=f"Target {uid[:6]}", status="busy"))

    # Ensure there is a pending change_log event in the source DB (some environments may not have triggers installed).
    change_log = _reflect(source, req.source_db, "change_log")
    with source.engine.begin() as conn:
        existing = (
            conn.execute(
                select(change_log.c.id)
                .where(change_log.c.processed == 0)
                .where(change_log.c.table_name == req.table_name)
                .where(change_log.c.pk_value == str(demo_id))
                .where(change_log.c.op == "U")
                .order_by(change_log.c.id.desc())
                .limit(1)
            )
            .first()
        )
        if not existing:
            conn.execute(
                insert(change_log),
                {
                    "source_db": req.source_db,
                    "table_name": req.table_name,
                    "pk_value": str(demo_id),
                    "op": "U",
                    "processed": 0,
                },
            )

    sync_result: Any
    if req.run_sync:
        # Apply only the updated row, so the demo is not affected by unrelated change_log backlog.
        sync_result = safe_try_apply_from_change_log(req.source_db, table_name=req.table_name, pk_value=str(demo_id), op="U")
    else:
        sync_result = {"skipped": True, "reason": "run_sync=false"}

    return {
        "ok": True,
        "kind": req.kind,
        "user": {"id": int(demo_id), "username": username, "email": email},
        "source": {"db": req.source_db, "table": req.table_name, "id": str(demo_id)},
        "target": {"db": req.target_db, "table": req.table_name, "id": str(demo_id)},
        "sync": sync_result,
    }
