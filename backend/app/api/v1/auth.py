"""
Authentication Router.
Endpoints: register, verify-otp, resend-otp, login, refresh, forgot-password, reset-password
"""
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
import redis.asyncio as aioredis

from app.api.deps import get_db_session, get_redis_client, get_current_verified_user
from app.models.user import User
from app.schemas.user import (
    OTPResend,
    OTPVerify,
    PasswordResetConfirm,
    PasswordResetRequest,
    TokenPair,
    TokenRefreshRequest,
    UserRegister,
    UserResponse,
)
from app.services.auth_service import auth_service
from app.repositories.role_verification import role_verification_repository

router = APIRouter()


@router.post("/register", status_code=status.HTTP_201_CREATED)
async def register(
    data: UserRegister,
    db: AsyncSession = Depends(get_db_session),
    redis: aioredis.Redis = Depends(get_redis_client),
):
    """
    **Sign Up** — Buat akun baru.
    Sistem akan mengirimkan kode OTP 6 digit ke email Anda.
    """
    try:
        return await auth_service.register(
            db, redis, full_name=data.full_name, email=data.email, password=data.password
        )
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))


@router.post("/verify-otp", response_model=TokenPair)
async def verify_otp(
    data: OTPVerify,
    db: AsyncSession = Depends(get_db_session),
    redis: aioredis.Redis = Depends(get_redis_client),
):
    """
    **Verifikasi OTP** — Masukkan kode OTP yang dikirim ke email.
    Jika berhasil, mengembalikan access token + refresh token.
    """
    try:
        return await auth_service.verify_otp(
            db, redis, email=data.email, otp_code=data.otp_code
        )
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))


@router.post("/resend-otp")
async def resend_otp(
    data: OTPResend,
    db: AsyncSession = Depends(get_db_session),
    redis: aioredis.Redis = Depends(get_redis_client),
):
    """
    **Kirim Ulang OTP** — Cooldown 60 detik setelah permintaan terakhir.
    """
    try:
        return await auth_service.resend_otp(db, redis, email=data.email)
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_429_TOO_MANY_REQUESTS, detail=str(e))


@router.post("/login", response_model=TokenPair)
async def login(
    data: "UserLoginSchema",
    db: AsyncSession = Depends(get_db_session),
):
    """
    **Login** — Autentikasi dengan email dan password.
    Mengembalikan JWT access token (1 jam) + refresh token (30 hari).
    """
    try:
        return await auth_service.login(db, email=data.email, password=data.password)
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail=str(e))


from app.schemas.user import UserLogin as UserLoginSchema  # noqa: E402


@router.post("/refresh", response_model=TokenPair)
async def refresh_token(
    data: TokenRefreshRequest,
    db: AsyncSession = Depends(get_db_session),
):
    """
    **Refresh Token** — Tukar refresh token dengan access token baru.
    """
    try:
        return await auth_service.refresh_token(db, refresh_token=data.refresh_token)
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail=str(e))


@router.post("/forgot-password")
async def forgot_password(
    data: PasswordResetRequest,
    db: AsyncSession = Depends(get_db_session),
    redis: aioredis.Redis = Depends(get_redis_client),
):
    """
    **Lupa Password** — Kirim link/kode reset ke email terdaftar.
    """
    return await auth_service.request_password_reset(
        db, redis, email=data.email
    )


@router.post("/reset-password")
async def reset_password(
    data: PasswordResetConfirm,
    db: AsyncSession = Depends(get_db_session),
    redis: aioredis.Redis = Depends(get_redis_client),
):
    """
    **Reset Password** — Konfirmasi token dan set password baru.
    """
    try:
        return await auth_service.confirm_password_reset(
            db, redis, token=data.token, new_password=data.new_password
        )
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))


@router.get("/me", response_model=UserResponse)
async def get_me(
    current_user: User = Depends(get_current_verified_user),
    db: AsyncSession = Depends(get_db_session),
):
    """**Profil Saya** — Mengembalikan data user yang sedang login."""
    approved_roles = await role_verification_repository.get_approved_roles(
        db, user_id=current_user.id
    )
    resp = UserResponse.model_validate(current_user)
    resp.verified_roles = approved_roles
    return resp
