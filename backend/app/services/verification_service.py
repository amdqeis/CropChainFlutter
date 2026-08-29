"""
Verification Service.
Handles role verification submission, resubmission, and role switching.
"""
import uuid
from typing import List

from sqlalchemy.ext.asyncio import AsyncSession

from app.models.role_verification import RoleType, VerificationStatus
from app.models.user import ActiveRole, User
from app.core.security import encrypt_sensitive, mask_nik
from app.repositories.role_verification import role_verification_repository
from app.repositories.user import user_repository
from app.schemas.role_verification import (
    RoleVerificationCreate,
    RoleVerificationResponse,
    RoleVerificationStatusResponse,
)


class VerificationService:

    async def submit_verification(
        self,
        db: AsyncSession,
        *,
        user: User,
        data: RoleVerificationCreate,
    ) -> RoleVerificationResponse:
        """
        Submit a new role verification request.
        If a previous record exists for this role:
        - If 'rejected' → resubmit (update to pending)
        - If 'pending' or 'approved' → raise error
        """
        if not data.consent_given:
            raise ValueError("Persetujuan pemrosesan data KTP wajib diberikan.")
        if not data.ktp_photo.startswith(("private://", "cloudinary://")):
            raise ValueError("KTP wajib menggunakan referensi privat dari endpoint /uploads/ktp.")

        existing = await role_verification_repository.get_by_user_and_role(
            db, user_id=user.id, role_type=data.role_type
        )

        if existing:
            if existing.status == VerificationStatus.PENDING:
                raise ValueError(
                    "Pengajuan verifikasi sudah ada dan sedang diproses. Harap tunggu."
                )
            if existing.status == VerificationStatus.APPROVED:
                raise ValueError(
                    f"Role {data.role_type.value} sudah terverifikasi."
                )
            # Keep the rejected revision for audit and create a new submission.
            record = await role_verification_repository.create(
                db, user_id=user.id, role_type=data.role_type,
                ktp_number=encrypt_sensitive(data.ktp_number),
                ktp_photo=data.ktp_photo, location=data.location,
                consent_given=data.consent_given, consent_version=data.consent_version,
            )
        else:
            record = await role_verification_repository.create(
                db,
                user_id=user.id,
                role_type=data.role_type,
                ktp_number=encrypt_sensitive(data.ktp_number),
                ktp_photo=data.ktp_photo,
                location=data.location,
                consent_given=data.consent_given,
                consent_version=data.consent_version,
            )
        response = RoleVerificationResponse.model_validate(record)
        response.ktp_number = mask_nik(record.ktp_number)
        return response

    async def get_all_verification_statuses(
        self, db: AsyncSession, *, user: User
    ) -> List[RoleVerificationStatusResponse]:
        """Return verification status for all roles this user has applied for."""
        records = await role_verification_repository.get_all_by_user(
            db, user_id=user.id
        )
        latest = {}
        for record in records:
            latest.setdefault(record.role_type, record)
        return [
            RoleVerificationStatusResponse(
                role_type=r.role_type,
                status=r.status,
                rejection_reason=r.rejection_reason,
                submitted_at=r.submitted_at,
            )
            for r in latest.values()
        ]

    async def get_approved_roles(
        self, db: AsyncSession, *, user_id: uuid.UUID
    ) -> List[str]:
        """Return list of approved role names for a user."""
        return await role_verification_repository.get_approved_roles(
            db, user_id=user_id
        )

    async def switch_role(
        self,
        db: AsyncSession,
        *,
        user: User,
        new_role: ActiveRole,
    ) -> User:
        """
        Switch active_role. Validates:
        - 'pembeli' is always allowed (no verification needed)
        - 'petani'/'distributor' requires approved verification
        """
        if new_role == ActiveRole.PEMBELI:
            return await user_repository.switch_active_role(
                db, user=user, new_role=new_role
            )

        role_type = RoleType(new_role.value)
        verification = await role_verification_repository.get_by_user_and_role(
            db, user_id=user.id, role_type=role_type
        )

        if not verification or verification.status != VerificationStatus.APPROVED:
            raise ValueError(
                f"Role {new_role.value} belum terverifikasi. "
                "Ajukan verifikasi terlebih dahulu."
            )

        return await user_repository.switch_active_role(
            db, user=user, new_role=new_role
        )


verification_service = VerificationService()
