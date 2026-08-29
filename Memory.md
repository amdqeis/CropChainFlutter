# Konteks Implementasi Backend CropChain

Terakhir diperbarui: 2026-07-14 (Asia/Jakarta).

- Scope: backend/database/deployment/docs saja; frontend Flutter tidak diubah.
- Prototype memakai provider fake deterministik secara default dan tidak melakukan transaksi bank nyata. Adapter opsional tersedia untuk Midtrans sandbox, Shipper, Cloudinary, FCM, dan Google Maps.
- Runtime produksi acuan Python 3.11, PostgreSQL 15, Redis 7, FastAPI, Celery worker/beat, dan Caddy.
- Migrasi `001_initial_schema` dipertahankan dan diperbaiki agar fresh install valid. Revision lanjutan: `b1f9cea001f6` (domain prototype lengkap) dan `c3a51e820fe2` (constraint, FK ML, active-dispute uniqueness, immutable ledger).
- Alur yang sudah dibuktikan melalui smoke test: register/OTP/admin approval/role switch → offer/negotiation/accept → fake farmer payment → stock aktif → product → buyer checkout/payment → shipment → selesai → review/dashboard.
- Checkout multi-item bersifat atomik dan menggunakan row lock, checkout group, order per distributor, aggregate payment, shipment per order, reservation timeout, retry attempt, idempotent transition, serta refund inventory/ledger reversal.
- KTP disimpan sebagai encrypted NIK dan private asset reference; aset lokal berada di `.private_media`, bukan static `/media`.
- ML prototype mendukung seed sintetis berlabel, import observasi, time-based training, baseline gate, model activation, dan prediction 7/30 hari. Tidak ada klaim validasi produksi tanpa dataset nyata.
- Endpoint utama dan integration gap frontend dicatat di `backend/docs/`.
- Validasi yang telah dijalankan: unit test, integration ML pada PostgreSQL nyata, Alembic fresh upgrade/downgrade/upgrade, OpenAPI generation, dan E2E smoke manual.
- TODO jangka lanjut: contract-test adapter Shipper/Midtrans dengan sandbox credential pengguna, tambah suite concurrency/IDOR penuh, selesaikan strict MyPy debt pada forward reference/Decimal ORM lama, dan validasi model dengan dataset harga nyata.

## Konteks Implementasi Frontend MVP (2026-07-18, diperbarui 2026-08-02)

- Frontend Flutter menggunakan design system CropChain dengan palette tetap,
  Poppins global, Riverpod, GoRouter, Dio, dan secure token storage.
- `BACKEND_URL` wajib diberikan sebagai origin lewat `--dart-define`; seluruh
  endpoint `/api/v1` tersentralisasi dan tidak ada URL backend hardcoded.
- **Semua flow MVP Phase 1 sudah terimplementasi**: auth/OTP/reset, verifikasi
  dan switch role, Offer Petani (buat/filter/terima-tolak-nego), Saldo Petani,
  Distributor (tawaran+nego+terima, stok, produk, order+aksi), Ringkasan
  Pendapatan Distributor, marketplace Pembeli, cart, checkout, payment browser,
  order Pembeli (filter status, Beri Ulasan, Laporkan).
- `flutter analyze` bersih (No issues found) per 2026-08-02.
- Debug APK berhasil di-build: `build/app/outputs/flutter-apk/app-debug.apk`.
- Screen baru ditambahkan: `DistributorRevenueScreen` (4.6), enhanced
  `BuyerOrdersScreen` (5.3 dengan review dan filter), `PetaniSaldoScreen` (3.5).
- Semua route terdaftar di `AppRouter`; bottom nav 3-tab sesuai active_role.
