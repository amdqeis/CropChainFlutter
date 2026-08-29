"""Minimal prototype administration API."""
import uuid
from typing import Optional

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_db_session, require_admin
from app.core.security import mask_nik
from app.models.role_verification import RoleVerification, VerificationStatus
from app.models.user import User
from app.repositories.role_verification import role_verification_repository
from app.schemas.admin import AdminUserResponse, AdminVerificationResponse, VerificationDecision
from app.services.platform_service import audit, notify

router = APIRouter()


def _verification_response(record: RoleVerification) -> AdminVerificationResponse:
    return AdminVerificationResponse(
        id=record.id, user_id=record.user_id, role_type=record.role_type,
        status=record.status, ktp_number_masked=mask_nik(record.ktp_number),
        ktp_photo=record.ktp_photo, location=record.location,
        consent_given=record.consent_given, consent_version=record.consent_version,
        submitted_at=record.submitted_at, rejection_reason=record.rejection_reason,
    )


@router.get("/verifications", response_model=list[AdminVerificationResponse])
async def list_verifications(
    status_filter: Optional[VerificationStatus] = Query(None, alias="status"),
    skip: int = Query(0, ge=0), limit: int = Query(50, ge=1, le=100),
    db: AsyncSession = Depends(get_db_session), _: User = Depends(require_admin),
):
    query = select(RoleVerification)
    if status_filter:
        query = query.where(RoleVerification.status == status_filter)
    result = await db.execute(query.order_by(RoleVerification.submitted_at.desc(), RoleVerification.id).offset(skip).limit(limit))
    return [_verification_response(item) for item in result.scalars()]


@router.patch("/verifications/{verification_id}", response_model=AdminVerificationResponse)
async def decide_verification(
    verification_id: uuid.UUID, data: VerificationDecision,
    db: AsyncSession = Depends(get_db_session), admin: User = Depends(require_admin),
):
    if data.status not in {VerificationStatus.APPROVED, VerificationStatus.REJECTED}:
        raise HTTPException(422, "Admin hanya dapat approve atau reject.")
    if data.status == VerificationStatus.REJECTED and not data.rejection_reason:
        raise HTTPException(422, "Alasan penolakan wajib diisi.")
    record = await db.get(RoleVerification, verification_id)
    if not record:
        raise HTTPException(404, "Pengajuan tidak ditemukan.")
    record = await role_verification_repository.update_status(
        db, record=record, status=data.status, rejection_reason=data.rejection_reason
    )
    await audit(db, action=f"verification.{data.status.value}", entity_type="role_verification", entity_id=record.id, actor_id=admin.id)
    await notify(db, user_id=record.user_id, kind="verification", title="Status verifikasi diperbarui", body=f"Pengajuan {record.role_type.value}: {record.status.value}")
    await db.commit()
    return _verification_response(record)


@router.get("/users", response_model=list[AdminUserResponse])
async def list_users(
    skip: int = Query(0, ge=0), limit: int = Query(50, ge=1, le=100),
    db: AsyncSession = Depends(get_db_session), _: User = Depends(require_admin),
):
    result = await db.execute(select(User).order_by(User.created_at.desc(), User.id).offset(skip).limit(limit))
    return [AdminUserResponse.model_validate(user) for user in result.scalars()]
