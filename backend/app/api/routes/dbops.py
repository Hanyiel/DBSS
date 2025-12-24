from __future__ import annotations

from typing import Any, Literal

from fastapi import APIRouter, Depends, HTTPException, Query
from pydantic import BaseModel, Field
from sqlalchemy import MetaData, Table, delete, insert, select
from sqlalchemy import inspect as sa_inspect
from sqlalchemy.exc import IntegrityError, SQLAlchemyError

from app.api.deps import require_admin
from app.core.settings import get_settings
from app.db.clients import get_db_clients
from app.db.schemas import BUSINESS_TABLES
from app.services.sync import apply_direct_change, safe_try_apply_from_change_log

router = APIRouter()


DbName = Literal["mysql", "postgres", "oracle"]


def _schema_for(db_name: DbName) -> str | None:
    settings = get_settings()
    if db_name == "postgres":
        return "public"
    if db_name == "oracle":
        if settings.oracle_schema and settings.oracle_schema.strip():
            return settings.oracle_schema.strip().upper()
        return settings.oracle_user.upper()
    return None


def _assert_business_table(table_name: str) -> None:
    if table_name.lower() not in BUSINESS_TABLES:
        raise HTTPException(status_code=400, detail="Only business tables are allowed")


def _resolve_physical_table_name(db_name: DbName, table_name: str) -> tuple[str, str | None]:
    clients = get_db_clients()
    client = clients[db_name]
    schema = _schema_for(db_name)
    try:
        inspector = sa_inspect(client.engine)
        names = inspector.get_table_names(schema=schema)
    except SQLAlchemyError as exc:
        raise HTTPException(
            status_code=503,
            detail=f"{db_name} unavailable: {exc}",
        ) from exc
    mapping = {n.lower(): n for n in names}
    physical = mapping.get(table_name.lower())
    if not physical:
        raise HTTPException(
            status_code=404,
            detail=f"Table '{table_name}' not found in {db_name} (schema={schema or 'default'})",
        )

    return physical, schema


def _get_table(db_name: DbName, table_name: str) -> Table:
    clients = get_db_clients()
    client = clients[db_name]
    physical, schema = _resolve_physical_table_name(db_name, table_name)
    meta = MetaData()
    try:
        return Table(
            physical,
            meta,
            autoload_with=client.engine,
            schema=schema,
        )
    except SQLAlchemyError as exc:
        raise HTTPException(status_code=503, detail=f"{db_name} unavailable: {exc}") from exc


class ColumnInfo(BaseModel):
    name: str
    type: str
    nullable: bool
    default: str | None = None


class TableInfo(BaseModel):
    db: str
    table: str
    schema_name: str | None
    columns: list[ColumnInfo]
    primary_key: list[str] = Field(default_factory=list)
    foreign_keys: list[dict[str, Any]] = Field(default_factory=list)
    indexes: list[dict[str, Any]] = Field(default_factory=list)


class InsertRowRequest(BaseModel):
    values: dict[str, Any]


@router.get("/dbs")
def list_dbs(_admin: dict = Depends(require_admin)):
    return {"dbs": ["mysql", "postgres", "oracle"]}


@router.get("/{db_name}/tables")
def list_tables(
    db_name: DbName,
    scope: Literal["business", "all"] = Query("business"),
    _admin: dict = Depends(require_admin),
):
    clients = get_db_clients()
    client = clients[db_name]
    schema = _schema_for(db_name)
    try:
        inspector = sa_inspect(client.engine)
        names = inspector.get_table_names(schema=schema)
    except SQLAlchemyError as exc:
        raise HTTPException(status_code=503, detail=f"{db_name} unavailable: {exc}") from exc

    if scope == "business":
        existing = {n.lower() for n in names}
        selected = [t for t in BUSINESS_TABLES if t.lower() in existing]
        return {"db": db_name, "schema": schema, "tables": selected}

    return {"db": db_name, "schema": schema, "tables": names}


@router.get("/{db_name}/tables/{table_name}", response_model=TableInfo)
def describe_table(db_name: DbName, table_name: str, _admin: dict = Depends(require_admin)):
    _assert_business_table(table_name)

    clients = get_db_clients()
    client = clients[db_name]
    try:
        inspector = sa_inspect(client.engine)
        physical_name, schema = _resolve_physical_table_name(db_name, table_name)
    except SQLAlchemyError as exc:
        raise HTTPException(status_code=503, detail=f"{db_name} unavailable: {exc}") from exc

    cols = inspector.get_columns(physical_name, schema=schema)
    pk = inspector.get_pk_constraint(physical_name, schema=schema) or {}
    fks = inspector.get_foreign_keys(physical_name, schema=schema) or []
    idx = inspector.get_indexes(physical_name, schema=schema) or []

    columns = [
        ColumnInfo(
            name=c.get("name"),
            type=str(c.get("type")),
            nullable=bool(c.get("nullable")),
            default=None if c.get("default") is None else str(c.get("default")),
        )
        for c in cols
    ]

    return TableInfo(
        db=db_name,
        table=table_name,
        schema_name=schema,
        columns=columns,
        primary_key=list(pk.get("constrained_columns") or []),
        foreign_keys=fks,
        indexes=idx,
    )


@router.get("/{db_name}/tables/{table_name}/rows")
def list_rows(
    db_name: DbName,
    table_name: str,
    limit: int = Query(20, ge=1, le=200),
    offset: int = Query(0, ge=0, le=100000),
    _admin: dict = Depends(require_admin),
):
    _assert_business_table(table_name)
    table = _get_table(db_name, table_name)

    clients = get_db_clients()
    client = clients[db_name]
    try:
        with client.engine.connect() as conn:
            rows = conn.execute(select(table).offset(offset).limit(limit)).mappings().all()
    except SQLAlchemyError as exc:
        raise HTTPException(status_code=503, detail=f"{db_name} unavailable: {exc}") from exc
    return {"db": db_name, "table": table_name, "limit": limit, "offset": offset, "rows": [dict(r) for r in rows]}


@router.post("/{db_name}/tables/{table_name}/rows")
def insert_row(db_name: DbName, table_name: str, req: InsertRowRequest, _admin: dict = Depends(require_admin)):
    _assert_business_table(table_name)
    table = _get_table(db_name, table_name)

    values = dict(req.values)
    cols_by_lower = {name.lower(): name for name in table.c.keys()}
    payload: dict[str, Any] = {}
    for k, v in values.items():
        col_name = cols_by_lower.get(str(k).lower())
        if col_name:
            payload[col_name] = v
    if not payload:
        raise HTTPException(status_code=400, detail="No valid columns in payload")

    clients = get_db_clients()
    client = clients[db_name]
    try:
        with client.engine.begin() as conn:
            result = conn.execute(insert(table), payload)
    except IntegrityError as exc:
        raise HTTPException(status_code=409, detail=f"Insert failed: {exc.orig}") from exc
    inserted_pk = [str(x) for x in (result.inserted_primary_key or [])]

    # Auto sync: insert -> propagate to other two DBs.
    sync_result: Any = {"skipped": True, "reason": "not attempted"}
    pk_value = inserted_pk[0] if inserted_pk else payload.get("id")
    if pk_value is None:
        sync_result = {"skipped": True, "reason": "cannot determine inserted id"}
    else:
        # 1) Try change_log based sync (recommended for overall system)
        res = safe_try_apply_from_change_log(db_name, table_name=table_name, pk_value=str(pk_value), op="I")
        if res.get("mode") == "change_log" and res.get("skipped"):
            # 2) Fallback: direct sync so UI CRUD still demonstrates "write -> sync"
            try:
                direct = apply_direct_change(db_name, table_name=table_name, pk_value=str(pk_value), op="I")
                sync_result = {"mode": "direct", **direct}
            except Exception as exc:  # noqa: BLE001
                sync_result = {"mode": "direct", "skipped": True, "reason": "sync failed", "error": str(exc)}
        else:
            sync_result = res

    return {"ok": True, "inserted_primary_key": inserted_pk, "sync": sync_result}


@router.delete("/{db_name}/tables/{table_name}/rows/{row_id}")
def delete_row(db_name: DbName, table_name: str, row_id: str, _admin: dict = Depends(require_admin)):
    _assert_business_table(table_name)
    table = _get_table(db_name, table_name)

    id_col = None
    for col_name in table.c.keys():
        if col_name.lower() == "id":
            id_col = table.c[col_name]
            break
    if id_col is None:
        raise HTTPException(status_code=400, detail="Only tables with 'id' primary key are supported")

    # Try to coerce id type (Oracle NUMBER etc.).
    try:
        py = id_col.type.python_type
        if py is int:
            row_id_value = int(row_id)
        else:
            row_id_value = row_id
    except Exception:  # noqa: BLE001
        row_id_value = row_id

    clients = get_db_clients()
    client = clients[db_name]
    with client.engine.begin() as conn:
        res = conn.execute(delete(table).where(id_col == row_id_value))

    # Auto sync: delete -> propagate to other two DBs.
    try:
        res2 = safe_try_apply_from_change_log(db_name, table_name=table_name, pk_value=str(row_id), op="D")
        if res2.get("mode") == "change_log" and res2.get("skipped"):
            direct = apply_direct_change(db_name, table_name=table_name, pk_value=str(row_id), op="D")
            sync_result = {"mode": "direct", **direct}
        else:
            sync_result = res2
    except Exception as exc:  # noqa: BLE001
        sync_result = {"skipped": True, "reason": "sync failed", "error": str(exc)}

    return {"ok": True, "deleted": int(res.rowcount or 0), "sync": sync_result}

