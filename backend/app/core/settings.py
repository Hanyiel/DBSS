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

    # Sync worker (change_log -> apply to other DBs)
    sync_enabled: bool = True
    sync_mode: str = "realtime"  # realtime | scheduled
    sync_source_db: str = "mysql"
    sync_poll_seconds: int = 2
    sync_interval_seconds: int = 600  # 10 minutes for scheduled mode
    sync_batch_limit: int = 50
    sync_run_on_startup: bool = True

    # Email notifications (conflicts -> email)
    email_enabled: bool = False
    email_smtp_host: str = ""
    email_smtp_port: int = 465
    email_smtp_username: str = ""
    # For providers like 163, use SMTP auth code (not login password)
    email_smtp_password: str = ""
    email_use_ssl: bool = True
    email_use_tls: bool = False
    email_from: str = ""
    email_to: str = ""  # comma-separated recipients
    email_subject_prefix: str = "[DBSS]"
    frontend_public_url: str = "http://localhost:5173"
    email_link_token_expire_minutes: int = 60
    email_max_per_run: int = 10

    # Reconcile (periodic consistency scan -> conflicts table)
    reconcile_enabled: bool = False
    reconcile_interval_seconds: int = 60
    reconcile_window_minutes: int = 5
    reconcile_max_pks: int = 200
    reconcile_full_scan_max_pks: int = 5000
    reconcile_store_db: str = "mysql"
    reconcile_auto_resolve: bool = False
    reconcile_run_on_startup: bool = True
    reconcile_startup_full_scan: bool = True

    @property
    def cors_origins_list(self) -> list[str]:
        if not self.cors_origins.strip():
            return []
        return [o.strip() for o in self.cors_origins.split(",") if o.strip()]


@lru_cache(maxsize=1)
def get_settings() -> Settings:
    return Settings()
