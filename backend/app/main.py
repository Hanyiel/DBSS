from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from sqlalchemy.exc import NoSuchTableError, OperationalError

from app.api.router import api_router
from app.core.settings import get_settings


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
