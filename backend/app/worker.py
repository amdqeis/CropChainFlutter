"""Celery application for prototype background jobs."""
from celery import Celery

from app.core.config import settings

celery_app = Celery(
    "cropchain",
    broker=settings.CELERY_BROKER_URL or settings.REDIS_URL,
    backend=settings.REDIS_URL,
    include=["app.tasks"],
)
celery_app.conf.update(
    task_serializer="json",
    result_serializer="json",
    accept_content=["json"],
    timezone="Asia/Jakarta",
    beat_schedule={
        "worker-heartbeat": {"task": "app.tasks.worker_heartbeat", "schedule": 30.0},
        "release-expired-reservations": {"task": "app.tasks.release_expired_reservations", "schedule": 60.0},
        "deliver-notifications": {"task": "app.tasks.deliver_notifications", "schedule": 15.0},
        "refresh-shipments": {"task": "app.tasks.refresh_shipments", "schedule": 300.0},
    },
)
