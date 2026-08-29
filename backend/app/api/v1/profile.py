"""
Profile Router.
Endpoints: view profile, update profile, verifications, role switch.
"""
from typing import List

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_current_verified_user, get_db_session
from app.models.user import User
from app.schemas.role_verification import RoleVerificationCreate, RoleVerificationResponse, RoleVerificationStatusResponse
from app.schemas.user import ActiveRoleSwitch, UserResponse, UserUpdate
from app.repositories.role_verification import role_verification_repository
from app.repositories.user import user_repository
from app.services.verification_service import verification_service

router = APIRouter()


@router.get("/me", response_model=UserResponse)
async def get_profile(
    current_user: User = Depends(get_current_verified_user),
    db: AsyncSession = Depends(get_db_session),
):
    """Get current user profile with list of verified roles."""
    approved_roles = await role_verification_repository.get_approved_roles(
        db, user_id=current_user.id
    )
    resp = UserResponse.model_validate(current_user)
    resp.verified_roles = approved_roles
    return resp


@router.patch("/me", response_model=UserResponse)
async def update_profile(
    data: UserUpdate,
    current_user: User = Depends(get_current_verified_user),
    db: AsyncSession = Depends(get_db_session),
):
    """Update profile info (currently: full_name only)."""
    updated = await user_repository.update_profile(
        db, user=current_user, full_name=data.full_name
    )
    resp = UserResponse.model_validate(updated)
    return resp


@router.get("/verifications", response_model=List[RoleVerificationStatusResponse])
async def get_verification_statuses(
    current_user: User = Depends(get_current_verified_user),
    db: AsyncSession = Depends(get_db_session),
):
    """
    Get verification status for all roles this user has applied for.
    Used to render the role-switcher tabs on the Profile page.
    """
    return await verification_service.get_all_verification_statuses(
        db, user=current_user
    )


@router.post("/verifications", response_model=RoleVerificationResponse, status_code=status.HTTP_201_CREATED)
async def submit_verification(
    data: RoleVerificationCreate,
    current_user: User = Depends(get_current_verified_user),
    db: AsyncSession = Depends(get_db_session),
):
    """
    **Ajukan Verifikasi Role** (Petani / Distributor).
    - If no prior record → creates new pending record.
    - If status is 'rejected' → resubmits (updates to pending).
    - If status is 'pending' or 'approved' → raises error.
    """
    try:
        return await verification_service.submit_verification(
            db, user=current_user, data=data
        )
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))


@router.patch("/active-role", response_model=UserResponse)
async def switch_active_role(
    data: ActiveRoleSwitch,
    current_user: User = Depends(get_current_verified_user),
    db: AsyncSession = Depends(get_db_session),
):
    """
    **Ganti Role Aktif**.
    - 'pembeli' → always allowed.
    - 'petani'/'distributor' → requires approved verification.
    """
    try:
        updated = await verification_service.switch_role(
            db, user=current_user, new_role=data.new_role
        )
        resp = UserResponse.model_validate(updated)
        return resp
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail=str(e))
