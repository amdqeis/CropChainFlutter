from sqlalchemy.ext.asyncio import AsyncSession, async_sessionmaker, create_async_engine
from sqlalchemy.orm import DeclarativeBase
import redis.asyncio as aioredis

from app.core.config import settings

# Create async engine
engine = create_async_engine(
    settings.get_database_url(),
    echo=False,            # Set True in dev for SQL logging
    pool_pre_ping=True,    # Verify connection liveness before using
    pool_size=10,
    max_overflow=20,
)

# Async session factory
AsyncSessionLocal = async_sessionmaker(
    bind=engine,
    class_=AsyncSession,
    autocommit=False,
    autoflush=False,
    expire_on_commit=False,
)


class Base(DeclarativeBase):
    """Base class for all SQLAlchemy ORM models."""
    pass


async def get_db() -> AsyncSession:
    """
    FastAPI dependency that yields an async database session
    and ensures it is properly closed after each request.
    """
    async with AsyncSessionLocal() as session:
        try:
            yield session
        finally:
            await session.close()


# ─── Redis Client ────────────────────────────────────────────────────────────
_redis_client: aioredis.Redis | None = None


async def get_redis() -> aioredis.Redis:
    """
    FastAPI dependency that returns a shared async Redis client.
    Used for OTP storage, rate-limiting, and caching.
    """
    global _redis_client
    if _redis_client is None:
        _redis_client = aioredis.from_url(
            settings.REDIS_URL,
            encoding="utf-8",
            decode_responses=True,
        )
    return _redis_client


async def close_redis() -> None:
    """Close the Redis connection on application shutdown."""
    global _redis_client
    if _redis_client is not None:
        await _redis_client.aclose()
        _redis_client = None
