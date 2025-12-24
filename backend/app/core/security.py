from __future__ import annotations

from datetime import datetime, timedelta, timezone
from typing import Any

from jose import jwt


def create_access_token(
    *,
    subject: str,
    secret_key: str,
    expires_delta: timedelta,
    extra_claims: dict[str, Any] | None = None,
) -> str:
    now = datetime.now(timezone.utc)
    expire = now + expires_delta
    payload: dict[str, Any] = {"sub": subject, "iat": int(now.timestamp()), "exp": int(expire.timestamp())}
    if extra_claims:
        payload.update(extra_claims)
    return jwt.encode(payload, secret_key, algorithm="HS256")

