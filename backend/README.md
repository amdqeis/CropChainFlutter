# CropChain Backend Prototype

Backend FastAPI untuk alur CropChain Petani → Distributor → Pembeli. Runtime acuan adalah Python 3.11, PostgreSQL 15, Redis 7, dan Celery. Semua pembayaran default bersifat simulasi; tidak ada transfer bank nyata.

## Menjalankan secara lokal

```bash
cp .env.example .env
docker compose up --build
```

API tersedia di `http://localhost:8000/api/v1`, Swagger di `http://localhost:8000/docs`, dan readiness di `GET /health`. Compose development menjalankan migration-once, API, PostgreSQL, Redis, worker, dan scheduler.

Bootstrap admin tidak memiliki kredensial default:

```bash
ADMIN_EMAIL=admin@example.com ADMIN_PASSWORD='change-this-password' \
  ADMIN_FULL_NAME='Prototype Admin' python -m app.cli create-admin
```

## Provider

Setiap provider dipilih eksplisit melalui environment:

- default prototype: `PAYMENT_PROVIDER=fake`, `SHIPPING_PROVIDER=fake`, `STORAGE_PROVIDER=local`, `NOTIFICATION_PROVIDER=fake`, `MAPS_PROVIDER=fake`;
- opsional: Midtrans sandbox, Shipper, Cloudinary authenticated assets, FCM, dan Google Maps.

Provider nyata yang dipilih tanpa credential membuat startup gagal. Endpoint `POST /api/v1/payments/demo/{external_order_id}/{outcome}` hanya hidup di non-production, saat payment provider `fake`, dan membutuhkan header `X-Demo-Key`.

## Alur utama

1. Register, OTP, login, lalu ajukan verifikasi Petani/Distributor dengan consent dan referensi KTP privat.
2. Admin menyetujui pengajuan; pengguna dapat mengganti active role.
3. Petani membuat offer. Distributor menerima atau mengklaim melalui negosiasi.
4. Accept membuat stock `pending_payment`; settlement pembayaran prototype mengaktifkan stock dan mencatat ledger/payout Petani.
5. Distributor mengalokasikan satu atau beberapa stock ke produk per kg.
6. Checkout buy-now/cart membuat checkout group, order per distributor, reservation, shipment quote, dan satu aggregate payment secara atomik.
7. Settlement mengubah reservation menjadi sale. Failure/expiry melepas reservation. Pembatalan berbayar memproses refund, memulihkan inventory, dan membalik ledger.
8. Distributor booking shipment dan mengirim; order selesai dapat diberi review atau dispute dalam jendela konfigurasi.

## Validasi

```bash
source .venv/bin/activate
pip install -r requirements-dev.txt
ruff check app tests
pytest -q -m 'not integration'

# Dengan PostgreSQL/Redis test nyata
RUN_INTEGRATION_TESTS=1 pytest -q

alembic upgrade head
alembic downgrade base
alembic upgrade head
docker compose config
```

Pipeline harga demo dapat diisi melalui `/api/v1/admin/ml/seed-demo`. Data tersebut ditandai sintetis. Model hanya dapat diaktifkan jika mengalahkan baseline; hasilnya bukan klaim akurasi produksi.

Dokumentasi tambahan: [runbook prototype](docs/prototype-runbook.md), [matriks requirement](docs/backend-requirement-matrix.md), dan [integration gap](docs/frontend-integration-gap.md).
