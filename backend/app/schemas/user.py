"""
User-related Pydantic schemas for request/response validation.
"""
import uuid
from datetime import datetime
from typing import List, Optional

from pydantic import BaseModel, ConfigDict, EmailStr, Field

from app.models.user import ActiveRole
from app.models.role_verification import RoleType, VerificationStatus


# ─── Auth Schemas ─────────────────────────────────────────────────────────────

class UserRegister(BaseModel):
    """Schema for user registration request."""
    full_name: str = Field(..., min_length=2, max_length=255)
    email: EmailStr
    password: str = Field(..., min_length=8, description="Minimum 8 characters")


class OTPVerify(BaseModel):
    """Schema for OTP verification after registration."""
    email: EmailStr
    otp_code: str = Field(..., min_length=6, max_length=6, pattern=r"^\d{6}$")


class OTPResend(BaseModel):
    """Schema for resending OTP."""
    email: EmailStr


class UserLogin(BaseModel):
    """Schema for login request."""
    email: EmailStr
    password: str


class PasswordResetRequest(BaseModel):
    """Schema for requesting a password reset email."""
    email: EmailStr


class PasswordResetConfirm(BaseModel):
    """Schema for confirming password reset with token."""
    token: str
    new_password: str = Field(..., min_length=8)


# ─── Token Schemas ────────────────────────────────────────────────────────────

class TokenPair(BaseModel):
    """Access + refresh token pair returned on login."""
    access_token: str
    refresh_token: str
    token_type: str = "bearer"


class TokenRefreshRequest(BaseModel):
    """Schema for refreshing access token."""
    refresh_token: str


class TokenData(BaseModel):
    """Internal schema for decoded JWT payload."""
    user_id: Optional[uuid.UUID] = None
    token_type: Optional[str] = None


# ─── Profile Schemas ──────────────────────────────────────────────────────────

class UserResponse(BaseModel):
    """Full user response including role info."""
    model_config = ConfigDict(from_attributes=True)

    id: uuid.UUID
    full_name: str
    email: EmailStr
    active_role: ActiveRole
    is_email_verified: bool
    is_admin: bool = False
    created_at: datetime
    updated_at: datetime

    # Computed field — list of approved roles
    verified_roles: Optional[List[str]] = None


class UserUpdate(BaseModel):
    """Schema for updating profile info."""
    full_name: Optional[str] = Field(None, min_length=2, max_length=255)


class ActiveRoleSwitch(BaseModel):
    """Schema for switching active role (must be already verified)."""
    new_role: ActiveRole


# ─── Verification Status Sub-schema ──────────────────────────────────────────

class VerificationStatusInfo(BaseModel):
    """Inline verification status for a single role."""
    model_config = ConfigDict(from_attributes=True)

    role_type: RoleType
    status: VerificationStatus
    rejection_reason: Optional[str] = None
    submitted_at: datetime
