from __future__ import annotations

from fastapi import APIRouter, Depends
from pydantic import BaseModel, Field

from app.api.deps import require_admin
from app.services.notify_email import email_config_snapshot, send_test_email

router = APIRouter()


@router.get("/email/config")
def get_email_config(_admin: dict = Depends(require_admin)):
    return email_config_snapshot()


class TestEmailRequest(BaseModel):
    to: str | None = Field(None, description="optional override recipient email")


@router.post("/email/test")
def test_email(req: TestEmailRequest, _admin: dict = Depends(require_admin)):
    return send_test_email(to=req.to)

