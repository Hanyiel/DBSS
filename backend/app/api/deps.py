from __future__ import annotations

from typing import Any

from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from jose import JWTError, jwt

from app.core.settings import Settings, get_settings

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/api/auth/token")


def get_current_token_payload(
    token: str = Depends(oauth2_scheme),
    settings: Settings = Depends(get_settings),
) -> dict[str, Any]:
    try:
        payload = jwt.decode(token, settings.secret_key, algorithms=["HS256"])
    except JWTError as exc:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid token") from exc
    return payload


def require_admin(payload: dict[str, Any] = Depends(get_current_token_payload)) -> dict[str, Any]:
    if payload.get("role") != "admin":
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Admin required")
    return payload

