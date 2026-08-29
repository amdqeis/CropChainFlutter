"""
Base mixin and utility classes for all SQLAlchemy ORM models.
"""
from datetime import datetime
from sqlalchemy import DateTime, func
from sqlalchemy.orm import Mapped, mapped_column


def enum_values(enum_cls):
    """Persist string enum values (lowercase API contract), not Python member names."""
    return [member.value for member in enum_cls]


class TimestampMixin:
    """Mixin that adds created_at and updated_at timestamps to any model."""

    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        server_default=func.now(),
        nullable=False,
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        server_default=func.now(),
        onupdate=func.now(),
        nullable=False,
    )
