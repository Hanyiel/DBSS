from fastapi import APIRouter, HTTPException

from app.db.clients import get_db_clients
from app.db.schemas import BUSINESS_TABLES

router = APIRouter()


@router.get("/tables")
def list_business_tables():
    return {"tables": BUSINESS_TABLES}


@router.get("/{db_name}/tables/{table_name}/count")
def table_count(db_name: str, table_name: str):
    if table_name not in BUSINESS_TABLES:
        raise HTTPException(status_code=404, detail="Unknown table")

    clients = get_db_clients()
    client = clients.get(db_name)
    if client is None:
        raise HTTPException(status_code=404, detail="Unknown database")

    return {"db": db_name, "table": table_name, "count": client.count_rows(table_name)}
