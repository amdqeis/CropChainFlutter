# PRD - CropChain
Product Requirements Document

## 1. Latar Belakang & Tujuan
CropChain mendigitalisasi rantai distribusi hasil pertanian: Petani → Distributor → Pembeli, dengan pembayaran digital terintegrasi (Midtrans) dan traceability asal produk.

## 2. Model Akun & Role
- Setiap akun bersifat **single account, multi-role**.
- Role default saat registrasi: **Pembeli**.
- Role **Petani** dan **Distributor** hanya bisa diakses setelah proses **verifikasi** disetujui.
- Perpindahan role dilakukan lewat **tab role-switcher** di halaman Profil: `[Pembeli] [Distributor] [Petani]`.
- Jika role belum terverifikasi, tab menampilkan status: `Belum Verifikasi` → CTA "Ajukan Verifikasi".
- Status verifikasi: `pending`, `approved`, `rejected` (dengan alasan penolakan, bisa ajukan ulang).

## 3. Tujuan Produk
1. Memberi petani akses pasar & harga yang transparan.
2. Memberi distributor alat konsolidasi stok & manajemen penjualan.
3. Memberi pembeli marketplace hasil tani dengan traceability & 2 mode beli (retail/grosir).
4. Menyediakan pembayaran aman via Midtrans dengan split payout (pembeli → distributor → petani).

## 4. Ruang Lingkup MVP
| Fase | Cakupan |
|---|---|
| Fase 1 | Autentikasi, role-switcher & verifikasi, alur Petani (buat tawaran), alur Distributor (terima tawaran, buat produk), alur Pembeli (browse, checkout, bayar sandbox) |
| Fase 2 | Logistik & tracking status pesanan real-time |
| Fase 3 | Dashboard & prediksi harga (ML) |
| Fase 4 | Pembukuan otomatis & ringkasan saldo/pendapatan |
| Fase 5 | Admin panel web (verifikasi role, monitoring, dispute) |
| Fase 6 | Pilot launch (Kab. Sumedang) |

## 5. Persona Pengguna
| Persona | Kebutuhan Utama |
|---|---|
| Petani | Jual hasil panen dengan harga wajar, tanpa perantara berlapis, pembayaran cepat |
| Distributor | Konsolidasi stok banyak petani, kontrol margin, kelola pengiriman ke banyak pembeli |
| Pembeli | Produk segar & tertelusuri asalnya, harga kompetitif (retail/grosir), pembayaran aman |

## 6. Metrik Keberhasilan (Success Metrics)
- Waktu rata-rata dari offer petani dibuat → diterima distributor < 24 jam
- Tingkat penyelesaian transaksi (checkout → pembayaran berhasil) > 85%
- Retensi distributor aktif bulanan
- Rasio dispute per 100 transaksi < 2%

## 7. Out of Scope (MVP)
- Kontrak jangka menengah otomatis untuk grosir (akan dibahas di iterasi lanjutan)
- API logistik pihak ketiga (opsional, non-MVP)
- Multi-bahasa (MVP hanya Bahasa Indonesia)

## 8. Dependensi
- Midtrans (Sandbox → Production)
- Firebase Cloud Messaging (push notification)
- Google Maps API (lokasi & alamat)
- Object storage untuk foto (S3/Cloudinary)

## 9. Referensi
Detail alur layar: lihat `user_flow.md`
Detail requirement teknis & field: lihat `srs.md`
