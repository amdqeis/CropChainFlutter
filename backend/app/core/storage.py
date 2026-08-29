import uuid
import asyncio
from pathlib import Path
from typing import Optional

import aiofiles
from fastapi import UploadFile

from app.core.config import settings

# Allowed image MIME types
ALLOWED_IMAGE_TYPES = {"image/jpeg", "image/png", "image/webp"}

# Max file size in bytes
MAX_FILE_SIZE = settings.MAX_UPLOAD_SIZE_MB * 1024 * 1024


def _ensure_upload_dir(subdir: str = "") -> Path:
    """Ensure the upload directory exists and return its path."""
    upload_path = Path(settings.UPLOAD_DIR) / subdir
    upload_path.mkdir(parents=True, exist_ok=True)
    return upload_path


def _get_file_extension(content_type: str) -> str:
    """Get file extension from MIME type."""
    mapping = {
        "image/jpeg": ".jpg",
        "image/png": ".png",
        "image/webp": ".webp",
    }
    return mapping.get(content_type, ".jpg")


async def save_upload_file(
    file: UploadFile,
    subdir: str = "images",
    max_size: Optional[int] = None,
    private: bool = False,
) -> str:
    """
    Save an uploaded file to local storage.
    Returns the relative URL path (e.g., '/media/images/uuid.jpg').
    
    Raises ValueError if:
    - File type is not allowed
    - File size exceeds the limit
    """
    # Validate content type
    if file.content_type not in ALLOWED_IMAGE_TYPES:
        raise ValueError(
            f"Tipe file tidak didukung. Gunakan: JPEG, PNG, atau WebP. "
            f"Diterima: {file.content_type}"
        )

    # Read file content
    content = await file.read()

    # Validate file size
    limit = max_size or MAX_FILE_SIZE
    if len(content) > limit:
        raise ValueError(
            f"Ukuran file terlalu besar. Maksimum {settings.MAX_UPLOAD_SIZE_MB}MB."
        )

    if settings.STORAGE_PROVIDER == "cloudinary":
        import cloudinary
        import cloudinary.uploader
        cloudinary.config(cloudinary_url=settings.CLOUDINARY_URL, secure=True)
        result = await asyncio.to_thread(
            cloudinary.uploader.upload,
            content,
            folder=f"cropchain/{subdir}",
            type="authenticated" if private else "upload",
            resource_type="image",
        )
        return f"cloudinary://{result['public_id']}" if private else result["secure_url"]

    # Generate unique filename
    ext = _get_file_extension(file.content_type)
    filename = f"{uuid.uuid4().hex}{ext}"

    # Save to disk
    upload_dir = (Path(settings.PRIVATE_UPLOAD_DIR) / subdir) if private else _ensure_upload_dir(subdir)
    upload_dir.mkdir(parents=True, exist_ok=True)
    file_path = upload_dir / filename

    async with aiofiles.open(file_path, "wb") as f:
        await f.write(content)

    # Return the URL path
    if private:
        return f"private://{subdir}/{filename}"
    return f"/{settings.UPLOAD_DIR}/{subdir}/{filename}"


def private_asset_path(reference: str) -> Path:
    """Resolve a private local reference without allowing path traversal."""
    if not reference.startswith("private://"):
        raise ValueError("Referensi aset privat tidak valid.")
    relative = Path(reference.removeprefix("private://"))
    if relative.is_absolute() or ".." in relative.parts:
        raise ValueError("Referensi aset privat tidak valid.")
    root = Path(settings.PRIVATE_UPLOAD_DIR).resolve()
    resolved = (root / relative).resolve()
    if root not in resolved.parents:
        raise ValueError("Referensi aset privat tidak valid.")
    return resolved


def cloudinary_private_url(reference: str) -> str:
    if not reference.startswith("cloudinary://"):
        raise ValueError("Referensi Cloudinary tidak valid.")
    import cloudinary
    import cloudinary.utils
    cloudinary.config(cloudinary_url=settings.CLOUDINARY_URL, secure=True)
    url, _ = cloudinary.utils.cloudinary_url(
        reference.removeprefix("cloudinary://"), type="authenticated", sign_url=True, secure=True
    )
    return url


async def save_multiple_files(
    files: list[UploadFile],
    subdir: str = "images",
    max_files: int = 5
) -> list[str]:
    """
    Save multiple uploaded files. Returns list of URL paths.
    Raises ValueError if number of files exceeds max_files.
    """
    if len(files) > max_files:
        raise ValueError(f"Maksimum {max_files} foto diperbolehkan.")

    urls = []
    for file in files:
        url = await save_upload_file(file, subdir=subdir)
        urls.append(url)

    return urls


def delete_file(url_path: str) -> bool:
    """
    Delete a file given its URL path (e.g., '/media/images/uuid.jpg').
    Returns True if deleted, False if not found.
    """
    if not url_path:
        return False

    # Strip leading slash and convert to Path
    relative_path = url_path.lstrip("/")
    file_path = Path(relative_path)

    if file_path.exists():
        file_path.unlink()
        return True
    return False
