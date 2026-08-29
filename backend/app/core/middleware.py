"""Small Redis-backed rate limiter for sensitive prototype endpoints."""
import time

from starlette.middleware.base import BaseHTTPMiddleware
from starlette.requests import Request
from starlette.responses import JSONResponse

from app.core.database import get_redis


class SensitiveRateLimitMiddleware(BaseHTTPMiddleware):
    LIMITS = {
        "/api/v1/auth/login": 10,
        "/api/v1/auth/register": 10,
        "/api/v1/auth/forgot-password": 5,
        "/api/v1/auth/resend-otp": 5,
    }

    async def dispatch(self, request: Request, call_next):
        limit = self.LIMITS.get(request.url.path)
        if not limit:
            return await call_next(request)
        client = request.client.host if request.client else "unknown"
        window = int(time.time() // 60)
        key = f"rate:{request.url.path}:{client}:{window}"
        try:
            redis = await get_redis()
            count = await redis.incr(key)
            if count == 1:
                await redis.expire(key, 61)
            if count > limit:
                return JSONResponse({"detail": "Terlalu banyak permintaan. Coba lagi nanti."}, status_code=429)
        except Exception:
            pass
        return await call_next(request)
