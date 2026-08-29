"""
RoleVerification Pydantic schemas.
"""
import uuid
from datetime import datetime
from typing import Optional

from pydantic import BaseModel, ConfigDict, Field

from app.models.role_verification import RoleType, VerificationStatus


class RoleVerificationCreate(BaseModel):
    """Schema for submitting a new role verification request."""
    role_type: RoleType
    ktp_number: str = Field(..., min_length=16, max_length=16, description="NIK KTP 16 digit")
    ktp_photo: str = Field(..., description="URL foto KTP (hasil upload)")
    location: str = Field(..., min_length=5, max_length=500)
    consent_given: bool = Field(..., description="Persetujuan pemrosesan data KTP wajib true")
    consent_version: str = Field("v1", max_length=30)


class RoleVerificationResponse(BaseModel):
    """Full verification record response."""
    model_config = ConfigDict(from_attributes=True)

    id: uuid.UUID
    user_id: uuid.UUID
    role_type: RoleType
    ktp_number: str = Field(..., description="NIK termasking")
    ktp_photo: str = Field(..., description="Referensi aset privat")
    location: str
    status: VerificationStatus
    rejection_reason: Optional[str] = None
    submitted_at: datetime
    verified_at: Optional[datetime] = None
    created_at: datetime


class RoleVerificationStatusResponse(BaseModel):
    """Summary of verification status per role — used in profile."""
    model_config = ConfigDict(from_attributes=True)

    role_type: RoleType
    status: VerificationStatus
    rejection_reason: Optional[str] = None
    submitted_at: datetime
