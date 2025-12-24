from __future__ import annotations

import time
from dataclasses import dataclass
from typing import Any

from sqlalchemy import MetaData, Table, delete, insert, select
from sqlalchemy import inspect as sa_inspect
from sqlalchemy.exc import NoSuchTableError

from app.core.settings import get_settings
from app.db.clients import get_db_clients


@dataclass(frozen=True)
class MigrationResult:
    table: str
    source_db: str
    target_db: str
    rows_read: int
    rows_written: int
    seconds: float


def _normalize_table_name(db_name: str, table_name: str) -> str:
    if db_name == "oracle":
        return table_name.upper()
    return table_name


def _schema_for(db_name: str) -> str | None:
    settings = get_settings()
    if db_name == "postgres":
        return "public"
    if db_name == "oracle":
        if settings.oracle_schema and settings.oracle_schema.strip():
            return settings.oracle_schema.strip().upper()
        return settings.oracle_user.upper()
    return None


def _resolve_physical_table_name(db_name: str, table_name: str) -> tuple[str, str | None]:
    clients = get_db_clients()
    client = clients[db_name]
    schema = _schema_for(db_name)
    insp = sa_inspect(client.engine)
    names = insp.get_table_names(schema=schema)
    mapping = {n.lower(): n for n in names}
    physical = mapping.get(table_name.lower()) or mapping.get(_normalize_table_name(db_name, table_name).lower())
    if not physical:
        raise NoSuchTableError(_normalize_table_name(db_name, table_name))
    return physical, schema


def _reflect_table(db_name: str, table_name: str) -> Table:
    clients = get_db_clients()
    client = clients[db_name]
    physical, schema = _resolve_physical_table_name(db_name, table_name)
    meta = MetaData()
    return Table(physical, meta, autoload_with=client.engine, schema=schema)


def migrate_table(
    *,
    source_db: str,
    target_db: str,
    table_name: str,
    truncate_target: bool,
    batch_size: int,
) -> dict[str, Any]:
    clients = get_db_clients()
    src = clients[source_db]
    dst = clients[target_db]

    src_table = _reflect_table(source_db, table_name)
    dst_table = _reflect_table(target_db, table_name)

    started = time.perf_counter()
    rows_read = 0
    rows_written = 0

    with src.engine.connect() as src_conn, dst.engine.begin() as dst_conn:
        if truncate_target:
            dst_conn.execute(delete(dst_table))

        # Simple batch scan (OFFSET-based). Good enough for course-size datasets.
        offset = 0
        while True:
            batch = src_conn.execute(select(src_table).offset(offset).limit(batch_size)).mappings().all()
            if not batch:
                break
            rows_read += len(batch)

            # Only insert columns that exist in destination (defensive for minor schema diffs).
            dst_cols_by_lower = {name.lower(): name for name in dst_table.c.keys()}
            payload = []
            for row in batch:
                mapped = {}
                for k, v in row.items():
                    dst_name = dst_cols_by_lower.get(str(k).lower())
                    if dst_name:
                        mapped[dst_name] = v
                if mapped:
                    payload.append(mapped)
            if payload:
                dst_conn.execute(insert(dst_table), payload)
                rows_written += len(payload)

            offset += batch_size

    seconds = time.perf_counter() - started
    result = MigrationResult(
        table=table_name,
        source_db=source_db,
        target_db=target_db,
        rows_read=rows_read,
        rows_written=rows_written,
        seconds=seconds,
    )
    return result.__dict__


def truncate_table(*, target_db: str, table_name: str) -> None:
    clients = get_db_clients()
    dst = clients[target_db]
    dst_table = _reflect_table(target_db, table_name)
    with dst.engine.begin() as conn:
        conn.execute(delete(dst_table))


def migrate_database(
    *,
    source_db: str,
    target_db: str,
    tables: list[str],
    truncate_target: bool,
    batch_size: int,
) -> dict[str, Any]:
    results: list[dict[str, Any]] = []

    # If truncating, delete in reverse order to reduce FK violations.
    ordered_tables = list(tables)
    if truncate_target:
        for t in reversed(ordered_tables):
            truncate_table(target_db=target_db, table_name=t)

        for t in ordered_tables:
            results.append(
                migrate_table(
                    source_db=source_db,
                    target_db=target_db,
                    table_name=t,
                    truncate_target=False,
                    batch_size=batch_size,
                )
            )
    else:
        for t in ordered_tables:
            results.append(
                migrate_table(
                    source_db=source_db,
                    target_db=target_db,
                    table_name=t,
                    truncate_target=False,
                    batch_size=batch_size,
                )
            )

    return {"source_db": source_db, "target_db": target_db, "results": results}
