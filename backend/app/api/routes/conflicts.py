from __future__ import annotations

from datetime import datetime, timezone
from typing import Any, Literal

from fastapi import APIRouter, Depends, HTTPException, Query
from pydantic import BaseModel, Field
from sqlalchemy import MetaData, Table, select, update
from sqlalchemy import inspect as sa_inspect

from app.api.deps import require_admin
from app.core.settings import get_settings
from app.db.clients import DbClient, get_db_clients
from app.services.sync import DbName, apply_change_to_target

router = APIRouter()


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


class ConflictResolveRequest(BaseModel):
    action: Literal["mark_resolved", "retry_keep_source"] = Field(..., description="resolve action")
    op: Literal["I", "U", "D"] = Field("U", description="used for retry_keep_source")
    mark_resolved_on_success: bool = True
    force: bool = Field(True, description="force overwrite when retrying (bypass updated_at conflict)")


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

    with client.engine.begin() as conn:
        row = conn.execute(select(conflicts).where(conflicts.c.id == conflict_id)).mappings().first()
        if not row:
            raise HTTPException(status_code=404, detail="conflict not found")

        if req.action == "mark_resolved":
            conn.execute(
                update(conflicts)
                .where(conflicts.c.id == conflict_id)
                .values(
                    status="resolved",
                    resolved_by=str(payload.get("sub") or "admin"),
                    resolved_at=datetime.now(tz=timezone.utc),
                )
            )
            return {"ok": True, "action": "mark_resolved"}

        # retry_keep_source
        resolution_db = row.get("resolution_db")
        if not resolution_db:
            raise HTTPException(status_code=400, detail="conflict has no resolution_db (target)")

    # apply outside the transaction
    apply_res = apply_change_to_target(
        source_db,
        target_db=str(resolution_db),
        table_name=str(row["table_name"]),
        pk_value=str(row["pk_value"]),
        op=req.op,
        force=req.force,
    )

    if apply_res.get("ok") and req.mark_resolved_on_success:
        with client.engine.begin() as conn:
            conn.execute(
                update(conflicts)
                .where(conflicts.c.id == conflict_id)
                .values(
                    status="resolved",
                    resolved_by=str(payload.get("sub") or "admin"),
                    resolved_at=datetime.now(tz=timezone.utc),
                )
            )

    return {"ok": True, "action": "retry_keep_source", "apply": apply_res}
