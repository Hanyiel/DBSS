from datetime import timedelta

from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm

from app.api.deps import get_current_token_payload
from app.core.security import create_access_token
from app.core.settings import Settings, get_settings

router = APIRouter()


@router.post("/token")
def login(
    form: OAuth2PasswordRequestForm = Depends(),
    settings: Settings = Depends(get_settings),
):
    if form.username != settings.admin_username or form.password != settings.admin_password:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid credentials")

    access_token_expires = timedelta(minutes=settings.access_token_expire_minutes)
    token = create_access_token(
        subject=form.username,
        secret_key=settings.secret_key,
        expires_delta=access_token_expires,
        extra_claims={"role": "admin"},
    )
    return {"access_token": token, "token_type": "bearer"}


@router.get("/me")
def me(payload: dict = Depends(get_current_token_payload)):
    return {"sub": payload.get("sub"), "role": payload.get("role")}
