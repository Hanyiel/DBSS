from fastapi import APIRouter, Depends

from app.core.settings import Settings, get_settings
from app.db.clients import get_db_clients

router = APIRouter()


@router.get("/health")
def health(settings: Settings = Depends(get_settings)):
    clients = get_db_clients()
    results = {name: client.ping() for name, client in clients.items()}
    return {"ok": all(r["ok"] for r in results.values()), "databases": results}
