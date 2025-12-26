from __future__ import annotations

from datetime import date, datetime, timedelta
from typing import Any, Literal

from fastapi import APIRouter, Depends, Query
from sqlalchemy import Date, MetaData, Table, cast, desc, func, select
from sqlalchemy import inspect as sa_inspect
from sqlalchemy.exc import SQLAlchemyError

from app.api.deps import require_admin
from app.core.settings import get_settings
from app.db.clients import DbClient, get_db_clients

router = APIRouter()

DbName = Literal["mysql", "postgres", "oracle"]


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

def _day_expr(db_name: DbName, col) -> Any:
    if db_name == "oracle":
        return func.trunc(col)
    return cast(col, Date)


def _iso_date(v: Any) -> str:
    if isinstance(v, date):
        return v.isoformat()
    if isinstance(v, datetime):
        return v.date().isoformat()
    try:
        return str(v)
    except Exception:  # noqa: BLE001
        return ""


@router.get("/overview")
def monitor_overview(_admin: dict = Depends(require_admin)):
    clients = get_db_clients()
    out: dict[str, Any] = {}
    for name, client in clients.items():
        try:
            change_log = _reflect(client, name, "change_log")
            conflicts = _reflect(client, name, "conflicts")
            stats = _reflect(client, name, "sync_stats_daily")

            schema = _schema_for(name)
            processed_false = False if name == "postgres" else 0
            with client.engine.connect() as conn:
                backlog = int(
                    conn.execute(select(func.count()).select_from(change_log).where(change_log.c.processed == processed_false)).scalar() or 0
                )
                open_conflicts = int(
                    conn.execute(select(func.count()).select_from(conflicts).where(conflicts.c.status == "open")).scalar() or 0
                )
                today = conn.execute(select(stats).where(stats.c.stat_date == date.today())).mappings().first()
            out[name] = {
                "ok": True,
                "schema": schema,
                "backlog_unprocessed": backlog,
                "open_conflicts": open_conflicts,
                "today": dict(today) if today else None,
            }
        except SQLAlchemyError as exc:
            out[name] = {"ok": False, "error": str(exc)}
        except Exception as exc:  # noqa: BLE001
            out[name] = {"ok": False, "error": str(exc)}
    return out


@router.get("/daily")
def monitor_daily(
    days: int = Query(14, ge=1, le=90),
    _admin: dict = Depends(require_admin),
):
    clients = get_db_clients()
    start = date.today() - timedelta(days=days - 1)
    out: dict[str, Any] = {}
    for name, client in clients.items():
        try:
            stats = _reflect(client, name, "sync_stats_daily")
            with client.engine.connect() as conn:
                rows = (
                    conn.execute(select(stats).where(stats.c.stat_date >= start).order_by(stats.c.stat_date.asc())).mappings().all()
                )
            out[name] = {"ok": True, "rows": [dict(r) for r in rows]}
        except Exception as exc:  # noqa: BLE001
            out[name] = {"ok": False, "error": str(exc)}
    return out


@router.get("/conflicts/report")
def monitor_conflicts_report(
    days: int = Query(14, ge=1, le=90),
    _admin: dict = Depends(require_admin),
):
    """
    Conflict report (real data) aggregated from each DB's `conflicts` table.

    Returns per-DB totals, daily new/resolved counts, and top open tables/reasons.
    """
    clients = get_db_clients()
    start = date.today() - timedelta(days=days - 1)

    out: dict[str, Any] = {}
    for name, client in clients.items():
        try:
            conflicts = _reflect(client, name, "conflicts")
            has_reason = "reason" in conflicts.c
            has_resolved_at = "resolved_at" in conflicts.c

            day_detected = _day_expr(name, conflicts.c.detected_at).label("d")
            day_resolved = _day_expr(name, conflicts.c.resolved_at).label("d") if has_resolved_at else None

            with client.engine.connect() as conn:
                status_rows = conn.execute(
                    select(conflicts.c.status, func.count().label("cnt")).group_by(conflicts.c.status)
                ).all()
                by_status = {str(s): int(c or 0) for (s, c) in status_rows}
                total = int(sum(by_status.values()))
                total_open = int(by_status.get("open", 0))
                total_resolved = int(by_status.get("resolved", 0))

                created_daily_rows = conn.execute(
                    select(day_detected, func.count().label("cnt"))
                    .where(day_detected >= start)
                    .group_by(day_detected)
                    .order_by(day_detected.asc())
                ).all()
                created_range = int(sum(int(r[1] or 0) for r in created_daily_rows))

                resolved_daily_rows: list[tuple[Any, Any]] = []
                resolved_range = 0
                if day_resolved is not None:
                    resolved_daily_rows = conn.execute(
                        select(day_resolved, func.count().label("cnt"))
                        .where(conflicts.c.resolved_at.is_not(None))
                        .where(day_resolved >= start)
                        .group_by(day_resolved)
                        .order_by(day_resolved.asc())
                    ).all()
                    resolved_range = int(sum(int(r[1] or 0) for r in resolved_daily_rows))

                top_tables_rows = conn.execute(
                    select(conflicts.c.table_name.label("table_name"), func.count().label("cnt"))
                    .where(conflicts.c.status == "open")
                    .group_by(conflicts.c.table_name)
                    .order_by(desc(func.count()))
                    .limit(10)
                ).all()

                top_reasons_rows: list[tuple[Any, Any]] = []
                if has_reason:
                    reason_expr = func.coalesce(conflicts.c.reason, "(none)").label("reason")
                    top_reasons_rows = conn.execute(
                        select(reason_expr, func.count().label("cnt"))
                        .where(conflicts.c.status == "open")
                        .group_by(reason_expr)
                        .order_by(desc(func.count()))
                        .limit(10)
                    ).all()

            out[name] = {
                "ok": True,
                "totals": {
                    "total": total,
                    "open": total_open,
                    "resolved": total_resolved,
                    "created_range": created_range,
                    "resolved_range": resolved_range,
                },
                "created_daily": [{"date": _iso_date(d), "count": int(c or 0)} for (d, c) in created_daily_rows],
                "resolved_daily": [{"date": _iso_date(d), "count": int(c or 0)} for (d, c) in resolved_daily_rows],
                "top_open_tables": [{"table_name": str(t), "count": int(c or 0)} for (t, c) in top_tables_rows],
                "top_open_reasons": [{"reason": str(r), "count": int(c or 0)} for (r, c) in top_reasons_rows],
            }
        except Exception as exc:  # noqa: BLE001
            out[name] = {"ok": False, "error": str(exc)}

    return {
        "generated_at": datetime.utcnow().isoformat(),
        "days": days,
        "start_date": start.isoformat(),
        "end_date": date.today().isoformat(),
        "by_db": out,
    }
