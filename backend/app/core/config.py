from typing import List, Literal, Optional
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        extra="ignore"
    )

    PROJECT_NAME: str = "CropChain API"
    API_V1_STR: str = "/api/v1"
    APP_ENV: Literal["development", "test", "production"] = "development"
    CORS_ORIGINS: str = "http://localhost:3000,http://localhost:8080"

    # Security
    SECRET_KEY: str = "supersecretjwtkeythatshouldbechangedinproduction12345"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60           # 1 hour
    REFRESH_TOKEN_EXPIRE_DAYS: int = 30             # 30 days
    KTP_ENCRYPTION_KEY: str = ""
    DEMO_API_KEY: str = "cropchain-demo-only"
    OTP_MAX_ATTEMPTS: int = 5

    # PostgreSQL Database
    POSTGRES_SERVER: str = "localhost"
    POSTGRES_PORT: int = 5432
    POSTGRES_USER: str = "postgres"
    POSTGRES_PASSWORD: str = "postgres"
    POSTGRES_DB: str = "cropchain"

    DATABASE_URL: Optional[str] = None

    # Redis
    REDIS_URL: str = "redis://localhost:6379/0"

    # OTP Settings
    OTP_EXPIRE_MINUTES: int = 5
    OTP_RESEND_COOLDOWN_SECONDS: int = 60

    # Midtrans Payment Gateway
    MIDTRANS_MERCHANT_ID: str = ""
    MIDTRANS_CLIENT_KEY: str = ""
    MIDTRANS_SERVER_KEY: str = ""
    MIDTRANS_IS_PRODUCTION: bool = False

    # Email (fastapi-mail)
    MAIL_USERNAME: str = ""
    MAIL_PASSWORD: str = ""
    MAIL_FROM: str = "noreply@cropchain.id"
    MAIL_PORT: int = 587
    MAIL_SERVER: str = "smtp.gmail.com"
    MAIL_FROM_NAME: str = "CropChain"
    MAIL_STARTTLS: bool = True
    MAIL_SSL_TLS: bool = False

    # File Upload
    UPLOAD_DIR: str = "media"
    PRIVATE_UPLOAD_DIR: str = ".private_media"
    MAX_UPLOAD_SIZE_MB: int = 5

    # Platform Fee
    PLATFORM_FEE_PERCENTAGE: float = 2.5
    CHECKOUT_RESERVATION_MINUTES: int = 15
    DISPUTE_WINDOW_DAYS: int = 7

    PAYMENT_PROVIDER: Literal["fake", "midtrans"] = "fake"
    SHIPPING_PROVIDER: Literal["fake", "shipper"] = "fake"
    STORAGE_PROVIDER: Literal["local", "cloudinary"] = "local"
    NOTIFICATION_PROVIDER: Literal["fake", "fcm"] = "fake"
    MAPS_PROVIDER: Literal["fake", "google"] = "fake"
    SHIPPER_API_KEY: str = ""
    SHIPPER_BASE_URL: str = "https://merchant-api-sandbox.shipper.id"
    CLOUDINARY_URL: str = ""
    GOOGLE_MAPS_API_KEY: str = ""
    FCM_CREDENTIALS_PATH: str = ""
    CELERY_BROKER_URL: Optional[str] = None

    @property
    def cors_origins(self) -> List[str]:
        return [origin.strip() for origin in self.CORS_ORIGINS.split(",") if origin.strip()]

    def validate_provider_configuration(self) -> None:
        required = {
            "midtrans": (self.PAYMENT_PROVIDER, self.MIDTRANS_SERVER_KEY),
            "shipper": (self.SHIPPING_PROVIDER, self.SHIPPER_API_KEY),
            "cloudinary": (self.STORAGE_PROVIDER, self.CLOUDINARY_URL),
            "google": (self.MAPS_PROVIDER, self.GOOGLE_MAPS_API_KEY),
            "fcm": (self.NOTIFICATION_PROVIDER, self.FCM_CREDENTIALS_PATH),
        }
        missing = [name for name, (selected, credential) in required.items() if selected == name and not credential]
        if missing:
            raise RuntimeError(f"Provider dipilih tetapi credential belum diatur: {', '.join(missing)}")
        if self.APP_ENV == "production":
            if self.SECRET_KEY.startswith("supersecretjwtkey") or len(self.SECRET_KEY) < 32:
                raise RuntimeError("SECRET_KEY production wajib unik dan minimal 32 karakter.")
            if not self.KTP_ENCRYPTION_KEY or len(self.KTP_ENCRYPTION_KEY) < 32:
                raise RuntimeError("KTP_ENCRYPTION_KEY production wajib unik dan minimal 32 karakter.")
            if "localhost" in self.CORS_ORIGINS or "*" in self.CORS_ORIGINS:
                raise RuntimeError("CORS_ORIGINS production tidak boleh wildcard/localhost.")

    def get_database_url(self) -> str:
        if self.DATABASE_URL:
            return self.DATABASE_URL
        return (
            f"postgresql+asyncpg://{self.POSTGRES_USER}:{self.POSTGRES_PASSWORD}"
            f"@{self.POSTGRES_SERVER}:{self.POSTGRES_PORT}/{self.POSTGRES_DB}"
        )


settings = Settings()
