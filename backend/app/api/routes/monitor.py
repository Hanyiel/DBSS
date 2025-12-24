from __future__ import annotations

from datetime import date, timedelta
from typing import Any, Literal

from fastapi import APIRouter, Depends, Query
from sqlalchemy import MetaData, Table, func, select
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
