import string
import base64
import hashlib
import secrets
from datetime import datetime, timedelta, timezone
from typing import Any, Optional, Union

from jose import JWTError, jwt
import bcrypt

from app.core.config import settings
from cryptography.fernet import Fernet

def verify_password(plain_password: str, hashed_password: str) -> bool:
    """Verify password plain text against hashed database value."""
    try:
        return bcrypt.checkpw(plain_password.encode(), hashed_password.encode())
    except ValueError:
        return False


def get_password_hash(password: str) -> str:
    """Hash password using bcrypt."""
    encoded = password.encode()
    if len(encoded) > 72:
        raise ValueError("Password terlalu panjang; maksimum 72 byte untuk bcrypt.")
    return bcrypt.hashpw(encoded, bcrypt.gensalt(rounds=12)).decode()


def create_access_token(
    subject: Union[str, Any],
    expires_delta: Optional[timedelta] = None
) -> str:
    """Generate JWT access token for authentication session."""
    if expires_delta:
        expire = datetime.now(timezone.utc) + expires_delta
    else:
        expire = datetime.now(timezone.utc) + timedelta(
            minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES
        )

    to_encode = {
        "exp": expire,
        "sub": str(subject),
        "type": "access"
    }
    return jwt.encode(to_encode, settings.SECRET_KEY, algorithm=settings.ALGORITHM)


def create_refresh_token(
    subject: Union[str, Any],
    expires_delta: Optional[timedelta] = None
) -> str:
    """Generate JWT refresh token with longer expiry."""
    if expires_delta:
        expire = datetime.now(timezone.utc) + expires_delta
    else:
        expire = datetime.now(timezone.utc) + timedelta(
            days=settings.REFRESH_TOKEN_EXPIRE_DAYS
        )

    to_encode = {
        "exp": expire,
        "sub": str(subject),
        "type": "refresh"
    }
    return jwt.encode(to_encode, settings.SECRET_KEY, algorithm=settings.ALGORITHM)


def decode_token(token: str) -> Optional[dict]:
    """
    Decode a JWT token and return its payload.
    Returns None if the token is invalid or expired.
    """
    try:
        payload = jwt.decode(
            token,
            settings.SECRET_KEY,
            algorithms=[settings.ALGORITHM]
        )
        return payload
    except JWTError:
        return None


def generate_otp(length: int = 6) -> str:
    """Generate a numeric OTP code of specified length."""
    return "".join(secrets.choice(string.digits) for _ in range(length))


def generate_reset_token() -> str:
    """Generate a secure random token for password reset."""
    return secrets.token_urlsafe(48)


def hash_token(token: str) -> str:
    return hashlib.sha256(token.encode()).hexdigest()


def _fernet() -> Fernet:
    raw = settings.KTP_ENCRYPTION_KEY or settings.SECRET_KEY
    key = base64.urlsafe_b64encode(hashlib.sha256(raw.encode()).digest())
    return Fernet(key)


def encrypt_sensitive(value: str) -> str:
    return _fernet().encrypt(value.encode()).decode()


def decrypt_sensitive(value: str) -> str:
    return _fernet().decrypt(value.encode()).decode()


def mask_nik(value: str) -> str:
    try:
        plain = decrypt_sensitive(value)
    except Exception:
        plain = value
    return f"************{plain[-4:]}" if len(plain) >= 4 else "****"
