import uuid
from datetime import datetime
from typing import Optional

from pydantic import BaseModel, ConfigDict, Field

from app.models.role_verification import RoleType, VerificationStatus


class VerificationDecision(BaseModel):
    status: VerificationStatus
    rejection_reason: Optional[str] = Field(None, max_length=1000)


class AdminVerificationResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    id: uuid.UUID
    user_id: uuid.UUID
    role_type: RoleType
    status: VerificationStatus
    ktp_number_masked: str
    ktp_photo: str
    location: str
    consent_given: bool
    consent_version: str
    submitted_at: datetime
    rejection_reason: Optional[str] = None


class AdminUserResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    id: uuid.UUID
    full_name: str
    email: str
    active_role: str
    is_email_verified: bool
    is_admin: bool
    created_at: datetime
