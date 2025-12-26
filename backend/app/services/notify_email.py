from __future__ import annotations

import logging
import threading
from dataclasses import dataclass
from datetime import timedelta
from email.message import EmailMessage
from html import escape as html_escape
from typing import Any
from urllib.parse import urlencode

import smtplib

from app.core.security import create_access_token
from app.core.settings import Settings, get_settings

logger = logging.getLogger(__name__)


@dataclass(frozen=True)
class ConflictEmail:
    store_db: str
    conflict_id: int | None
    table_name: str
    pk_value: str
    source_db: str
    target_db: str | None
    reason: str
    detected_at: str | None = None


def _recipients(settings: Settings) -> list[str]:
    raw = (settings.email_to or "").strip()
    if not raw:
        return []
    return [x.strip() for x in raw.split(",") if x.strip()]


def _from_addr(settings: Settings) -> str:
    if settings.email_from and settings.email_from.strip():
        return settings.email_from.strip()
    return settings.email_smtp_username.strip()


def _build_email_link(settings: Settings, ev: ConflictEmail) -> str:
    expires = timedelta(minutes=int(getattr(settings, "email_link_token_expire_minutes", 60)))
    token = create_access_token(
        subject=str(getattr(settings, "admin_username", "admin")),
        secret_key=settings.secret_key,
        expires_delta=expires,
        extra_claims={
            "role": "admin",
            "typ": "email_link",
            "store_db": ev.store_db,
            "conflict_id": ev.conflict_id,
        },
    )
    base = (settings.frontend_public_url or "http://localhost:5173").rstrip("/")
    qs = urlencode(
        {
            "token": token,
            "store_db": ev.store_db,
            "conflict_id": "" if ev.conflict_id is None else str(ev.conflict_id),
        }
    )
    return f"{base}/email-login?{qs}"


def _compose_message(settings: Settings, ev: ConflictEmail) -> EmailMessage:
    link = _build_email_link(settings, ev)
    subject = f"{settings.email_subject_prefix} 同步冲突: {ev.table_name} pk={ev.pk_value} ({ev.source_db}->{ev.target_db or '-'})"
    # Put the link on its own line to reduce the chance email clients break/truncate it.
    body = "\n".join(
        [
            "DBSS 同步系统检测到数据冲突：",
            f"- store_db: {ev.store_db}",
            f"- conflict_id: {ev.conflict_id}",
            f"- table: {ev.table_name}",
            f"- pk: {ev.pk_value}",
            f"- source_db: {ev.source_db}",
            f"- target_db: {ev.target_db or '-'}",
            f"- detected_at: {ev.detected_at or '-'}",
            "",
            "原因：",
            (ev.reason or "-"),
            "",
            "点击链接查看冲突（链接包含短期认证 token，可在 PC/移动端打开）：",
            f"<{link}>",
            "",
            "安全提示：链接 token 有有效期，请勿转发。",
        ]
    )

    msg = EmailMessage()
    msg["Subject"] = subject
    msg["From"] = _from_addr(settings)
    msg["To"] = ", ".join(_recipients(settings))
    msg.set_content(body)

    # Add a HTML version to improve link clickability in some mail clients.
    html = f"""\
<html>
  <body>
    <p><b>DBSS 同步系统检测到数据冲突</b></p>
    <ul>
      <li>store_db: {html_escape(str(ev.store_db))}</li>
      <li>conflict_id: {html_escape(str(ev.conflict_id))}</li>
      <li>table: {html_escape(str(ev.table_name))}</li>
      <li>pk: {html_escape(str(ev.pk_value))}</li>
      <li>source_db: {html_escape(str(ev.source_db))}</li>
      <li>target_db: {html_escape(str(ev.target_db or '-'))}</li>
      <li>detected_at: {html_escape(str(ev.detected_at or '-'))}</li>
    </ul>
    <p><b>原因</b></p>
    <pre style="white-space: pre-wrap;">{html_escape(str(ev.reason or '-'))}</pre>
    <p>
      <a href="{html_escape(link)}">点击查看冲突（含短期认证 token）</a>
    </p>
    <p style="color:#6b7280;font-size:12px;">安全提示：链接 token 有有效期，请勿转发。</p>
  </body>
</html>
"""
    msg.add_alternative(html, subtype="html")
    return msg


def _send_smtp(settings: Settings, msg: EmailMessage) -> None:
    host = settings.email_smtp_host.strip()
    port = int(settings.email_smtp_port)
    username = settings.email_smtp_username.strip()
    password = settings.email_smtp_password

    if settings.email_use_ssl:
        with smtplib.SMTP_SSL(host, port, timeout=15) as smtp:
            if username:
                smtp.login(username, password)
            smtp.send_message(msg)
        return

    with smtplib.SMTP(host, port, timeout=15) as smtp:
        smtp.ehlo()
        if settings.email_use_tls:
            smtp.starttls()
            smtp.ehlo()
        if username:
            smtp.login(username, password)
        smtp.send_message(msg)


def notify_conflict_created(ev: ConflictEmail, *, settings: Settings | None = None) -> dict[str, Any]:
    settings = settings or get_settings()
    if not getattr(settings, "email_enabled", False):
        logger.info("Email notify skipped: EMAIL_ENABLED=false")
        return {"ok": False, "skipped": True, "reason": "email disabled"}
    if not settings.email_smtp_host.strip():
        logger.warning("Email notify skipped: missing EMAIL_SMTP_HOST")
        return {"ok": False, "skipped": True, "reason": "missing email_smtp_host"}
    if not _recipients(settings):
        logger.warning("Email notify skipped: missing EMAIL_TO")
        return {"ok": False, "skipped": True, "reason": "missing email_to"}
    if not settings.secret_key.strip():
        logger.warning("Email notify skipped: missing SECRET_KEY")
        return {"ok": False, "skipped": True, "reason": "missing secret_key"}

    msg = _compose_message(settings, ev)

    def _run():  # noqa: ANN001
        try:
            _send_smtp(settings, msg)
            logger.info("Email notify sent to=%s subject=%s", msg.get("To"), msg.get("Subject"))
        except Exception as exc:
            # Best-effort notifications: don't crash sync worker.
            logger.exception("Email notify failed: %s", exc)

    t = threading.Thread(target=_run, name="email-notify", daemon=True)
    t.start()
    return {"ok": True, "sent_async": True, "to": _recipients(settings)}


def email_config_snapshot(*, settings: Settings | None = None) -> dict[str, Any]:
    settings = settings or get_settings()
    return {
        "enabled": bool(getattr(settings, "email_enabled", False)),
        "smtp_host": settings.email_smtp_host,
        "smtp_port": settings.email_smtp_port,
        "smtp_username": settings.email_smtp_username,
        "use_ssl": settings.email_use_ssl,
        "use_tls": settings.email_use_tls,
        "from": _from_addr(settings),
        "to": _recipients(settings),
        "frontend_public_url": settings.frontend_public_url,
        "token_expire_minutes": settings.email_link_token_expire_minutes,
    }


def send_test_email(*, settings: Settings | None = None, to: str | None = None) -> dict[str, Any]:
    settings = settings or get_settings()
    recipients = [to] if to else _recipients(settings)
    if not recipients:
        return {"ok": False, "error": "missing recipient (EMAIL_TO or to)"}
    msg = EmailMessage()
    msg["Subject"] = f"{settings.email_subject_prefix} 测试邮件"
    msg["From"] = _from_addr(settings)
    msg["To"] = ", ".join(recipients)
    msg.set_content("这是一封 DBSS 冲突邮件通知的测试邮件。如果你收到，说明 SMTP 配置正常。")
    try:
        _send_smtp(settings, msg)
        return {"ok": True, "to": recipients}
    except Exception as exc:
        return {"ok": False, "error": str(exc)}
