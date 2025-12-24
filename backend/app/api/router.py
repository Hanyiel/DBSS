from fastapi import APIRouter

from app.api.routes import auth, conflicts, dbops, health, migration, monitor, schema, sync

api_router = APIRouter()

api_router.include_router(health.router, tags=["health"])
api_router.include_router(auth.router, prefix="/auth", tags=["auth"])
api_router.include_router(schema.router, prefix="/schema", tags=["schema"])
api_router.include_router(migration.router, prefix="/migration", tags=["migration"])
api_router.include_router(dbops.router, prefix="/db", tags=["db"])
api_router.include_router(sync.router, prefix="/sync", tags=["sync"])
api_router.include_router(conflicts.router, prefix="/conflicts", tags=["conflicts"])
api_router.include_router(monitor.router, prefix="/monitor", tags=["monitor"])
