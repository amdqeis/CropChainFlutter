"""
Authentication Service.
Handles registration, OTP verification, login, token refresh, and password reset.
OTP codes are stored in Redis with TTL and cooldown enforcement.
"""
import uuid
from datetime import datetime, timedelta, timezone

import redis.asyncio as aioredis
from sqlalchemy import select, update
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.config import settings
from app.core.security import (
    create_access_token,
    create_refresh_token,
    decode_token,
    generate_otp,
    generate_reset_token,
    hash_token,
    verify_password,
)
from app.models.user import User
from app.models.platform import RefreshSession
from app.repositories.user import user_repository
from app.schemas.user import TokenPair

# Redis key prefixes
OTP_KEY = "otp:{email}"
OTP_COOLDOWN_KEY = "otp_cooldown:{email}"
RESET_KEY = "reset:{token}"
OTP_ATTEMPTS_KEY = "otp_attempts:{email}"


class AuthService:

    # ─── Registration & OTP ──────────────────────────────────────────────────

    async def register(
        self,
        db: AsyncSession,
        redis: aioredis.Redis,
        *,
        full_name: str,
        email: str,
        password: str,
    ) -> dict:
        """
        Register a new user:
        1. Check email uniqueness
        2. Create unverified user
        3. Generate OTP, store in Redis
        4. Return dev_otp in non-production (skip email send in dev)
        """
        email = email.strip().lower()
        existing = await user_repository.get_by_email(db, email=email)
        if existing:
            raise ValueError("Email sudah terdaftar. Silakan login atau gunakan email lain.")

        await user_repository.create(
            db, full_name=full_name, email=email, password=password
        )

        otp = await self._generate_and_store_otp(redis, email=email)

        # Try to send email; if it fails in dev, just return OTP in response
        try:
            from app.core.email import send_otp_email
            await send_otp_email(email_to=email, otp_code=otp, full_name=full_name)
            dev_otp = None
        except Exception:
            if settings.APP_ENV == "production":
                raise RuntimeError("Pengiriman OTP gagal.")
            dev_otp = otp

        return {
            "message": "Registrasi berhasil. Periksa email Anda untuk kode OTP.",
            "email": email,
            "dev_otp": dev_otp,  # Will be None in production
        }

    async def verify_otp(
        self,
        db: AsyncSession,
        redis: aioredis.Redis,
        *,
        email: str,
        otp_code: str,
    ) -> TokenPair:
        """Verify OTP and activate user account."""
        email = email.strip().lower()
        user = await user_repository.get_by_email(db, email=email)
        if not user:
            raise ValueError("Email tidak ditemukan.")

        if user.is_email_verified:
            raise ValueError("Email sudah diverifikasi sebelumnya.")

        stored_otp = await redis.get(OTP_KEY.format(email=email))
        if not stored_otp:
            raise ValueError("Kode OTP tidak ditemukan atau sudah kedaluwarsa. Minta ulang.")
        if stored_otp != otp_code:
            attempts = await redis.incr(OTP_ATTEMPTS_KEY.format(email=email))
            await redis.expire(OTP_ATTEMPTS_KEY.format(email=email), settings.OTP_EXPIRE_MINUTES * 60)
            if attempts >= settings.OTP_MAX_ATTEMPTS:
                await redis.delete(OTP_KEY.format(email=email))
                raise ValueError("Terlalu banyak percobaan OTP. Minta kode baru.")
            raise ValueError("Kode OTP tidak valid.")

        # Mark user as verified and clear OTP
        await user_repository.update_email_verified(db, user=user, verified=True)
        await redis.delete(OTP_KEY.format(email=email))
        await redis.delete(OTP_ATTEMPTS_KEY.format(email=email))

        return await self._create_token_pair(db, user)

    async def resend_otp(
        self,
        db: AsyncSession,
        redis: aioredis.Redis,
        *,
        email: str,
    ) -> dict:
        """Resend OTP with 60-second cooldown enforcement."""
        email = email.strip().lower()
        user = await user_repository.get_by_email(db, email=email)
        if not user:
            raise ValueError("Email tidak ditemukan.")
        if user.is_email_verified:
            raise ValueError("Email sudah diverifikasi.")

        # Check cooldown
        cooldown = await redis.get(OTP_COOLDOWN_KEY.format(email=email))
        if cooldown:
            raise ValueError(
                f"Harap tunggu {settings.OTP_RESEND_COOLDOWN_SECONDS} detik "
                "sebelum meminta kode OTP baru."
            )

        otp = await self._generate_and_store_otp(redis, email=email)

        try:
            from app.core.email import send_otp_email
            await send_otp_email(email_to=email, otp_code=otp, full_name=user.full_name)
            dev_otp = None
        except Exception:
            if settings.APP_ENV == "production":
                raise RuntimeError("Pengiriman OTP gagal.")
            dev_otp = otp

        return {
            "message": "Kode OTP baru telah dikirim ke email Anda.",
            "dev_otp": dev_otp,
        }

    # ─── Login & Token ────────────────────────────────────────────────────────

    async def login(
        self,
        db: AsyncSession,
        *,
        email: str,
        password: str,
    ) -> TokenPair:
        """Authenticate user and return JWT token pair."""
        email = email.strip().lower()
        user = await user_repository.get_by_email(db, email=email)
        if not user or not verify_password(password, user.password_hash):
            raise ValueError("Email atau password salah.")

        if not user.is_email_verified:
            raise ValueError(
                "Email belum diverifikasi. Silakan verifikasi email Anda terlebih dahulu."
            )

        return await self._create_token_pair(db, user)

    async def refresh_token(self, db: AsyncSession, *, refresh_token: str) -> TokenPair:
        """Validate refresh token and issue new token pair."""
        payload = decode_token(refresh_token)
        if not payload or payload.get("type") != "refresh":
            raise ValueError("Refresh token tidak valid atau sudah kedaluwarsa.")

        user_id = uuid.UUID(payload.get("sub"))
        user = await user_repository.get_by_id(db, user_id=user_id)
        if not user:
            raise ValueError("User tidak ditemukan.")

        token_hash = hash_token(refresh_token)
        result = await db.execute(
            select(RefreshSession).where(
                RefreshSession.token_hash == token_hash,
                RefreshSession.revoked_at.is_(None),
                RefreshSession.expires_at > datetime.now(timezone.utc),
            ).with_for_update()
        )
        session = result.scalar_one_or_none()
        if not session:
            raise ValueError("Refresh token sudah dicabut atau tidak dikenal.")
        session.revoked_at = datetime.now(timezone.utc)
        pair = await self._create_token_pair(db, user)
        replacement = await db.execute(select(RefreshSession).where(RefreshSession.token_hash == hash_token(pair.refresh_token)))
        session.replaced_by_id = replacement.scalar_one().id
        await db.commit()
        return pair

    # ─── Password Reset ───────────────────────────────────────────────────────

    async def request_password_reset(
        self,
        db: AsyncSession,
        redis: aioredis.Redis,
        *,
        email: str,
    ) -> dict:
        """Send password reset email. Does not reveal if email exists (security)."""
        user = await user_repository.get_by_email(db, email=email)
        if user:
            token = generate_reset_token()
            # Store token in Redis for 30 minutes
            await redis.setex(RESET_KEY.format(token=token), 1800, str(user.id))
            try:
                from app.core.email import send_password_reset_email
                await send_password_reset_email(
                    email_to=email, reset_token=token, full_name=user.full_name
                )
            except Exception:
                pass  # Silent fail — don't reveal server errors

        return {
            "message": (
                "Jika email terdaftar, link reset password telah dikirim. "
                "Periksa kotak masuk email Anda."
            )
        }

    async def confirm_password_reset(
        self,
        db: AsyncSession,
        redis: aioredis.Redis,
        *,
        token: str,
        new_password: str,
    ) -> dict:
        """Verify reset token and update password."""
        user_id = await redis.get(RESET_KEY.format(token=token))
        if not user_id:
            raise ValueError("Token reset password tidak valid atau sudah kedaluwarsa.")

        user = await user_repository.get_by_id(db, user_id=user_id)
        if not user:
            raise ValueError("User tidak ditemukan.")

        await user_repository.update_password(db, user=user, new_password=new_password)
        await db.execute(
            update(RefreshSession)
            .where(RefreshSession.user_id == user.id, RefreshSession.revoked_at.is_(None))
            .values(revoked_at=datetime.now(timezone.utc))
        )
        await db.commit()
        await redis.delete(RESET_KEY.format(token=token))

        return {"message": "Password berhasil diubah. Silakan login kembali."}

    # ─── Helpers ──────────────────────────────────────────────────────────────

    async def _generate_and_store_otp(
        self, redis: aioredis.Redis, *, email: str
    ) -> str:
        """Generate OTP, store in Redis with TTL, set cooldown key."""
        otp = generate_otp()
        ttl_seconds = settings.OTP_EXPIRE_MINUTES * 60

        await redis.setex(OTP_KEY.format(email=email), ttl_seconds, otp)
        await redis.setex(
            OTP_COOLDOWN_KEY.format(email=email),
            settings.OTP_RESEND_COOLDOWN_SECONDS,
            "1",
        )
        return otp

    async def _create_token_pair(self, db: AsyncSession, user: User) -> TokenPair:
        access_token = create_access_token(subject=str(user.id))
        refresh_token = create_refresh_token(subject=str(user.id))
        db.add(RefreshSession(
            user_id=user.id,
            token_hash=hash_token(refresh_token),
            expires_at=datetime.now(timezone.utc) + timedelta(days=settings.REFRESH_TOKEN_EXPIRE_DAYS),
        ))
        await db.commit()
        return TokenPair(access_token=access_token, refresh_token=refresh_token)


auth_service = AuthService()
