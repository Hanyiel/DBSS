from __future__ import annotations

import subprocess
from datetime import datetime
from pathlib import Path
from typing import Any

from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel, Field
from sqlalchemy.exc import NoSuchTableError
from sqlalchemy.exc import SQLAlchemyError, IntegrityError

from app.api.deps import require_admin
from app.db.schemas import BUSINESS_TABLES
from app.services.migration import migrate_database, migrate_table

router = APIRouter()


def _repo_root() -> Path:
    here = Path(__file__).resolve()
    for parent in here.parents:
        if (parent / "deploy").exists() and (parent / "backend").exists() and (parent / "frontend").exists():
            return parent
    # Fallback: backend/app/api/routes/migration.py -> repo root at parents[4]
    return here.parents[4]


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


class BackupRequest(BaseModel):
    skip_mysql: bool = False
    skip_postgres: bool = False
    skip_oracle: bool = False


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
    except IntegrityError as exc:
        raise HTTPException(status_code=409, detail=f"Migration failed: {exc.orig}") from exc
    except NoSuchTableError as exc:
        raise HTTPException(
            status_code=400,
            detail=(
                f"Table not found in {req.target_db} (or schema mismatch): {exc}."
                " If migrating to Oracle, ensure tables are created under the correct schema;"
                " you may need to set ORACLE_SCHEMA in backend/.env or rebuild containers."
            ),
        ) from exc
    except SQLAlchemyError as exc:
        raise HTTPException(status_code=500, detail=f"Migration failed: {exc}") from exc
    except Exception as exc:  # noqa: BLE001
        raise HTTPException(status_code=500, detail=f"Migration failed: {exc}") from exc


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
    except IntegrityError as exc:
        raise HTTPException(status_code=409, detail=f"Migration failed: {exc.orig}") from exc
    except NoSuchTableError as exc:
        raise HTTPException(
            status_code=400,
            detail=(
                f"Table not found in {req.target_db} (or schema mismatch): {exc}."
                " If migrating to Oracle, ensure tables are created under the correct schema;"
                " you may need to set ORACLE_SCHEMA in backend/.env or rebuild containers."
            ),
        ) from exc
    except SQLAlchemyError as exc:
        raise HTTPException(status_code=500, detail=f"Migration failed: {exc}") from exc
    except Exception as exc:  # noqa: BLE001
        raise HTTPException(status_code=500, detail=f"Migration failed: {exc}") from exc


@router.post("/backup")
def backup_databases(req: BackupRequest, _admin: dict = Depends(require_admin)):
    """
    Trigger a full backup for MySQL/PostgreSQL/Oracle by calling deploy/backup.ps1.

    Notes:
    - This is intended for local demo/teaching usage (admin only).
    - The produced files are stored under backup/dumps/<timestamp>/.
    """
    root = _repo_root()
    script = root / "deploy" / "backup.ps1"
    if not script.exists():
        raise HTTPException(status_code=500, detail=f"backup script not found: {script}")

    ts = datetime.now().strftime("%Y%m%d-%H%M%S")
    out_dir = root / "backup" / "dumps" / ts
    out_dir.mkdir(parents=True, exist_ok=True)

    args: list[str] = [
        "powershell",
        "-NoProfile",
        "-ExecutionPolicy",
        "Bypass",
        "-File",
        str(script),
        "-OutDir",
        str(out_dir),
    ]
    if req.skip_mysql:
        args.append("-SkipMySQL")
    if req.skip_postgres:
        args.append("-SkipPostgres")
    if req.skip_oracle:
        args.append("-SkipOracle")

    try:
        proc = subprocess.run(args, capture_output=True, text=True, timeout=15 * 60, cwd=str(root), check=False)
    except Exception as exc:  # noqa: BLE001
        raise HTTPException(status_code=500, detail=f"backup failed to start: {exc}") from exc

    if proc.returncode != 0:
        raise HTTPException(
            status_code=500,
            detail={
                "error": "backup failed",
                "returncode": proc.returncode,
                "stdout": proc.stdout[-4000:],
                "stderr": proc.stderr[-4000:],
                "out_dir": str(out_dir),
            },
        )

    files: list[dict[str, Any]] = []
    for p in sorted(out_dir.glob("*")):
        if p.is_file():
            files.append({"name": p.name, "bytes": p.stat().st_size})

    if not files:
        raise HTTPException(
            status_code=500,
            detail={
                "error": "backup produced no files",
                "stdout": proc.stdout[-4000:],
                "stderr": proc.stderr[-4000:],
                "out_dir": str(out_dir),
            },
        )

    return {"ok": True, "out_dir": str(out_dir), "files": files, "stdout_tail": proc.stdout[-2000:]}
