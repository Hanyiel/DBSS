import threading
import time

from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from sqlalchemy.exc import NoSuchTableError, OperationalError

from app.api.router import api_router
from app.core.settings import get_settings
from app.services.reconcile import reconcile_once
from app.services.sync import DbName, run_once

try:
    from apscheduler.schedulers.background import BackgroundScheduler
except Exception:  # noqa: BLE001
    BackgroundScheduler = None  # type: ignore[assignment]

_scheduler = None
_sync_thread = None
_sync_stop = None


def create_app() -> FastAPI:
    settings = get_settings()

    app = FastAPI(title=settings.app_name)

    @app.exception_handler(OperationalError)
    async def _db_operational_error(_request: Request, exc: OperationalError):  # noqa: ANN001
        msg = str(getattr(exc, "orig", None) or exc)
        return JSONResponse(status_code=503, content={"detail": f"database unavailable: {msg}"})

    @app.exception_handler(NoSuchTableError)
    async def _no_such_table(_request: Request, exc: NoSuchTableError):  # noqa: ANN001
        return JSONResponse(status_code=404, content={"detail": f"table not found: {exc}"})

    @app.on_event("startup")
    def _start_background_jobs():  # noqa: ANN001
        global _scheduler, _sync_stop, _sync_thread

        def safe_sync_once(source_db: DbName):  # noqa: ANN001
            try:
                run_once(source_db, limit=int(getattr(settings, "sync_batch_limit", 50)))
            except Exception:  # noqa: BLE001
                pass

        def safe_reconcile_once(full_scan: bool):  # noqa: ANN001
            try:
                reconcile_once(full_scan=full_scan)
            except Exception:  # noqa: BLE001
                pass

        # Sync: realtime (poll) or scheduled (interval).
        if getattr(settings, "sync_enabled", True):
            mode = str(getattr(settings, "sync_mode", "realtime")).strip().lower()
            source_db = str(getattr(settings, "sync_source_db", "mysql")).strip().lower()
            if source_db not in ("mysql", "postgres", "oracle"):
                source_db = "mysql"
            source_db_typed: DbName = source_db  # type: ignore[assignment]

            if getattr(settings, "sync_run_on_startup", True):
                safe_sync_once(source_db_typed)

            if mode == "scheduled":
                seconds = max(60, int(getattr(settings, "sync_interval_seconds", 600)))
            else:
                # Default: near-real-time via small interval polling.
                seconds = max(1, int(getattr(settings, "sync_poll_seconds", 2)))

            # Avoid APScheduler "max instances reached" spam in realtime mode:
            # - realtime: run a simple single-thread loop (no overlap by design)
            # - scheduled: use APScheduler if available (better for long intervals)
            use_thread_loop = (mode != "scheduled") or (BackgroundScheduler is None)
            if use_thread_loop:
                if _sync_thread is None:
                    _sync_stop = threading.Event()

                    def _loop():  # noqa: ANN001
                        while _sync_stop is not None and not _sync_stop.is_set():
                            safe_sync_once(source_db_typed)
                            time.sleep(seconds)

                    _sync_thread = threading.Thread(target=_loop, name="sync-worker", daemon=True)
                    _sync_thread.start()
            else:
                if _scheduler is None:
                    _scheduler = BackgroundScheduler(daemon=True)
                _scheduler.add_job(
                    lambda: safe_sync_once(source_db_typed),
                    "interval",
                    seconds=seconds,
                    id="sync_once",
                    replace_existing=True,
                    coalesce=True,
                    max_instances=1,
                )

        # Reconcile: periodic consistency scan.
        if settings.reconcile_enabled and BackgroundScheduler is not None:
            if getattr(settings, "reconcile_run_on_startup", True):
                safe_reconcile_once(full_scan=bool(getattr(settings, "reconcile_startup_full_scan", True)))
            if _scheduler is None:
                _scheduler = BackgroundScheduler(daemon=True)
            _scheduler.add_job(
                lambda: safe_reconcile_once(full_scan=False),
                "interval",
                seconds=max(10, int(settings.reconcile_interval_seconds)),
                id="reconcile_once",
                replace_existing=True,
                coalesce=True,
                max_instances=1,
            )

        if _scheduler is not None:
            _scheduler.start()

    @app.on_event("shutdown")
    def _stop_reconcile_scheduler():  # noqa: ANN001
        global _scheduler, _sync_stop, _sync_thread
        if _sync_stop is not None:
            try:
                _sync_stop.set()
            except Exception:  # noqa: BLE001
                pass
        _sync_stop = None
        _sync_thread = None
        if _scheduler is not None:
            try:
                _scheduler.shutdown(wait=False)
            except Exception:  # noqa: BLE001
                pass
            _scheduler = None

    app.include_router(api_router, prefix=settings.api_prefix)

    cors_origins = settings.cors_origins_list
    if cors_origins:
        app.add_middleware(
            CORSMiddleware,
            allow_origins=cors_origins,
            allow_credentials=True,
            allow_methods=["*"],
            allow_headers=["*"],
        )

    return app


app = create_app()
