"""Price observation and prototype model registry."""
import enum
import uuid
from datetime import date, datetime
from typing import Optional

from sqlalchemy import Boolean, Date, DateTime, Enum, ForeignKey, Integer, Numeric, String, UniqueConstraint
from sqlalchemy.dialects.postgresql import JSONB, UUID
from sqlalchemy.orm import Mapped, mapped_column

from app.core.database import Base
from app.models.base import TimestampMixin, enum_values


class TrainingStatus(str, enum.Enum):
    PENDING = "pending"
    RUNNING = "running"
    SUCCEEDED = "succeeded"
    FAILED = "failed"


class MarketPriceObservation(Base, TimestampMixin):
    __tablename__ = "market_price_observations"
    __table_args__ = (UniqueConstraint("observed_at", "commodity", "district", "source", name="uq_price_observation"),)
    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    observed_at: Mapped[date] = mapped_column(Date, nullable=False, index=True)
    commodity: Mapped[str] = mapped_column(String(150), nullable=False, index=True)
    district: Mapped[str] = mapped_column(String(150), nullable=False, index=True)
    price_per_kg: Mapped[float] = mapped_column(Numeric(15, 2), nullable=False)
    source: Mapped[str] = mapped_column(String(150), nullable=False)
    volume_kg: Mapped[Optional[float]] = mapped_column(Numeric(15, 2), nullable=True)
    is_synthetic: Mapped[bool] = mapped_column(Boolean, default=False, nullable=False)


class ModelVersion(Base, TimestampMixin):
    __tablename__ = "model_versions"
    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    version: Mapped[str] = mapped_column(String(100), unique=True, nullable=False)
    algorithm: Mapped[str] = mapped_column(String(100), nullable=False)
    artifact_path: Mapped[str] = mapped_column(String(1000), nullable=False)
    metrics: Mapped[dict] = mapped_column(JSONB, default=dict, nullable=False)
    feature_schema: Mapped[dict] = mapped_column(JSONB, default=dict, nullable=False)
    is_active: Mapped[bool] = mapped_column(Boolean, default=False, nullable=False, index=True)


class TrainingRun(Base, TimestampMixin):
    __tablename__ = "training_runs"
    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    status: Mapped[TrainingStatus] = mapped_column(Enum(TrainingStatus, name="training_status_enum", values_callable=enum_values), default=TrainingStatus.PENDING, index=True)
    model_version_id: Mapped[Optional[uuid.UUID]] = mapped_column(
        UUID(as_uuid=True), ForeignKey("model_versions.id", ondelete="SET NULL"), nullable=True
    )
    started_at: Mapped[Optional[datetime]] = mapped_column(DateTime(timezone=True), nullable=True)
    finished_at: Mapped[Optional[datetime]] = mapped_column(DateTime(timezone=True), nullable=True)
    error: Mapped[Optional[str]] = mapped_column(String(2000), nullable=True)
    metrics: Mapped[dict] = mapped_column(JSONB, default=dict, nullable=False)


class PricePrediction(Base, TimestampMixin):
    __tablename__ = "price_predictions"
    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    model_version: Mapped[str] = mapped_column(String(100), nullable=False, index=True)
    commodity: Mapped[str] = mapped_column(String(150), nullable=False, index=True)
    district: Mapped[str] = mapped_column(String(150), nullable=False, index=True)
    horizon_days: Mapped[int] = mapped_column(Integer, nullable=False)
    predicted_for: Mapped[date] = mapped_column(Date, nullable=False)
    predicted_price_per_kg: Mapped[float] = mapped_column(Numeric(15, 2), nullable=False)
    lower_bound: Mapped[float] = mapped_column(Numeric(15, 2), nullable=False)
    upper_bound: Mapped[float] = mapped_column(Numeric(15, 2), nullable=False)
    is_baseline: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False)
