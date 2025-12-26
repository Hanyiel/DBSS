from __future__ import annotations

from fastapi import APIRouter, Depends
from pydantic import BaseModel, Field
from sqlalchemy import inspect as sa_inspect

from app.api.deps import require_admin
from app.core.settings import Settings, get_settings
from app.db.clients import get_db_clients
from app.services.sync import DbName, run_once

router = APIRouter()


class SyncRunOnceRequest(BaseModel):
    source_db: DbName = Field(..., description="mysql/postgres/oracle")
    limit: int = Field(50, ge=1, le=200)


@router.get("/config")
def sync_config(settings: Settings = Depends(get_settings), _admin: dict = Depends(require_admin)):
    return {
        "sync_enabled": settings.sync_enabled,
        "sync_mode": settings.sync_mode,
        "sync_source_db": settings.sync_source_db,
        "sync_poll_seconds": settings.sync_poll_seconds,
        "sync_interval_seconds": settings.sync_interval_seconds,
        "sync_batch_limit": settings.sync_batch_limit,
        "sync_run_on_startup": settings.sync_run_on_startup,
    }


@router.post("/run-once")
def sync_run_once(req: SyncRunOnceRequest, _admin: dict = Depends(require_admin)):
    return run_once(req.source_db, limit=req.limit)


@router.get("/precheck")
def sync_precheck(settings: Settings = Depends(get_settings), _admin: dict = Depends(require_admin)):
    clients = get_db_clients()
    needed = ["change_log", "sync_applied", "conflicts", "sync_stats_daily", "audit_log"]
    out = {}
    for name, client in clients.items():
        try:
            insp = sa_inspect(client.engine)
            schema = None
            if name == "postgres":
                schema = "public"
            if name == "oracle":
                schema = (settings.oracle_schema or settings.oracle_user).upper()
            tables = {t.lower() for t in insp.get_table_names(schema=schema)}
            out[name] = {
                "ok": True,
                "missing_tables": [t for t in needed if t.lower() not in tables],
                "schema": schema,
            }
        except Exception as exc:  # noqa: BLE001
            out[name] = {"ok": False, "error": str(exc)}
    return out
