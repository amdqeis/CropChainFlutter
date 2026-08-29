"""
RoleVerification model.
Tracks the KYC (KTP) verification process for Petani and Distributor roles.
Status flow: pending → approved / rejected → (if rejected) resubmit → pending
"""
import enum
import uuid
from datetime import datetime
from typing import Optional

from sqlalchemy import Boolean, DateTime, Enum, ForeignKey, String
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.core.database import Base
from app.models.base import TimestampMixin, enum_values


class RoleType(str, enum.Enum):
    PETANI = "petani"
    DISTRIBUTOR = "distributor"


class VerificationStatus(str, enum.Enum):
    PENDING = "pending"
    APPROVED = "approved"
    REJECTED = "rejected"


class RoleVerification(Base, TimestampMixin):
    __tablename__ = "role_verifications"

    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), primary_key=True, default=uuid.uuid4
    )
    user_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    role_type: Mapped[RoleType] = mapped_column(
        Enum(RoleType, name="role_type_enum", values_callable=enum_values),
        nullable=False,
    )

    # KTP Verification Data
    ktp_number: Mapped[str] = mapped_column(String(500), nullable=False)
    ktp_photo: Mapped[str] = mapped_column(String(500), nullable=False)
    location: Mapped[str] = mapped_column(String(500), nullable=False)
    consent_given: Mapped[bool] = mapped_column(Boolean, nullable=False, default=False)
    consent_version: Mapped[str] = mapped_column(String(30), nullable=False, default="v1")
    consent_at: Mapped[Optional[datetime]] = mapped_column(DateTime(timezone=True), nullable=True)

    # Status
    status: Mapped[VerificationStatus] = mapped_column(
        Enum(VerificationStatus, name="verification_status_enum", values_callable=enum_values),
        nullable=False,
        default=VerificationStatus.PENDING,
    )
    rejection_reason: Mapped[Optional[str]] = mapped_column(String(1000), nullable=True)

    # Timestamps
    submitted_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), nullable=False
    )
    verified_at: Mapped[Optional[datetime]] = mapped_column(
        DateTime(timezone=True), nullable=True
    )

    # Relationships
    user: Mapped["User"] = relationship("User", back_populates="role_verifications")

    def __repr__(self) -> str:
        return (
            f"<RoleVerification user_id={self.user_id} "
            f"role={self.role_type} status={self.status}>"
        )
