"""
RoleVerification repository.
"""
import uuid
from datetime import datetime, timezone
from typing import List, Optional

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.role_verification import (
    RoleVerification,
    RoleType,
    VerificationStatus,
)


class RoleVerificationRepository:

    async def get_by_user_and_role(
        self,
        db: AsyncSession,
        *,
        user_id: uuid.UUID,
        role_type: RoleType,
    ) -> Optional[RoleVerification]:
        """Get the most recent verification record for a user+role combo."""
        result = await db.execute(
            select(RoleVerification)
            .where(
                RoleVerification.user_id == user_id,
                RoleVerification.role_type == role_type,
            )
            .order_by(RoleVerification.submitted_at.desc())
            .limit(1)
        )
        return result.scalar_one_or_none()

    async def get_all_by_user(
        self, db: AsyncSession, *, user_id: uuid.UUID
    ) -> List[RoleVerification]:
        """Get all verification records for a user (all roles)."""
        result = await db.execute(
            select(RoleVerification)
            .where(RoleVerification.user_id == user_id)
            .order_by(RoleVerification.submitted_at.desc())
        )
        return list(result.scalars().all())

    async def create(
        self,
        db: AsyncSession,
        *,
        user_id: uuid.UUID,
        role_type: RoleType,
        ktp_number: str,
        ktp_photo: str,
        location: str,
        consent_given: bool = False,
        consent_version: str = "v1",
    ) -> RoleVerification:
        """Create a new verification request (status=pending)."""
        record = RoleVerification(
            user_id=user_id,
            role_type=role_type,
            ktp_number=ktp_number,
            ktp_photo=ktp_photo,
            location=location,
            status=VerificationStatus.PENDING,
            submitted_at=datetime.now(timezone.utc),
            consent_given=consent_given,
            consent_version=consent_version,
            consent_at=datetime.now(timezone.utc) if consent_given else None,
        )
        db.add(record)
        await db.commit()
        await db.refresh(record)
        return record

    async def update_status(
        self,
        db: AsyncSession,
        *,
        record: RoleVerification,
        status: VerificationStatus,
        rejection_reason: Optional[str] = None,
    ) -> RoleVerification:
        """Update verification status (used by admin approve/reject)."""
        record.status = status
        if rejection_reason is not None:
            record.rejection_reason = rejection_reason
        if status == VerificationStatus.APPROVED:
            record.verified_at = datetime.now(timezone.utc)
        await db.commit()
        await db.refresh(record)
        return record

    async def resubmit(
        self,
        db: AsyncSession,
        *,
        record: RoleVerification,
        ktp_number: str,
        ktp_photo: str,
        location: str,
    ) -> RoleVerification:
        """Update existing rejected record back to pending for resubmission."""
        record.ktp_number = ktp_number
        record.ktp_photo = ktp_photo
        record.location = location
        record.status = VerificationStatus.PENDING
        record.rejection_reason = None
        record.verified_at = None
        record.submitted_at = datetime.now(timezone.utc)
        await db.commit()
        await db.refresh(record)
        return record

    async def get_approved_roles(
        self, db: AsyncSession, *, user_id: uuid.UUID
    ) -> List[str]:
        """Return list of role_type strings where status=approved for a user."""
        result = await db.execute(
            select(RoleVerification.role_type).where(
                RoleVerification.user_id == user_id,
                RoleVerification.status == VerificationStatus.APPROVED,
            )
        )
        return [row[0].value for row in result.all()]


role_verification_repository = RoleVerificationRepository()
