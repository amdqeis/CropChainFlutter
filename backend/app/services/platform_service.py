"""Shared audit, notification, and ledger helpers."""
import uuid
from datetime import datetime, timezone
from decimal import Decimal
from typing import Any, Optional

from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.operations import LedgerEntry, LedgerTransaction, Notification
from app.models.platform import AuditLog


async def audit(
    db: AsyncSession, *, action: str, entity_type: str, entity_id: Any,
    actor_id: Optional[uuid.UUID] = None, metadata: Optional[dict] = None,
) -> None:
    safe = {k: v for k, v in (metadata or {}).items() if k not in {"ktp_number", "password", "token"}}
    db.add(AuditLog(
        actor_id=actor_id, action=action, entity_type=entity_type,
        entity_id=str(entity_id), metadata_json=safe, created_at=datetime.now(timezone.utc),
    ))


async def notify(
    db: AsyncSession, *, user_id: uuid.UUID, kind: str, title: str, body: str,
    payload: Optional[dict] = None,
) -> Notification:
    item = Notification(user_id=user_id, kind=kind, title=title, body=body, payload=payload or {})
    db.add(item)
    return item


async def post_ledger(
    db: AsyncSession, *, reference_type: str, reference_id: Any,
    description: str, entries: list[tuple[str, Optional[uuid.UUID], Decimal]],
) -> LedgerTransaction:
    if sum((entry[2] for entry in entries), Decimal("0")) != Decimal("0"):
        raise ValueError("Ledger transaction tidak seimbang.")
    existing = await db.execute(select(LedgerTransaction).where(
        LedgerTransaction.reference_type == reference_type,
        LedgerTransaction.reference_id == str(reference_id),
    ))
    if existing.scalar_one_or_none():
        raise ValueError("Referensi ledger sudah pernah diposting.")
    tx = LedgerTransaction(
        reference_type=reference_type, reference_id=str(reference_id),
        description=description, created_at=datetime.now(timezone.utc),
    )
    db.add(tx)
    await db.flush()
    for account_code, user_id, amount in entries:
        db.add(LedgerEntry(
            transaction_id=tx.id, account_code=account_code,
            user_id=user_id, amount=amount,
        ))
    return tx


async def user_balance(db: AsyncSession, user_id: uuid.UUID) -> Decimal:
    result = await db.execute(select(func.coalesce(func.sum(LedgerEntry.amount), 0)).where(
        LedgerEntry.user_id == user_id,
        LedgerEntry.account_code.in_(["farmer_balance", "distributor_revenue"]),
    ))
    return Decimal(str(result.scalar_one()))
