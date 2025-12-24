from __future__ import annotations

from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel, Field
from sqlalchemy.exc import NoSuchTableError

from app.api.deps import require_admin
from app.db.schemas import BUSINESS_TABLES
from app.services.migration import migrate_database, migrate_table

router = APIRouter()


class TableMigrationRequest(BaseModel):
    source_db: str = Field(..., description="mysql/postgres/oracle")
    target_db: str = Field(..., description="mysql/postgres/oracle")
    table_name: str
    truncate_target: bool = True
    batch_size: int = Field(500, ge=1, le=5000)


class DatabaseMigrationRequest(BaseModel):
    source_db: str
    target_db: str
    tables: list[str] = Field(default_factory=lambda: list(BUSINESS_TABLES))
    truncate_target: bool = True
    batch_size: int = Field(500, ge=1, le=5000)


@router.get("/tables")
def migration_tables(_admin: dict = Depends(require_admin)):
    return {"tables": BUSINESS_TABLES}


@router.post("/table")
def migrate_one_table(req: TableMigrationRequest, _admin: dict = Depends(require_admin)):
    if req.table_name not in BUSINESS_TABLES:
        raise HTTPException(status_code=400, detail="table_name must be a known business table")
    if req.source_db == req.target_db:
        raise HTTPException(status_code=400, detail="source_db and target_db must differ")
    try:
        return migrate_table(
            source_db=req.source_db,
            target_db=req.target_db,
            table_name=req.table_name,
            truncate_target=req.truncate_target,
            batch_size=req.batch_size,
        )
    except NoSuchTableError as exc:
        raise HTTPException(
            status_code=400,
            detail=(
                f"Table not found in {req.target_db} (or schema mismatch): {exc}."
                " If migrating to Oracle, ensure tables are created under the correct schema;"
                " you may need to set ORACLE_SCHEMA in backend/.env or rebuild containers."
            ),
        ) from exc


@router.post("/database")
def migrate_whole_database(req: DatabaseMigrationRequest, _admin: dict = Depends(require_admin)):
    unknown = [t for t in req.tables if t not in BUSINESS_TABLES]
    if unknown:
        raise HTTPException(status_code=400, detail=f"unknown tables: {unknown}")
    if req.source_db == req.target_db:
        raise HTTPException(status_code=400, detail="source_db and target_db must differ")
    try:
        return migrate_database(
            source_db=req.source_db,
            target_db=req.target_db,
            tables=req.tables,
            truncate_target=req.truncate_target,
            batch_size=req.batch_size,
        )
    except NoSuchTableError as exc:
        raise HTTPException(
            status_code=400,
            detail=(
                f"Table not found in {req.target_db} (or schema mismatch): {exc}."
                " If migrating to Oracle, ensure tables are created under the correct schema;"
                " you may need to set ORACLE_SCHEMA in backend/.env or rebuild containers."
            ),
        ) from exc
