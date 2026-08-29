"""
Order repository.
"""
import uuid
from typing import List, Optional

from sqlalchemy import select
from sqlalchemy.orm import selectinload
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.order import Order, OrderStatus


class OrderRepository:

    async def create(self, db: AsyncSession, *, order: Order) -> Order:
        db.add(order)
        await db.commit()
        await db.refresh(order)
        return order

    async def get_by_id(
        self, db: AsyncSession, *, order_id: uuid.UUID
    ) -> Optional[Order]:
        result = await db.execute(
            select(Order)
            .where(Order.id == order_id)
            .options(
                selectinload(Order.payment),
                selectinload(Order.shipping_address),
                selectinload(Order.product),
                selectinload(Order.buyer),
                selectinload(Order.distributor),
                selectinload(Order.review),
                selectinload(Order.items),
            )
        )
        return result.scalar_one_or_none()

    async def get_by_buyer(
        self,
        db: AsyncSession,
        *,
        buyer_id: uuid.UUID,
        status: Optional[OrderStatus] = None,
    ) -> List[Order]:
        query = (
            select(Order)
            .where(Order.buyer_id == buyer_id)
            .options(
                selectinload(Order.payment),
                selectinload(Order.product),
                selectinload(Order.shipping_address),
            )
        )
        if status:
            query = query.where(Order.status == status)
        result = await db.execute(query.order_by(Order.created_at.desc()))
        return list(result.scalars().all())

    async def get_by_distributor(
        self,
        db: AsyncSession,
        *,
        distributor_id: uuid.UUID,
        status: Optional[OrderStatus] = None,
    ) -> List[Order]:
        query = (
            select(Order)
            .where(Order.distributor_id == distributor_id)
            .options(
                selectinload(Order.payment),
                selectinload(Order.product),
                selectinload(Order.shipping_address),
                selectinload(Order.buyer),
            )
        )
        if status:
            query = query.where(Order.status == status)
        result = await db.execute(query.order_by(Order.created_at.desc()))
        return list(result.scalars().all())

    async def update_status(
        self, db: AsyncSession, *, order: Order, status: OrderStatus
    ) -> Order:
        order.status = status
        await db.commit()
        await db.refresh(order)
        return order


order_repository = OrderRepository()
