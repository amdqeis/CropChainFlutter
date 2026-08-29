"""
User repository — data access layer for User model.
"""
import uuid
from typing import Optional

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.security import get_password_hash
from app.models.user import User, ActiveRole


class UserRepository:

    async def get_by_id(self, db: AsyncSession, *, user_id: uuid.UUID) -> Optional[User]:
        result = await db.execute(select(User).where(User.id == user_id))
        return result.scalar_one_or_none()

    async def get_by_email(self, db: AsyncSession, *, email: str) -> Optional[User]:
        result = await db.execute(select(User).where(User.email == email))
        return result.scalar_one_or_none()

    async def create(
        self,
        db: AsyncSession,
        *,
        full_name: str,
        email: str,
        password: str,
    ) -> User:
        user = User(
            full_name=full_name,
            email=email,
            password_hash=get_password_hash(password),
            active_role=ActiveRole.PEMBELI,
            is_email_verified=False,
        )
        db.add(user)
        await db.commit()
        await db.refresh(user)
        return user

    async def update_email_verified(
        self, db: AsyncSession, *, user: User, verified: bool = True
    ) -> User:
        user.is_email_verified = verified
        await db.commit()
        await db.refresh(user)
        return user

    async def update_password(
        self, db: AsyncSession, *, user: User, new_password: str
    ) -> User:
        user.password_hash = get_password_hash(new_password)
        await db.commit()
        await db.refresh(user)
        return user

    async def update_profile(
        self, db: AsyncSession, *, user: User, full_name: Optional[str] = None
    ) -> User:
        if full_name is not None:
            user.full_name = full_name
        await db.commit()
        await db.refresh(user)
        return user

    async def switch_active_role(
        self, db: AsyncSession, *, user: User, new_role: ActiveRole
    ) -> User:
        user.active_role = new_role
        await db.commit()
        await db.refresh(user)
        return user


user_repository = UserRepository()
