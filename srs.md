# SYSTEM REQUIREMENTS SPECIFICATION (SRS)
## Aplikasi Mobile CropChain

Dokumen ini adalah acuan teknis final, sudah diintegrasikan dan diverifikasi konsisten dengan `user_flow.md`. Semua nama field di bawah ini adalah **field final** yang wajib dipakai backend, frontend, dan AI code-gen — tidak boleh diubah nama/casing-nya tanpa update dokumen ini.

---

## 1. Gambaran Umum Sistem

CropChain adalah aplikasi mobile **single account, multi-role** (Petani, Distributor, Pembeli) yang mendigitalisasi alur distribusi hasil pertanian, dilengkapi pembayaran digital terintegrasi Midtrans, dashboard harga, dan manajemen logistik.

### 1.1 Perubahan dari Draft Sebelumnya
- "Tengkulak" diganti menjadi **"Distributor"** di seluruh dokumen & kode.
- Bukan 3 akun terpisah per role — melainkan **1 akun** dengan `active_role` yang bisa berpindah setelah verifikasi.
- Role default saat registrasi = **Pembeli** (tidak perlu verifikasi).
- Role Petani & Distributor wajib melalui **proses verifikasi** (KTP + lokasi) sebelum bisa diakses.

### 1.2 Alur Bisnis (Flow) Utama
```
PETANI --(Offer)--> DISTRIBUTOR --(Product)--> PEMBELI
```
1. Petani membuat **Offer** (tawaran hasil panen) ke distributor.
2. Distributor menerima/menegosiasi Offer → jika diterima, masuk ke **Stock** distributor.
3. Distributor mengonsolidasi Stock menjadi **Product** (listing) dengan harga retail & grosir.
4. Pembeli membeli Product → **Order** → **Payment** via Midtrans → **Shipment**.

---

## 2. Role & Verifikasi

### 2.1 Model Role
| Field | Tipe | Keterangan |
|---|---|---|
| `active_role` | enum(`pembeli`,`distributor`,`petani`) | Role yang sedang aktif digunakan user, default `pembeli` |
| `verified_roles` | array | Daftar role yang sudah `approved` |

### 2.2 Entity: RoleVerification
| Field | Tipe | Wajib | Keterangan |
|---|---|---|---|
| `id` | UUID | - | PK |
| `user_id` | UUID | ✔ | FK ke `users` |
| `role_type` | enum(`petani`,`distributor`) | ✔ | |
| `ktp_number` | string | ✔ | |
| `ktp_photo` | string (URL) | ✔ | |
| `location` | string / geopoint | ✔ | Lokasi lahan (petani) / wilayah operasional (distributor) |
| `status` | enum(`pending`,`approved`,`rejected`) | ✔ | default `pending` |
| `rejection_reason` | string | opsional | Diisi jika `status = rejected` |
| `submitted_at` | timestamp | ✔ | |
| `verified_at` | timestamp | opsional | |

**FR-VER-01**: User hanya bisa mengakses Page Petani/Distributor jika ada `RoleVerification` dengan `role_type` sesuai dan `status = approved`.
**FR-VER-02**: User yang `rejected` dapat mengajukan ulang (`resubmit`), yang membuat baris baru atau update `status` kembali ke `pending`.

---

## 3. Autentikasi

### 3.1 Entity: User
| Field | Tipe | Wajib |
|---|---|---|
| `id` | UUID | - |
| `full_name` | string | ✔ |
| `email` | string, unik | ✔ |
| `password_hash` | string | ✔ |
| `active_role` | enum | ✔ (default `pembeli`) |
| `is_email_verified` | boolean | ✔ (default false) |
| `created_at` | timestamp | ✔ |

### 3.2 Functional Requirements
| ID | Requirement |
|---|---|
| FR-AUTH-01 | Sistem mengirim `otp_code` 6 digit ke email saat Sign Up, berlaku 5 menit |
| FR-AUTH-02 | Endpoint resend OTP memiliki cooldown 60 detik |
| FR-AUTH-03 | Password di-hash dengan bcrypt sebelum disimpan |
| FR-AUTH-04 | Login menghasilkan JWT access token + refresh token |
| FR-AUTH-05 | Lupa password mengirim link/kode reset ke email terdaftar |

---

## 4. Modul Petani

### 4.1 Entity: Offer
| Field | Tipe | Wajib | Sumber di User Flow |
|---|---|---|---|
| `id` | UUID | - | |
| `petani_id` | UUID (FK users) | ✔ | |
| `category` | string/enum | ✔ | jenis hasil panen |
| `quantity` | decimal | ✔ | jumlah kg/ton |
| `unit` | enum(`kg`,`ton`) | ✔ | |
| `proposed_price` | decimal | ✔ | harga yang diinginkan (per unit) |
| `location` | string/geopoint | ✔ | lokasi hasil panen |
| `photo` | array\<string URL\> | ✔ (min 1) | upload foto hasil panen |
| `notes` | string | opsional | catatan tambahan |
| `negotiated_price` | decimal | opsional | diisi distributor saat nego |
| `status` | enum(`menunggu`,`setuju_harga_baru`,`diterima`,`tolak`,`selesai`) | ✔ | default `menunggu` |
| `created_at` | timestamp | ✔ | |

**Status transition:**
`menunggu` → (distributor nego) → `setuju_harga_baru` → (petani terima) → `diterima` → (transaksi selesai) → `selesai`
`menunggu` atau `setuju_harga_baru` → (ditolak) → `tolak`

### 4.2 Functional Requirements
| ID | Requirement |
|---|---|
| FR-PET-01 | Petani dapat membuat Offer dengan field sesuai tabel 4.1 |
| FR-PET-02 | Petani dapat filter daftar Offer berdasarkan `status`: Semua, Menunggu, Diterima, Selesai |
| FR-PET-03 | Jika `status = setuju_harga_baru`, petani dapat **Terima** (→ `diterima`) atau **Tolak** (→ `tolak`) |
| FR-PET-04 | "Hasil Panen Terjual" = daftar Offer dengan `status = selesai` |
| FR-PET-05 | "Ringkasan Saldo" dihitung dari total `Payment` yang sudah di-payout ke petani terkait |

---

## 5. Modul Distributor

### 5.1 Entity: Stock
| Field | Tipe | Wajib |
|---|---|---|
| `id` | UUID | - |
| `distributor_id` | UUID (FK users) | ✔ |
| `offer_id` | UUID (FK offers) | ✔ |
| `category` | string | ✔ |
| `quantity_available` | decimal | ✔ |
| `received_at` | timestamp | ✔ |

Dibuat otomatis saat `Offer.status` berubah menjadi `diterima`.

### 5.2 Entity: Product
| Field | Tipe | Wajib | Sumber di User Flow |
|---|---|---|---|
| `id` | UUID | - | |
| `distributor_id` | UUID (FK users) | ✔ | |
| `stock_id` | UUID (FK stock) atau array | ✔ | stok yang dipilih |
| `public_price` | decimal | ✔ | harga jual untuk publik (retail) |
| `wholesale_price` | decimal | ✔ | harga jual untuk pasar induk (grosir) |
| `location` | string/geopoint | ✔ | |
| `photo` | array\<string URL\> | ✔ (min 1) | |
| `show_farmer_info` | boolean | ✔ (default false) | tampilkan/sembunyikan info petani asal |
| `stock_remaining` | decimal | ✔ | dikurangi otomatis tiap Order sukses |
| `status` | enum(`aktif`,`nonaktif`) | ✔ | default `aktif` |
| `created_at` | timestamp | ✔ | |

### 5.3 Functional Requirements
| ID | Requirement |
|---|---|
| FR-DIST-01 | Distributor melihat daftar Offer masuk, filter: Baru, Diproses, Selesai |
| FR-DIST-02 | Distributor dapat mengisi `negotiated_price` pada Offer → status Offer berubah ke `setuju_harga_baru` |
| FR-DIST-03 | Distributor dapat **Terima** Offer langsung (tanpa nego) → status `diterima` → sistem otomatis membuat baris `Stock` → redirect ke halaman Pembayaran (distributor bayar ke petani) |
| FR-DIST-04 | "Ringkasan Stok Dimiliki" menampilkan agregat `quantity_available` per `category` dari semua Stock milik distributor |
| FR-DIST-05 | Distributor membuat Product dari Stock dengan field sesuai tabel 5.2 |
| FR-DIST-06 | Distributor dapat mengubah/menghapus Product miliknya |
| FR-DIST-07 | Distributor melihat daftar Order masuk, filter: Baru, Diproses, Dikirim, Selesai, Dibatalkan |
| FR-DIST-08 | Distributor dapat menandai Order: **Tandai Dikirim** (→ `dikirim`) / **Tandai Selesai** (→ `selesai`) |
| FR-DIST-09 | "Ringkasan Pendapatan" = total (`Order.total_price` - payout ke petani terkait) untuk Order `selesai` |

---

## 6. Modul Pembeli

### 6.1 Entity: Address
| Field | Tipe | Wajib |
|---|---|---|
| `id` | UUID | - |
| `user_id` | UUID (FK users) | ✔ |
| `label` | string | ✔ |
| `recipient_name` | string | ✔ |
| `phone` | string | ✔ |
| `full_address` | string | ✔ |
| `is_default` | boolean | ✔ (default false) |

### 6.2 Entity: Cart & CartItem
| Field | Tipe | Wajib |
|---|---|---|
| `id` | UUID | - |
| `user_id` | UUID (FK users) | ✔ |
| `product_id` | UUID (FK products) | ✔ |
| `quantity` | decimal | ✔ |

### 6.3 Entity: Order
| Field | Tipe | Wajib |
|---|---|---|
| `id` | UUID | - |
| `buyer_id` | UUID (FK users) | ✔ |
| `distributor_id` | UUID (FK users) | ✔ |
| `product_id` | UUID (FK products) | ✔ |
| `quantity` | decimal | ✔ |
| `purchase_mode` | enum(`retail`,`grosir`) | ✔ |
| `shipping_address_id` | UUID (FK addresses) | ✔ |
| `payment_method` | string | ✔ |
| `total_price` | decimal | ✔ |
| `shipping_fee` | decimal | ✔ |
| `platform_fee` | decimal | ✔ |
| `status` | enum(`diproses`,`dikirim`,`selesai`,`dibatalkan`) | ✔ | default `diproses` |
| `created_at` | timestamp | ✔ |

### 6.4 Entity: Payment
| Field | Tipe | Wajib |
|---|---|---|
| `id` | UUID | - |
| `order_id` | UUID (FK orders) | ✔ |
| `midtrans_transaction_id` | string | ✔ |
| `method` | string | ✔ |
| `amount` | decimal | ✔ |
| `status` | enum(`menunggu`,`gagal`,`berhasil`) | ✔ | default `menunggu` |
| `paid_at` | timestamp | opsional |

### 6.5 Entity: Review
| Field | Tipe | Wajib |
|---|---|---|
| `id` | UUID | - |
| `order_id` | UUID (FK orders) | ✔ |
| `buyer_id` | UUID (FK users) | ✔ |
| `product_id` | UUID (FK products) | ✔ |
| `rating` | integer (1-5) | ✔ |
| `comment` | string | opsional |
| `created_at` | timestamp | ✔ |

### 6.6 Functional Requirements
| ID | Requirement |
|---|---|
| FR-BUY-01 | Pembeli melihat detail Product: `photo`, `name`, `public_price`/`wholesale_price` (sesuai `purchase_mode`), `location`, `seller_info`, `farmer_origin_info` (hanya jika `Product.show_farmer_info = true`), `stock_remaining`, ulasan |
| FR-BUY-02 | Opsi **Tambah ke Keranjang** membuat/update `CartItem` |
| FR-BUY-03 | Opsi **Beli Sekarang** langsung ke checkout tanpa menyimpan ke Cart |
| FR-BUY-04 | Checkout wajib memilih `shipping_address_id` dari Address tersimpan atau membuat baru |
| FR-BUY-05 | Checkout menghitung `total_price = (harga x quantity) + shipping_fee + platform_fee` |
| FR-BUY-06 | Pembayaran diproses via Midtrans; status Payment awal `menunggu` |
| FR-BUY-07 | Jika Payment `gagal`, tampilkan tombol **Coba Bayar Lagi** (retry create transaction) |
| FR-BUY-08 | Jika Payment `berhasil`, Order dibuat/dikonfirmasi dan redirect ke "Lihat Pesanan Saya" |
| FR-BUY-09 | Filter status Order: Diproses (info barang), Dikirim (info distributor), Selesai (opsi Beri Ulasan + Laporkan Masalah), Dibatalkan |
| FR-BUY-10 | Kolom pencarian mencari Product berdasarkan `name`/`category`, hasil menampilkan semua Product `status = aktif` |

---

## 7. Kebutuhan Integrasi Eksternal
1. **Midtrans** — payment gateway (Snap/Core API)
2. **Google Maps API** — lokasi lahan, alamat pengiriman, tracking
3. **Firebase Cloud Messaging** — push notification
4. **SMS/WhatsApp Gateway** (opsional) — OTP & notifikasi
5. **Object Storage (S3/Cloudinary)** — foto hasil panen, produk, KTP

---

## 8. Non-Functional Requirements
- **Skalabilitas**: arsitektur modular, mendukung ekspansi wilayah
- **Keamanan**: JWT auth, HTTPS/TLS, enkripsi data sensitif (`ktp_number`, `ktp_photo` disimpan terenkripsi/akses terbatas admin)
- **Performa**: response time API < 2 detik
- **Ketersediaan**: uptime ≥ 99%
- **Kompatibilitas**: Android 6.0+, iOS 12+
- **Backup**: backup database harian
- **Auditability**: log seluruh perubahan `status` pada Offer, Order, Payment untuk audit & dispute
- **Data Privacy**: kepatuhan UU PDP — consent eksplisit saat submit KTP, retensi data verifikasi dibatasi sesuai kebijakan

---

## 9. Technology Stack

### 9.1 Frontend Mobile
Flutter (Dart), state management Riverpod, routing go_router/auto_route dengan **role-based routing** mengikuti `active_role`, HTTP client Dio, `flutter_secure_storage` untuk JWT, FCM untuk push notification.

### 9.2 Admin Web Panel
React.js/Next.js atau Flutter Web — untuk approve/reject `RoleVerification`, monitoring transaksi, kelola dispute & komisi.

### 9.3 Backend
FastAPI (Python), SQLAlchemy + Alembic, Pydantic untuk validasi payload per entity di atas, JWT (`python-jose`/`pyjwt` + `passlib`), async endpoint untuk upload foto & webhook Midtrans, Celery + Redis untuk job terjadwal (prediksi harga, notifikasi).

### 9.4 Database
PostgreSQL sebagai database utama, dengan tabel mengikuti entity di atas: `users`, `role_verifications`, `offers`, `stock`, `products`, `addresses`, `carts`, `cart_items`, `orders`, `payments`, `reviews`. Redis untuk caching harga real-time & session/rate-limiting.

### 9.5 Payment Gateway
Midtrans Snap/Core API. Endpoint `/webhook/midtrans` (async) wajib verifikasi signature key sebelum update `Payment.status`. Status juga di-double-check via API status Midtrans, bukan hanya mengandalkan webhook.

### 9.6 Infrastruktur & DevOps
VPS/Cloud (AWS/GCP/DigitalOcean), Uvicorn/Gunicorn di belakang Nginx, Docker untuk FastAPI+PostgreSQL+Redis+Celery, CI/CD, monitoring (Sentry, Grafana+Prometheus).

---

## 10. Business Rules Tambahan (klarifikasi yang sebelumnya ambigu)

| Area | Aturan |
|---|---|
| Nego harga | Distributor hanya bisa mengajukan `negotiated_price` satu kali per siklus; petani wajib respon (Terima/Tolak) sebelum distributor bisa nego ulang |
| Payout ke petani | Dilakukan saat Offer berstatus `diterima` (distributor bayar petani duluan, sebelum stok terjual ke pembeli) — sesuai flow "Terima → Halaman Pembayaran" |
| Pembatalan Order | Pembeli dapat membatalkan hanya saat `status = diproses`; setelah `dikirim` tidak bisa dibatalkan otomatis (perlu proses dispute) |
| Refund | Jika Order `dibatalkan` setelah Payment `berhasil`, refund diproses via Midtrans refund API, status Payment berubah jadi `refunded` |
| Traceability | `farmer_origin_info` hanya tampil ke pembeli jika `Product.show_farmer_info = true`; jika false, sistem tetap menyimpan relasi ke Offer/petani asal untuk keperluan audit internal, hanya disembunyikan dari tampilan pembeli |
| Verifikasi ulang | User yang `rejected` bisa mengajukan verifikasi ulang tanpa batas maksimal percobaan (MVP), disarankan tambah limit di iterasi berikutnya |

---

## 11. Tahapan Implementasi (Rekomendasi MVP)
1. **Fase 1 – Core**: Autentikasi, role-switcher + verifikasi, alur Petani (Offer), alur Distributor (terima Offer, buat Product), alur Pembeli (browse, checkout, Midtrans sandbox)
2. **Fase 2 – Logistik & Tracking**: status Order real-time
3. **Fase 3 – Dashboard Harga & ML**: prediksi harga berbasis data historis
4. **Fase 4 – Pembukuan & Edukasi**: Ringkasan Saldo/Pendapatan otomatis
5. **Fase 5 – Admin Panel**: approve/reject RoleVerification, monitoring, dispute
6. **Fase 6 – Pilot Launch**: Kabupaten Sumedang

---

## 12. Tim Pengembangan
| Peran | Jumlah |
|---|---|
| Mobile Developer (Flutter) | 1–2 |
| Backend Developer (FastAPI) | 1–2 |
| UI/UX Designer | 1 |
| Data/ML Engineer | 1 (bisa merangkap backend) |
| QA Tester | 1 |
| DevOps (paruh waktu) | 1 |
