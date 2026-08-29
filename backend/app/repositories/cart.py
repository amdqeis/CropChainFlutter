"""
Cart repository.
"""
import uuid
from typing import Optional

from sqlalchemy import select
from sqlalchemy.orm import selectinload
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.cart import Cart, CartItem


class CartRepository:

    async def get_or_create_cart(
        self, db: AsyncSession, *, user_id: uuid.UUID
    ) -> Cart:
        """Get existing cart for user or create a new one."""
        result = await db.execute(
            select(Cart)
            .where(Cart.user_id == user_id)
            .options(selectinload(Cart.items).selectinload(CartItem.product))
        )
        cart = result.scalar_one_or_none()
        if cart is None:
            cart = Cart(user_id=user_id)
            db.add(cart)
            await db.commit()
            await db.refresh(cart)
        return cart

    async def get_cart_with_items(
        self, db: AsyncSession, *, user_id: uuid.UUID
    ) -> Optional[Cart]:
        result = await db.execute(
            select(Cart)
            .where(Cart.user_id == user_id)
            .options(selectinload(Cart.items).selectinload(CartItem.product))
        )
        return result.scalar_one_or_none()

    async def get_cart_item(
        self,
        db: AsyncSession,
        *,
        cart_id: uuid.UUID,
        product_id: uuid.UUID,
    ) -> Optional[CartItem]:
        result = await db.execute(
            select(CartItem).where(
                CartItem.cart_id == cart_id,
                CartItem.product_id == product_id,
            )
        )
        return result.scalar_one_or_none()

    async def get_cart_item_by_id(
        self, db: AsyncSession, *, item_id: uuid.UUID
    ) -> Optional[CartItem]:
        result = await db.execute(
            select(CartItem).where(CartItem.id == item_id)
        )
        return result.scalar_one_or_none()

    async def add_item(
        self,
        db: AsyncSession,
        *,
        cart_id: uuid.UUID,
        product_id: uuid.UUID,
        quantity: float,
    ) -> CartItem:
        """Add item to cart. If product already exists, update quantity instead."""
        existing = await self.get_cart_item(
            db, cart_id=cart_id, product_id=product_id
        )
        if existing:
            existing.quantity = float(existing.quantity) + quantity
            await db.commit()
            await db.refresh(existing)
            return existing

        item = CartItem(cart_id=cart_id, product_id=product_id, quantity=quantity)
        db.add(item)
        await db.commit()
        await db.refresh(item)
        return item

    async def update_item_quantity(
        self, db: AsyncSession, *, item: CartItem, quantity: float
    ) -> CartItem:
        item.quantity = quantity
        await db.commit()
        await db.refresh(item)
        return item

    async def remove_item(self, db: AsyncSession, *, item: CartItem) -> None:
        await db.delete(item)
        await db.commit()

    async def clear_cart(self, db: AsyncSession, *, cart: Cart) -> None:
        """Remove all items from a cart (called after successful checkout)."""
        for item in cart.items:
            await db.delete(item)
        await db.commit()


cart_repository = CartRepository()
