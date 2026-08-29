from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from fastapi.responses import JSONResponse
from sqlalchemy import text
import os
from contextlib import asynccontextmanager

from app.api.v1.api import api_router
from app.core.config import settings
from app.core.database import close_redis
from app.core.database import AsyncSessionLocal, get_redis
from app.core.middleware import SensitiveRateLimitMiddleware

settings.validate_provider_configuration()


@asynccontextmanager
async def lifespan(_: FastAPI):
    yield
    await close_redis()

# ─── App Initialization ───────────────────────────────────────────────────────
app = FastAPI(
    title=settings.PROJECT_NAME,
    description=(
        "**CropChain API** — Digitalisasi rantai distribusi hasil pertanian.\n\n"
        "**Alur Bisnis**: Petani → Offer → Distributor → Stock → Product → Pembeli → Order → Payment\n\n"
        "**Autentikasi**: Bearer JWT (access token dari `/api/v1/auth/login`)"
    ),
    version="1.0.0",
    openapi_url=f"{settings.API_V1_STR}/openapi.json",
    docs_url="/docs",
    redoc_url="/redoc",
    lifespan=lifespan,
)

# ─── CORS Middleware ──────────────────────────────────────────────────────────
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origins,
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)
app.add_middleware(SensitiveRateLimitMiddleware)

# ─── Static Files (Local Media Uploads) ──────────────────────────────────────
media_dir = settings.UPLOAD_DIR
os.makedirs(media_dir, exist_ok=True)
app.mount(f"/{media_dir}", StaticFiles(directory=media_dir), name="media")

# ─── API Routes ───────────────────────────────────────────────────────────────
app.include_router(api_router, prefix=settings.API_V1_STR)

# ─── Health Check ─────────────────────────────────────────────────────────────

@app.get("/", tags=["⚙️ System"])
async def root():
    """Root endpoint — API health check."""
    return {
        "status": "online",
        "project": settings.PROJECT_NAME,
        "version": "1.0.0",
        "docs": "/docs",
        "redoc": "/redoc",
    }


@app.get("/health", tags=["⚙️ System"])
async def health_check():
    """Detailed health check for monitoring."""
    checks = {"database": "down", "redis": "down", "worker": "down"}
    try:
        async with AsyncSessionLocal() as db:
            await db.execute(text("SELECT 1"))
        checks["database"] = "up"
    except Exception:
        pass
    try:
        redis = await get_redis()
        await redis.ping()
        checks["redis"] = "up"
        if await redis.get("cropchain:worker:heartbeat"):
            checks["worker"] = "up"
    except Exception:
        pass
    healthy = all(value == "up" for value in checks.values())
    return JSONResponse({"status": "healthy" if healthy else "degraded", **checks}, status_code=200 if healthy else 503)
