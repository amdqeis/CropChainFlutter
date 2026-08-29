"""Operational CLI. Example: python -m app.cli create-admin."""
import argparse
import asyncio
import os

from sqlalchemy import select

from app.core.database import AsyncSessionLocal
from app.core.security import get_password_hash
from app.models.user import User


async def create_admin() -> None:
    email = os.getenv("BOOTSTRAP_ADMIN_EMAIL", "").strip().lower()
    password = os.getenv("BOOTSTRAP_ADMIN_PASSWORD", "")
    full_name = os.getenv("BOOTSTRAP_ADMIN_NAME", "Administrator CropChain")
    if not email or len(password) < 12:
        raise SystemExit("Atur BOOTSTRAP_ADMIN_EMAIL dan BOOTSTRAP_ADMIN_PASSWORD minimal 12 karakter.")
    async with AsyncSessionLocal() as db:
        result = await db.execute(select(User).where(User.email == email))
        user = result.scalar_one_or_none()
        if user:
            user.is_admin = True
            user.is_email_verified = True
        else:
            user = User(
                full_name=full_name, email=email,
                password_hash=get_password_hash(password),
                is_email_verified=True, is_admin=True,
            )
            db.add(user)
        await db.commit()
        print(f"Admin siap: {email}")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("command", choices=["create-admin"])
    args = parser.parse_args()
    if args.command == "create-admin":
        asyncio.run(create_admin())


if __name__ == "__main__":
    main()
