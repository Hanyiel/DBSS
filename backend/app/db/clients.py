from __future__ import annotations

from dataclasses import dataclass
from functools import lru_cache
from typing import Any

from sqlalchemy import create_engine, text
from sqlalchemy.engine import Engine

from app.core.settings import get_settings


@dataclass(frozen=True)
class DbClient:
    name: str
    engine: Engine

    def _ping_query(self) -> str:
        if self.name == "oracle":
            return "SELECT 1 FROM dual"
        return "SELECT 1"

    def ping(self) -> dict[str, Any]:
        try:
            with self.engine.connect() as conn:
                conn.execute(text(self._ping_query()))
            return {"ok": True}
        except Exception as exc:  # noqa: BLE001
            return {"ok": False, "error": str(exc)}

    def count_rows(self, table_name: str) -> int:
        stmt = text(f"SELECT COUNT(*) AS c FROM {table_name}")
        with self.engine.connect() as conn:
            return int(conn.execute(stmt).scalar_one())


def _mysql_url() -> str:
    settings = get_settings()
    return (
        f"mysql+pymysql://{settings.mysql_user}:{settings.mysql_password}"
        f"@{settings.mysql_host}:{settings.mysql_port}/{settings.mysql_db}?charset=utf8mb4"
    )


def _pg_url() -> str:
    settings = get_settings()
    return (
        f"postgresql+psycopg2://{settings.pg_user}:{settings.pg_password}"
        f"@{settings.pg_host}:{settings.pg_port}/{settings.pg_db}"
    )


def _oracle_url() -> str:
    settings = get_settings()
    # service_name is required for Oracle XE (XEPDB1)
    return (
        f"oracle+oracledb://{settings.oracle_user}:{settings.oracle_password}"
        f"@{settings.oracle_host}:{settings.oracle_port}/?service_name={settings.oracle_service_name}"
    )


@lru_cache(maxsize=1)
def get_db_clients() -> dict[str, DbClient]:
    mysql_engine = create_engine(_mysql_url(), pool_pre_ping=True, future=True)
    pg_engine = create_engine(_pg_url(), pool_pre_ping=True, future=True)
    oracle_engine = create_engine(_oracle_url(), pool_pre_ping=True, future=True)

    return {
        "mysql": DbClient("mysql", mysql_engine),
        "postgres": DbClient("postgres", pg_engine),
        "oracle": DbClient("oracle", oracle_engine),
    }
