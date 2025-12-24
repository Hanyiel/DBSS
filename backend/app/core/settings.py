from __future__ import annotations

from functools import lru_cache

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=False,
        extra="ignore",
    )

    app_name: str = "DBSS"
    api_prefix: str = "/api"
    env: str = "dev"
    log_level: str = "INFO"

    secret_key: str = "change-me"
    access_token_expire_minutes: int = 60 * 24
    admin_username: str = "admin"
    admin_password: str = "admin123"

    cors_origins: str = ""

    mysql_host: str = "127.0.0.1"
    mysql_port: int = 3307
    mysql_db: str = "video_conference"
    mysql_user: str = "root"
    mysql_password: str = ""

    pg_host: str = "127.0.0.1"
    pg_port: int = 5432
    pg_db: str = "video_conference"
    pg_user: str = "postgres"
    pg_password: str = ""

    oracle_host: str = "127.0.0.1"
    oracle_port: int = 1521
    oracle_service_name: str = "XEPDB1"
    oracle_user: str = "lhy"
    oracle_password: str = ""
    # Optional: override Oracle schema used for reflection (defaults to ORACLE_USER uppercased)
    oracle_schema: str | None = None

    sync_source_db: str = "mysql"
    sync_poll_seconds: int = 2

    @property
    def cors_origins_list(self) -> list[str]:
        if not self.cors_origins.strip():
            return []
        return [o.strip() for o in self.cors_origins.split(",") if o.strip()]


@lru_cache(maxsize=1)
def get_settings() -> Settings:
    return Settings()
