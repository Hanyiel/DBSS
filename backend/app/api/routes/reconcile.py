from __future__ import annotations

from fastapi import APIRouter, Depends

from app.api.deps import require_admin
from app.core.settings import Settings, get_settings
from app.services.reconcile import reconcile_once

router = APIRouter()


@router.get("/config")
def reconcile_config(settings: Settings = Depends(get_settings), _admin: dict = Depends(require_admin)):
    return {
        "enabled": settings.reconcile_enabled,
        "interval_seconds": settings.reconcile_interval_seconds,
        "window_minutes": settings.reconcile_window_minutes,
        "max_pks": settings.reconcile_max_pks,
        "store_db": settings.reconcile_store_db,
        "auto_resolve": settings.reconcile_auto_resolve,
    }


@router.post("/run")
def reconcile_run(_admin: dict = Depends(require_admin)):
    return reconcile_once()

