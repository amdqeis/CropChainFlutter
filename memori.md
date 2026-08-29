# Memori Proyek IISIEC

## 2026-08-01 — Keputusan bahasa backend CropChain

- Frontend tetap Flutter/Dart dan backend tetap menjadi service terpisah menggunakan FastAPI/Python.
- Backend Dart tidak diperlukan hanya untuk menyamakan bahasa dengan frontend. Pemisahan melalui kontrak HTTP `/api/v1` sudah tepat.
- Alasan utama mempertahankan FastAPI: implementasi backend sudah mencakup PostgreSQL/SQLAlchemy/Alembic, Redis, Celery worker dan scheduler, autentikasi/otorisasi, webhook dan refund pembayaran, shipping, notifikasi, ledger/payout, dispute, serta pipeline ML berbasis scikit-learn.
- Migrasi penuh ke Dart akan menjadi rewrite dengan risiko regresi kontrak, transaksi, migrasi database, background job, provider, dan deployment, tanpa manfaat bisnis yang terukur saat ini.
- Dart backend layak dipertimbangkan ulang hanya jika ada kebutuhan organisasi yang konkret, misalnya tim backend hanya menguasai Dart, target deployment khusus Dart, atau bukti operasional bahwa Python menjadi bottleneck. Keputusan tersebut memerlukan proposal migrasi dan persetujuan sebelum perubahan database atau kontrak API.
- Catatan dokumentasi: README root masih mengarahkan instalasi manual ke `requirements.txt`, sedangkan metadata `pyproject.toml` saat ini hanya memuat konfigurasi Ruff; sumber dependency aktual berada di `requirements.txt` dan `requirements-dev.txt`.
