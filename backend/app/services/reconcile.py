from __future__ import annotations

import hashlib
import time
from dataclasses import dataclass
from datetime import datetime, timedelta, timezone
from typing import Any, Iterable, Literal

from sqlalchemy import MetaData, Table, func, insert, select, update
from sqlalchemy import inspect as sa_inspect
from sqlalchemy.exc import SQLAlchemyError

from app.core.settings import get_settings
from app.db.clients import DbClient, get_db_clients
from app.db.schemas import BUSINESS_TABLES
from app.services.notify_email import ConflictEmail, notify_conflict_created

DbName = Literal["mysql", "postgres", "oracle"]


@dataclass(frozen=True)
class ReconcileConflict:
    table: str
    pk: str
    reason: str
    rows_by_db: dict[str, dict[str, Any] | None]


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
        raise ValueError(f"table not found: {table_name}")
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


def _coerce_id(col, value: str):
    try:
        py = col.type.python_type
        if py is int:
            return int(value)
    except Exception:  # noqa: BLE001
        return value
    return value


def _normalize_value(v: Any) -> str:
    if v is None:
        return "null"
    if isinstance(v, (str, int, float, bool)):
        return str(v)
    if isinstance(v, datetime):
        if v.tzinfo is None:
            v = v.replace(tzinfo=timezone.utc)
        return v.isoformat()
    return str(v)


def _row_signature(row: dict[str, Any]) -> str:
    items = sorted(((str(k).lower(), _normalize_value(v)) for k, v in row.items()), key=lambda x: x[0])
    raw = "|".join([f"{k}={v}" for k, v in items])
    return hashlib.sha1(raw.encode("utf-8", errors="ignore")).hexdigest()[:10]


def _diff_columns(rows_by_db: dict[str, dict[str, Any] | None]) -> list[str]:
    present = {k: v for k, v in rows_by_db.items() if v is not None}
    if len(present) <= 1:
        return []
    keys = set()
    for r in present.values():
        keys.update([str(k).lower() for k in r.keys()])

    diffs: list[str] = []
    for key in sorted(keys):
        values = {db: _normalize_value(next((rv for rk, rv in row.items() if str(rk).lower() == key), None)) for db, row in present.items()}
        if len(set(values.values())) > 1:
            diffs.append(key)
    return diffs


def _candidate_ids_for_table(
    client: DbClient,
    db_name: DbName,
    table: Table,
    *,
    since: datetime,
    limit: int,
) -> list[str]:
    id_col = _find_column_ci(table, "id")
    if id_col is None:
        return []
    ts_col = _find_column_ci(table, "updated_at") or _find_column_ci(table, "created_at")
    stmt = select(id_col)
    if ts_col is not None:
        stmt = stmt.where(ts_col >= since).order_by(ts_col.desc())
    else:
        stmt = stmt.order_by(id_col.desc())
    stmt = stmt.limit(limit)
    with client.engine.connect() as conn:
        ids = [str(r[0]) for r in conn.execute(stmt).all()]
    return ids


def _all_ids_for_table(client: DbClient, table: Table, *, limit: int) -> list[str]:
    id_col = _find_column_ci(table, "id")
    if id_col is None:
        return []
    stmt = select(id_col).order_by(id_col.asc()).limit(limit)
    with client.engine.connect() as conn:
        return [str(r[0]) for r in conn.execute(stmt).all()]


def _fetch_row_by_pk(client: DbClient, db_name: DbName, *, table: Table, pk_value: str) -> dict[str, Any] | None:
    id_col = _find_column_ci(table, "id")
    if id_col is None:
        return None
    rid = _coerce_id(id_col, pk_value)
    with client.engine.connect() as conn:
        row = conn.execute(select(table).where(id_col == rid)).mappings().first()
    return dict(row) if row else None


def reconcile_once(*, full_scan: bool | None = None) -> dict[str, Any]:
    """
    Periodic consistency check (demo-friendly):
    - Sample recently updated rows (updated_at/created_at) from each DB
    - Compare rows across DBs and record inconsistencies into conflicts table
    """
    settings = get_settings()
    clients = get_db_clients()

    store_db: DbName = getattr(settings, "reconcile_store_db", "mysql")
    if store_db not in clients:
        store_db = "mysql"

    interval_seconds = int(getattr(settings, "reconcile_interval_seconds", 60))
    window_minutes = int(getattr(settings, "reconcile_window_minutes", 5))
    max_pks = int(getattr(settings, "reconcile_max_pks", 200))
    max_full_scan_pks = int(getattr(settings, "reconcile_full_scan_max_pks", 5000))
    auto_resolve = bool(getattr(settings, "reconcile_auto_resolve", False))
    if full_scan is None:
        full_scan = bool(getattr(settings, "reconcile_full_scan", False))

    now = datetime.now(tz=timezone.utc)
    since = now - timedelta(minutes=max(1, window_minutes))

    store = clients[store_db]
    conflicts_table = _reflect(store, store_db, "conflicts")

    created = 0
    resolved = 0
    scanned = 0
    details: list[dict[str, Any]] = []
    emailed = 0

    # Cache reflected business tables per db per run.
    reflected: dict[tuple[str, str], Table] = {}

    def try_email(table_name: str, pk_value: str, reason: str) -> None:
        nonlocal emailed
        if emailed >= int(getattr(settings, "email_max_per_run", 10)):
            return
        try:
            res = notify_conflict_created(
                ConflictEmail(
                    store_db=str(store_db),
                    conflict_id=None,
                    table_name=table_name,
                    pk_value=pk_value,
                    source_db="reconcile",
                    target_db=None,
                    reason=reason,
                ),
                settings=settings,
            )
            if res.get("ok") and not res.get("skipped"):
                emailed += 1
        except Exception:  # noqa: BLE001
            pass

    def get_table(db: DbName, table_name: str) -> Table:
        key = (db, table_name)
        if key in reflected:
            return reflected[key]
        tbl = _reflect(clients[db], db, table_name)
        reflected[key] = tbl
        return tbl

    for table_name in BUSINESS_TABLES:
        # Fast check: rowcount mismatch => definitely inconsistent.
        try:
            counts: dict[str, int] = {}
            for db_name in ("mysql", "postgres", "oracle"):
                tbl = get_table(db_name, table_name)  # type: ignore[arg-type]
                with clients[db_name].engine.connect() as conn:  # type: ignore[arg-type]
                    counts[db_name] = int(conn.execute(select(func.count()).select_from(tbl)).scalar() or 0)
            if len(set(counts.values())) > 1:
                reason = f"reconcile: rowcount differs mysql={counts['mysql']} postgres={counts['postgres']} oracle={counts['oracle']}"
                pk_value = "*"
                with store.engine.begin() as conn:
                    stmt = (
                        select(conflicts_table.c.id)
                        .where(conflicts_table.c.status == "open")
                        .where(conflicts_table.c.table_name == table_name)
                        .where(conflicts_table.c.pk_value == pk_value)
                        .where(conflicts_table.c.reason == reason)
                        .limit(1)
                    )
                    exists = conn.execute(stmt).first()
                    if not exists:
                        payload: dict[str, Any] = {
                            "table_name": table_name,
                            "pk_value": pk_value,
                            "status": "open",
                            "reason": reason,
                            "source_db": "reconcile",
                        }
                        if "resolution_method" in conflicts_table.c:
                            payload["resolution_method"] = "scan"
                        conn.execute(insert(conflicts_table), payload)
                        created += 1
                        try_email(table_name, pk_value, reason)
                details.append({"table": table_name, "pk": pk_value, "reason": reason, "counts": counts})
        except SQLAlchemyError:
            # If a DB is unavailable or table missing, skip rowcount checks for this table.
            pass

        ids: set[str] = set()
        for db_name in ("mysql", "postgres", "oracle"):
            client = clients[db_name]  # type: ignore[index]
            try:
                tbl = get_table(db_name, table_name)  # type: ignore[arg-type]
                if full_scan:
                    got = _all_ids_for_table(client, tbl, limit=max_full_scan_pks)  # type: ignore[arg-type]
                else:
                    got = _candidate_ids_for_table(client, db_name, tbl, since=since, limit=max_pks)  # type: ignore[arg-type]
                for pk in got:
                    ids.add(pk)
            except Exception:  # noqa: BLE001
                continue

        for pk_value in sorted(ids):
            scanned += 1
            rows_by_db: dict[str, dict[str, Any] | None] = {}
            for db_name in ("mysql", "postgres", "oracle"):
                try:
                    tbl = get_table(db_name, table_name)  # type: ignore[arg-type]
                    rows_by_db[db_name] = _fetch_row_by_pk(clients[db_name], db_name, table=tbl, pk_value=pk_value)  # type: ignore[arg-type]
                except Exception:  # noqa: BLE001
                    rows_by_db[db_name] = None

            present = [db for db, row in rows_by_db.items() if row is not None]
            if len(present) != 3:
                missing = [db for db in ("mysql", "postgres", "oracle") if db not in present]
                reason = f"reconcile: missing row in {','.join(missing)}"
            else:
                sigs = {db: _row_signature(rows_by_db[db] or {}) for db in ("mysql", "postgres", "oracle")}
                if len(set(sigs.values())) == 1:
                    reason = ""
                else:
                    diffs = _diff_columns(rows_by_db)[:8]
                    diff_txt = ",".join(diffs) if diffs else "unknown"
                    reason = f"reconcile: row differs ({diff_txt})"

            if reason:
                # De-dup open conflicts for same table/pk/reason.
                with store.engine.begin() as conn:
                    stmt = (
                        select(conflicts_table.c.id)
                        .where(conflicts_table.c.status == "open")
                        .where(conflicts_table.c.table_name == table_name)
                        .where(conflicts_table.c.pk_value == pk_value)
                        .where(conflicts_table.c.reason == reason)
                        .limit(1)
                    )
                    exists = conn.execute(stmt).first()
                    if not exists:
                        payload: dict[str, Any] = {
                            "table_name": table_name,
                            "pk_value": pk_value,
                            "status": "open",
                            "reason": reason,
                            "source_db": "reconcile",
                        }
                        if "resolution_method" in conflicts_table.c:
                            payload["resolution_method"] = "scan"
                        conn.execute(insert(conflicts_table), payload)
                        created += 1
                        try_email(table_name, pk_value, reason)
                details.append({"table": table_name, "pk": pk_value, "reason": reason, "present": present})
            elif auto_resolve:
                with store.engine.begin() as conn:
                    q = (
                        update(conflicts_table)
                        .where(conflicts_table.c.status == "open")
                        .where(conflicts_table.c.table_name == table_name)
                        .where(conflicts_table.c.pk_value == pk_value)
                        .values(status="resolved")
                    )
                    if "resolution_method" in conflicts_table.c:
                        q = q.values(resolution_method="auto_clear")
                    res = conn.execute(q)
                    resolved += int(res.rowcount or 0)

    # Optionally bump daily conflicts count for visibility.
    try:
        stats = _reflect(store, store_db, "sync_stats_daily")
        with store.engine.begin() as conn:
            today = now.date()
            try:
                conn.execute(insert(stats), {"stat_date": today})
            except Exception:  # noqa: BLE001
                pass
            if created:
                conn.execute(
                    update(stats).where(stats.c.stat_date == today).values(conflicts=stats.c.conflicts + int(created))
                )
    except Exception:  # noqa: BLE001
        pass

    return {
        "ok": True,
        "full_scan": bool(full_scan),
        "interval_seconds": interval_seconds,
        "window_minutes": window_minutes,
        "max_pks": max_pks,
        "max_full_scan_pks": max_full_scan_pks,
        "store_db": store_db,
        "since": since.isoformat(),
        "scanned": scanned,
        "conflicts_created": created,
        "conflicts_auto_resolved": resolved,
        "emails_sent_best_effort": emailed,
        "details": details[:200],
    }


def iter_reconcile_forever() -> Iterable[dict[str, Any]]:
    settings = get_settings()
    interval_seconds = int(getattr(settings, "reconcile_interval_seconds", 60))
    while True:
        yield reconcile_once()
        time.sleep(max(10, interval_seconds))
