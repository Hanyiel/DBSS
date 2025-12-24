from __future__ import annotations

import time
from dataclasses import dataclass
from typing import Any, Iterable, Literal

from datetime import datetime, timezone, date
from decimal import Decimal
from sqlalchemy import MetaData, Table, delete, insert, select, text, update
from sqlalchemy import inspect as sa_inspect
from sqlalchemy.exc import SQLAlchemyError
from sqlalchemy.exc import IntegrityError
from sqlalchemy.exc import NoSuchTableError

from app.core.settings import get_settings
from app.db.clients import DbClient, get_db_clients

DbName = Literal["mysql", "postgres", "oracle"]


@dataclass(frozen=True)
class ChangeEvent:
    id: int
    table_name: str
    pk_value: str
    op: str  # I/U/D
    created_at: datetime | None = None


def _fetch_events_sql(db_name: DbName) -> str:
    if db_name == "mysql":
        return (
            "SELECT id, table_name, pk_value, op, created_at "
            "FROM change_log WHERE processed = 0 ORDER BY id ASC LIMIT :limit"
        )
    if db_name == "postgres":
        return (
            "SELECT id, table_name, pk_value, op, created_at "
            "FROM change_log WHERE processed = FALSE ORDER BY id ASC LIMIT :limit"
        )
    if db_name == "oracle":
        # Oracle doesn't reliably support bind variables in FETCH FIRST across drivers,
        # so use a subquery + ROWNUM for safe limiting.
        return (
            "SELECT id, table_name, pk_value, op, created_at FROM ("
            "  SELECT id, table_name, pk_value, op, created_at FROM change_log "
            "  WHERE processed = 0 ORDER BY id ASC"
            ") WHERE ROWNUM <= :limit"
        )
    raise ValueError(f"Unsupported db: {db_name}")


def _mark_processed_sql(db_name: DbName) -> str:
    if db_name == "postgres":
        return "UPDATE change_log SET processed = TRUE WHERE id = :id"
    return "UPDATE change_log SET processed = 1 WHERE id = :id"


def _reflect_table(client: DbClient, table_name: str, schema: str | None = None) -> Table:
    meta = MetaData()
    return Table(table_name, meta, autoload_with=client.engine, schema=schema)

def _resolve_physical_table_name(client: DbClient, db_name: DbName, table_name: str) -> tuple[str, str | None]:
    """
    Resolve a logical table name (e.g. 'users') to the physical name returned by the database.
    This avoids Oracle case-sensitivity pitfalls when tables were created with quoted identifiers.
    """
    schema = _schema_for(db_name)
    inspector = sa_inspect(client.engine)
    names = inspector.get_table_names(schema=schema)
    mapping = {n.lower(): n for n in names}
    physical = mapping.get(table_name.lower())
    if not physical:
        raise NoSuchTableError(table_name)
    return physical, schema


def _schema_for(db_name: DbName) -> str | None:
    settings = get_settings()
    if db_name == "postgres":
        return "public"
    if db_name == "oracle":
        if getattr(settings, "oracle_schema", None) and str(settings.oracle_schema).strip():
            return str(settings.oracle_schema).strip().upper()
        return settings.oracle_user.upper()
    return None


def _select_row_by_id(source: DbClient, source_db: DbName, table_name: str, row_id: str) -> dict[str, Any] | None:
    physical, schema = _resolve_physical_table_name(source, source_db, table_name)
    src_table = _reflect_table(source, physical, schema=schema)
    id_col = _find_column_ci(src_table, "id")
    if id_col is None:
        raise ValueError("Only tables with 'id' column are supported")
    rid = _coerce_id(id_col, row_id)
    with source.engine.connect() as conn:
        row = conn.execute(select(src_table).where(id_col == rid)).mappings().first()
    return None if row is None else dict(row)


def _upsert_by_id(target: DbClient, target_db: DbName, table_name: str, row: dict[str, Any]) -> None:
    physical, schema = _resolve_physical_table_name(target, target_db, table_name)
    dst_table = _reflect_table(target, physical, schema=schema)
    id_col = _find_column_ci(dst_table, "id")
    if id_col is None:
        raise ValueError("Only tables with 'id' column are supported")

    dst_cols_by_lower = {name.lower(): name for name in dst_table.c.keys()}
    payload: dict[str, Any] = {}
    for k, v in row.items():
        dst_name = dst_cols_by_lower.get(str(k).lower())
        if dst_name:
            payload[dst_name] = v

    with target.engine.begin() as conn:
        try:
            conn.execute(insert(dst_table), payload)
        except IntegrityError as exc:
            # Duplicate PK or unique conflict: fallback to update-by-id.
            update_payload = {k: v for k, v in payload.items() if k.lower() != "id"}
            if update_payload:
                id_key = dst_cols_by_lower.get("id")
                rid = _coerce_id(id_col, payload.get(id_key) if id_key else None)
                res = conn.execute(update(dst_table).where(id_col == rid).values(update_payload))
                # If we couldn't update an existing row, treat it as a failed sync.
                if res.rowcount is not None and int(res.rowcount) <= 0:
                    raise exc
            else:
                raise exc


def _delete_by_id(target: DbClient, target_db: DbName, table_name: str, row_id: str) -> None:
    physical, schema = _resolve_physical_table_name(target, target_db, table_name)
    dst_table = _reflect_table(target, physical, schema=schema)
    id_col = _find_column_ci(dst_table, "id")
    if id_col is None:
        raise ValueError("Only tables with 'id' column are supported")
    rid = _coerce_id(id_col, row_id)
    with target.engine.begin() as conn:
        conn.execute(delete(dst_table).where(id_col == rid))


def _coerce_id(col, value: Any) -> Any:
    if value is None:
        return None
    try:
        py = col.type.python_type
    except Exception:  # noqa: BLE001
        return value

    if py is int:
        try:
            return int(value)
        except Exception:  # noqa: BLE001
            return value
    if py is Decimal:
        try:
            return Decimal(str(value))
        except Exception:  # noqa: BLE001
            return value
    if py is str:
        return str(value)
    if py is float:
        try:
            return float(value)
        except Exception:  # noqa: BLE001
            return value
    return value


def _find_column_ci(table: Table, name: str):
    for col_name in table.c.keys():
        if col_name.lower() == name.lower():
            return table.c[col_name]
    return None


def _detect_updated_at_conflict(
    target: DbClient,
    target_db: DbName,
    *,
    table_name: str,
    pk_value: str,
    source_row: dict[str, Any],
) -> str | None:
    """
    Conflict rule (LWW-safe default):
    - If both source and target have `updated_at`
    - and target.updated_at > source.updated_at
    then treat it as a conflict and do NOT overwrite target by default.
    """
    src_updated_at = None
    for k, v in source_row.items():
        if str(k).lower() == "updated_at":
            src_updated_at = v
            break
    if not isinstance(src_updated_at, datetime):
        return None

    physical, schema = _resolve_physical_table_name(target, target_db, table_name)
    dst_table = _reflect_table(target, physical, schema=schema)
    id_col = _find_column_ci(dst_table, "id")
    updated_at_col = _find_column_ci(dst_table, "updated_at")
    if id_col is None or updated_at_col is None:
        return None

    rid = _coerce_id(id_col, pk_value)
    with target.engine.connect() as conn:
        row = conn.execute(select(id_col, updated_at_col).where(id_col == rid)).first()
    if not row:
        return None

    dst_updated_at = row[1]
    if not isinstance(dst_updated_at, datetime):
        return None

    # Normalize tz-aware comparison.
    s = src_updated_at
    t = dst_updated_at
    if s.tzinfo is None and t.tzinfo is not None:
        s = s.replace(tzinfo=t.tzinfo)
    if t.tzinfo is None and s.tzinfo is not None:
        t = t.replace(tzinfo=s.tzinfo)

    try:
        if t > s:
            return f"updated_at conflict: target({target_db})={t.isoformat()} newer than source({s.isoformat()})"
    except Exception:  # noqa: BLE001
        return None
    return None


def _sync_applied_upsert(source: DbClient, source_db: DbName, change_id: int, target_db: str, status: str, error: str | None):
    physical, schema = _resolve_physical_table_name(source, source_db, "sync_applied")
    sync_applied = _reflect_table(source, physical, schema=schema)
    payload = {"change_id": change_id, "target_db": target_db, "status": status, "error_text": error}

    with source.engine.begin() as conn:
        try:
            conn.execute(insert(sync_applied), payload)
        except IntegrityError:
            conn.execute(
                update(sync_applied)
                .where(sync_applied.c.change_id == change_id)
                .where(sync_applied.c.target_db == target_db)
                .values(status=status, error_text=error)
            )


def fetch_events(source_db: DbName, limit: int = 50) -> list[ChangeEvent]:
    clients = get_db_clients()
    source = clients[source_db]
    sql = _fetch_events_sql(source_db)
    with source.engine.connect() as conn:
        rows = conn.execute(text(sql), {"limit": limit}).mappings().all()
    out: list[ChangeEvent] = []
    for r in rows:
        created_at = r.get("created_at")
        if created_at is not None and isinstance(created_at, datetime) and created_at.tzinfo is None:
            created_at = created_at.replace(tzinfo=timezone.utc)
        out.append(
            ChangeEvent(
                id=int(r["id"]),
                table_name=str(r["table_name"]),
                pk_value=str(r["pk_value"]),
                op=str(r["op"]),
                created_at=created_at if isinstance(created_at, datetime) else None,
            )
        )
    return out


def _fetch_latest_event_sql(db_name: DbName) -> str:
    if db_name == "mysql":
        return (
            "SELECT id, table_name, pk_value, op, created_at "
            "FROM change_log "
            "WHERE processed = 0 AND table_name = :table_name AND pk_value = :pk_value AND op = :op "
            "ORDER BY id DESC LIMIT 1"
        )
    if db_name == "postgres":
        return (
            "SELECT id, table_name, pk_value, op, created_at "
            "FROM change_log "
            "WHERE processed = FALSE AND table_name = :table_name AND pk_value = :pk_value AND op = :op "
            "ORDER BY id DESC LIMIT 1"
        )
    if db_name == "oracle":
        return (
            "SELECT id, table_name, pk_value, op, created_at FROM ("
            "  SELECT id, table_name, pk_value, op, created_at FROM change_log "
            "  WHERE processed = 0 AND table_name = :table_name AND pk_value = :pk_value AND op = :op "
            "  ORDER BY id DESC"
            ") WHERE ROWNUM = 1"
        )
    raise ValueError(f"Unsupported db: {db_name}")


def fetch_latest_event(source_db: DbName, *, table_name: str, pk_value: str, op: str) -> ChangeEvent | None:
    clients = get_db_clients()
    source = clients[source_db]
    sql = _fetch_latest_event_sql(source_db)
    with source.engine.connect() as conn:
        row = conn.execute(text(sql), {"table_name": table_name, "pk_value": pk_value, "op": op}).mappings().first()
    if row is None:
        return None
    created_at = row.get("created_at")
    if created_at is not None and isinstance(created_at, datetime) and created_at.tzinfo is None:
        created_at = created_at.replace(tzinfo=timezone.utc)
    return ChangeEvent(
        id=int(row["id"]),
        table_name=str(row["table_name"]),
        pk_value=str(row["pk_value"]),
        op=str(row["op"]),
        created_at=created_at if isinstance(created_at, datetime) else None,
    )


def _is_conflict_exception(exc: Exception) -> bool:
    if isinstance(exc, IntegrityError):
        return True
    if isinstance(exc, NoSuchTableError):
        return True
    msg = str(exc).lower()
    keywords = [
        "duplicate",
        "unique constraint",
        "violates unique",
        "ora-00001",
        "foreign key",
        "ora-02291",
        "ora-02292",
        "cannot find table",
    ]
    return any(k in msg for k in keywords)


def _record_conflict(
    source: DbClient,
    source_db: DbName,
    *,
    table_name: str,
    pk_value: str,
    target_db: str,
    reason: str,
) -> None:
    try:
        physical, schema = _resolve_physical_table_name(source, source_db, "conflicts")
        conflicts = _reflect_table(source, physical, schema=schema)
    except Exception:  # noqa: BLE001
        return

    reason_text = (reason or "")[:900]
    with source.engine.begin() as conn:
        # De-dup: if same open conflict already exists, don't create another.
        existing = (
            conn.execute(
                select(conflicts.c.id)
                .where(conflicts.c.status == "open")
                .where(conflicts.c.table_name == table_name)
                .where(conflicts.c.pk_value == pk_value)
                .where(conflicts.c.source_db == source_db)
                .where(conflicts.c.resolution_db == target_db)
                .limit(1)
            )
            .first()
        )
        if existing:
            return
        conn.execute(
            insert(conflicts),
            {
                "table_name": table_name,
                "pk_value": pk_value,
                "status": "open",
                "reason": reason_text,
                "source_db": source_db,
                "resolution_db": target_db,
            },
        )


def _update_daily_stats(
    source: DbClient,
    source_db: DbName,
    *,
    inc_events: int = 0,
    inc_ok: int = 0,
    inc_fail: int = 0,
    inc_conflicts: int = 0,
    lag_ms: int | None = None,
) -> None:
    try:
        physical, schema = _resolve_physical_table_name(source, source_db, "sync_stats_daily")
        stats = _reflect_table(source, physical, schema=schema)
    except Exception:  # noqa: BLE001
        return

    today = date.today()
    with source.engine.begin() as conn:
        try:
            conn.execute(insert(stats), {"stat_date": today})
        except IntegrityError:
            pass

        row = conn.execute(select(stats.c.total_events, stats.c.avg_lag_ms).where(stats.c.stat_date == today)).first()
        total_before = int(row[0] or 0) if row else 0
        avg_before = int(row[1] or 0) if row else 0

        total_after = total_before + int(inc_events)
        avg_after = avg_before
        if lag_ms is not None and inc_events:
            try:
                avg_after = int(round((avg_before * total_before + int(lag_ms)) / max(1, total_after)))
            except Exception:  # noqa: BLE001
                avg_after = avg_before

        values: dict[str, Any] = {}
        if inc_events:
            values["total_events"] = stats.c.total_events + int(inc_events)
        if inc_ok:
            values["applied_ok"] = stats.c.applied_ok + int(inc_ok)
        if inc_fail:
            values["applied_fail"] = stats.c.applied_fail + int(inc_fail)
        if inc_conflicts:
            values["conflicts"] = stats.c.conflicts + int(inc_conflicts)
        if lag_ms is not None and inc_events:
            values["avg_lag_ms"] = avg_after
        if not values:
            return

        conn.execute(update(stats).where(stats.c.stat_date == today).values(**values))


def apply_direct_change(source_db: DbName, *, table_name: str, pk_value: str, op: str) -> dict[str, Any]:
    """
    Apply a change to the other two DBs without relying on change_log/sync_applied.
    This is used for app-driven CRUD to ensure "write -> sync" even when triggers are not installed.
    """
    clients = get_db_clients()
    source = clients[source_db]
    targets: list[tuple[str, DbClient]] = [(n, c) for n, c in clients.items() if n != source_db]

    ok_targets: list[str] = []
    failed: list[dict[str, Any]] = []

    if op in ("I", "U"):
        try:
            row = _select_row_by_id(source, source_db, table_name, pk_value)
        except Exception as exc:  # noqa: BLE001
            return {"skipped": True, "reason": "cannot read source row for sync", "error": str(exc)}
        if row is None:
            return {"skipped": True, "reason": "row not found in source"}

        for tname, tclient in targets:
            try:
                _upsert_by_id(tclient, tname, table_name, row)
                ok_targets.append(tname)
            except Exception as exc:  # noqa: BLE001
                failed.append({"target": tname, "error": str(exc)})

    elif op == "D":
        for tname, tclient in targets:
            try:
                _delete_by_id(tclient, tname, table_name, pk_value)
                ok_targets.append(tname)
            except Exception as exc:  # noqa: BLE001
                failed.append({"target": tname, "error": str(exc)})
    else:
        return {"skipped": True, "reason": f"unknown op: {op}"}

    return {"table": table_name, "pk": pk_value, "op": op, "ok_targets": ok_targets, "failed": failed}


def apply_change_to_target(
    source_db: DbName,
    *,
    target_db: str,
    table_name: str,
    pk_value: str,
    op: str,
    force: bool = False,
) -> dict[str, Any]:
    """
    Apply one change from source_db to a single target_db.
    Used by conflict resolution UI ("retry keeping source").
    """
    clients = get_db_clients()
    if target_db not in clients:
        return {"ok": False, "error": f"unknown target_db: {target_db}"}
    if target_db == source_db:
        return {"ok": False, "error": "target_db must differ from source_db"}

    source = clients[source_db]
    target = clients[target_db]

    try:
        if op in ("I", "U"):
            row = _select_row_by_id(source, source_db, table_name, pk_value)
            if row is None:
                return {"ok": False, "skipped": True, "reason": "row not found in source"}
            if not force:
                reason = _detect_updated_at_conflict(target, target_db, table_name=table_name, pk_value=pk_value, source_row=row)
                if reason:
                    return {"ok": False, "conflict": True, "reason": reason}
            _upsert_by_id(target, target_db, table_name, row)
            return {"ok": True}
        if op == "D":
            _delete_by_id(target, target_db, table_name, pk_value)
            return {"ok": True}
        return {"ok": False, "error": f"unknown op: {op}"}
    except Exception as exc:  # noqa: BLE001
        return {"ok": False, "error": str(exc)}


def safe_try_apply_from_change_log(source_db: DbName, *, table_name: str, pk_value: str, op: str) -> dict[str, Any]:
    """
    Prefer applying by change_log event (so we can mark processed and write sync_applied),
    fallback to direct apply if change_log/sync_applied tables/triggers are missing.
    """
    try:
        ev = fetch_latest_event(source_db, table_name=table_name, pk_value=pk_value, op=op)
        if ev is None:
            return {"mode": "change_log", "skipped": True, "reason": "no matching event found; fallback to direct"}
        res = apply_event(source_db, ev)
        res["mode"] = "change_log"
        return res
    except SQLAlchemyError as exc:
        return {"mode": "change_log", "skipped": True, "reason": "sync tables/triggers missing or DB error", "error": str(exc)}


def apply_event(source_db: DbName, event: ChangeEvent) -> dict[str, Any]:
    clients = get_db_clients()
    source = clients[source_db]
    targets: list[tuple[str, DbClient]] = [(n, c) for n, c in clients.items() if n != source_db]

    ok_targets: list[str] = []
    failed: list[dict[str, Any]] = []
    conflict_failures = 0

    if event.op in ("I", "U"):
        row = _select_row_by_id(source, source_db, event.table_name, event.pk_value)
        if row is None:
            return {"event_id": event.id, "skipped": True, "reason": "row not found in source"}

        for tname, tclient in targets:
            try:
                reason = _detect_updated_at_conflict(tclient, tname, table_name=event.table_name, pk_value=event.pk_value, source_row=row)
                if reason:
                    conflict_failures += 1
                    _sync_applied_upsert(source, source_db, event.id, tname, "fail", reason)
                    _record_conflict(
                        source,
                        source_db,
                        table_name=event.table_name,
                        pk_value=event.pk_value,
                        target_db=tname,
                        reason=reason,
                    )
                    failed.append({"target": tname, "error": reason, "conflict": True})
                    continue
                _upsert_by_id(tclient, tname, event.table_name, row)
                _sync_applied_upsert(source, source_db, event.id, tname, "ok", None)
                ok_targets.append(tname)
            except Exception as exc:  # noqa: BLE001
                _sync_applied_upsert(source, source_db, event.id, tname, "fail", str(exc))
                if _is_conflict_exception(exc):
                    conflict_failures += 1
                    _record_conflict(
                        source,
                        source_db,
                        table_name=event.table_name,
                        pk_value=event.pk_value,
                        target_db=tname,
                        reason=str(exc),
                    )
                failed.append({"target": tname, "error": str(exc)})

    elif event.op == "D":
        for tname, tclient in targets:
            try:
                _delete_by_id(tclient, tname, event.table_name, event.pk_value)
                _sync_applied_upsert(source, source_db, event.id, tname, "ok", None)
                ok_targets.append(tname)
            except Exception as exc:  # noqa: BLE001
                _sync_applied_upsert(source, source_db, event.id, tname, "fail", str(exc))
                if _is_conflict_exception(exc):
                    conflict_failures += 1
                    _record_conflict(
                        source,
                        source_db,
                        table_name=event.table_name,
                        pk_value=event.pk_value,
                        target_db=tname,
                        reason=str(exc),
                    )
                failed.append({"target": tname, "error": str(exc)})
    else:
        return {"event_id": event.id, "skipped": True, "reason": f"unknown op: {event.op}"}

    should_mark_processed = (not failed) or (failed and conflict_failures == len(failed))
    if should_mark_processed:
        with source.engine.begin() as conn:
            conn.execute(text(_mark_processed_sql(source_db)), {"id": event.id})

        lag_ms: int | None = None
        if event.created_at is not None:
            try:
                now = datetime.now(tz=event.created_at.tzinfo or timezone.utc)
                lag_ms = int(max(0, (now - event.created_at).total_seconds() * 1000))
            except Exception:  # noqa: BLE001
                lag_ms = None
        _update_daily_stats(
            source,
            source_db,
            inc_events=1,
            inc_ok=len(ok_targets),
            inc_fail=len(failed),
            inc_conflicts=conflict_failures,
            lag_ms=lag_ms,
        )

    return {
        "event_id": event.id,
        "table": event.table_name,
        "pk": event.pk_value,
        "op": event.op,
        "ok_targets": ok_targets,
        "failed": failed,
        "processed": should_mark_processed,
        "conflicts_recorded": conflict_failures,
    }


def run_once(source_db: DbName, limit: int = 50) -> dict[str, Any]:
    started = time.perf_counter()
    try:
        events = fetch_events(source_db, limit=limit)
    except SQLAlchemyError as exc:
        return {
            "source_db": source_db,
            "pulled": 0,
            "results": [],
            "seconds": time.perf_counter() - started,
            "error": str(exc),
        }

    results = [apply_event(source_db, e) for e in events]
    return {
        "source_db": source_db,
        "pulled": len(events),
        "results": results,
        "seconds": time.perf_counter() - started,
    }


def iter_forever(source_db: DbName, poll_seconds: int = 2, limit: int = 50) -> Iterable[dict[str, Any]]:
    while True:
        yield run_once(source_db, limit=limit)
        time.sleep(max(1, poll_seconds))
