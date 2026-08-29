"""
FastAPI dependency injection utilities.
Provides: DB session, Redis client, current user, role-based access guards.
"""
import uuid
from typing import Annotated

import redis.asyncio as aioredis
from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db, get_redis
from app.core.security import decode_token
from app.models.role_verification import RoleType, VerificationStatus
from app.models.user import ActiveRole, User
from app.repositories.role_verification import role_verification_repository
from app.repositories.user import user_repository

# OAuth2 scheme — token URL is the login endpoint
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/api/v1/auth/login")


# ─── Database & Redis ────────────────────────────────────────────────────────

async def get_db_session() -> AsyncSession:
    async for session in get_db():
        yield session


async def get_redis_client() -> aioredis.Redis:
    return await get_redis()


# ─── Current User ─────────────────────────────────────────────────────────────

async def get_current_user(
    token: Annotated[str, Depends(oauth2_scheme)],
    db: AsyncSession = Depends(get_db_session),
) -> User:
    """
    Decode JWT access token and return the corresponding User object.
    Raises 401 if token is invalid or user not found.
    """
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Token tidak valid atau sudah kedaluwarsa. Silakan login ulang.",
        headers={"WWW-Authenticate": "Bearer"},
    )

    payload = decode_token(token)
    if payload is None or payload.get("type") != "access":
        raise credentials_exception

    user_id_str: str = payload.get("sub")
    if not user_id_str:
        raise credentials_exception

    try:
        user_id = uuid.UUID(user_id_str)
    except ValueError:
        raise credentials_exception

    user = await user_repository.get_by_id(db, user_id=user_id)
    if not user:
        raise credentials_exception

    return user


async def get_current_verified_user(
    current_user: User = Depends(get_current_user),
) -> User:
    """Ensure the current user has verified their email."""
    if not current_user.is_email_verified:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Email belum diverifikasi. Periksa email Anda untuk kode OTP.",
        )
    return current_user


# ─── Role Guards ──────────────────────────────────────────────────────────────

def require_role(role: ActiveRole):
    """
    Dependency factory that ensures the current user's active_role matches
    the required role. For petani/distributor roles, also verifies approval.
    """
    async def _role_guard(
        current_user: User = Depends(get_current_verified_user),
        db: AsyncSession = Depends(get_db_session),
    ) -> User:
        if current_user.active_role != role:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=(
                    f"Akses ditolak. Role aktif Anda adalah '{current_user.active_role.value}', "
                    f"tapi endpoint ini memerlukan role '{role.value}'. "
                    f"Pindahkan role Anda di halaman Profil."
                ),
            )

        # Pembeli is always available without verification
        if role == ActiveRole.PEMBELI:
            return current_user

        # Petani / Distributor: must have approved verification
        role_type = RoleType(role.value)
        verification = await role_verification_repository.get_by_user_and_role(
            db, user_id=current_user.id, role_type=role_type
        )
        if not verification or verification.status != VerificationStatus.APPROVED:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=(
                    f"Role '{role.value}' belum terverifikasi. "
                    "Ajukan verifikasi di halaman Profil."
                ),
            )
        return current_user

    return _role_guard


# ─── Convenience Aliases ──────────────────────────────────────────────────────

require_petani = require_role(ActiveRole.PETANI)
require_distributor = require_role(ActiveRole.DISTRIBUTOR)
require_pembeli = require_role(ActiveRole.PEMBELI)


async def require_admin(
    current_user: User = Depends(get_current_verified_user),
) -> User:
    if not current_user.is_admin:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Akses admin diperlukan.")
    return current_user
