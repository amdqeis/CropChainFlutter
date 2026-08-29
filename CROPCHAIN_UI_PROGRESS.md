# CROPCHAIN UI PROGRESS LOG

**Session Start Protocol:** Baca file ini SEBELUM membuat perubahan apapun.
**Last Updated:** 2026-08-27 Session B

---

## Design System

### Warna Utama
| Token | Value | Penggunaan |
|-------|-------|------------|
| `primaryGreen` | `#4A7C3F` | AppBar text, heading, icon utama |
| `primaryGreenDark` | `#3D6834` | Button fill utama (Beli, Lanjut Bayar, dll) |
| `accentOrange` | `#E8711A` | Badge status, Checkout CTA, qty stepper, timer payment |
| `lightGreenBg` | `#E8F0E3` | Menu icon background, card subtle |
| `textPrimary` | `#1A1A1A` | Judul & body text |
| `textSecondary` | `#6B6B6B` | Label & deskripsi sekunder |
| `borderColor` | `#E0E0E0` | Divider, outline input field |
| `backgroundGrey` | `#F5F5F5` | Background halaman, card placeholder |
| `white` | `#FFFFFF` | Surface card |

### Tipografi
- **Font:** Google Fonts "Inter" atau system default
- **H1/Title:** Bold, 24px, textPrimary
- **H2/Section title:** SemiBold, 18px, primaryGreen
- **Body:** Regular, 14px, textPrimary
- **Caption:** Regular, 12px, textSecondary

### Bottom Navigation Bar
- Bentuk: Pill/rounded container dengan border hijau
- Background: White
- Active icon: `primaryGreen` (filled)
- Inactive icon: `primaryGreen` (line/outline)

### Status Badge
- Background: accentOrange (default)
- Text: White, 11px, bold
- BorderRadius: 20px (pill)
- Khusus "Aktif": `primaryGreenDark`
- Khusus "Nonaktif": Abu-abu

---

## Mapping Layar → File

### SHARED (Semua role)
| # | Layar | File Target | Status |
|---|-------|-------------|--------|
| S-1 | Splash / Onboarding (ss 1) | `features/auth/pages/splash_page.dart` | ✅ DONE |
| S-2 | Splash Loading Logo (ss 2) | `features/auth/pages/splash_page.dart` | ✅ DONE |
| S-3 | Login glassmorphism (ss 3) | `features/auth/pages/login_page.dart` | ✅ DONE |
| S-4 | Register Form (ss 5) | `features/auth/pages/register_page.dart` | ✅ DONE |
| S-5 | OTP Verification (ss 6) | `features/auth/pages/register_page.dart` | ✅ DONE |

### PEMBELI (Role: Buyer)
| # | Layar | File Target | Status |
|---|-------|-------------|--------|
| B-1 | Home Pembeli (ss 7) | `features/buyer/pages/buyer_pages.dart` | ✅ DONE |
| B-2 | Katalog Produk (ss 9) | `features/buyer/pages/buyer_pages.dart` | ✅ DONE |
| B-3 | Detail Produk (ss 10, 14) | `features/buyer/pages/buyer_pages.dart` | ✅ DONE |
| B-4 | Keranjang (ss 24) | `features/buyer/pages/buyer_pages.dart` | ✅ DONE — checkbox, orange qty, Checkout orange |
| B-5 | Checkout (ss 15) | `features/buyer/pages/buyer_pages.dart` | ✅ DONE — Qris/BCA VA/Credit Card radio orange |
| B-6 | Menunggu Konfirmasi (ss 16) | `features/buyer/pages/buyer_pages.dart` | ✅ DONE — orange header + timer 25 menit |
| B-7 | Payment Success (ss 17) | `features/buyer/pages/buyer_pages.dart` | ✅ DONE — _PaymentResultSheet modal green |
| B-8 | Payment Failed (ss 18) | `features/buyer/pages/buyer_pages.dart` | ✅ DONE — shared _PaymentResultSheet red |
| B-9 | Status Pesanan (ss 19-23) | `features/buyer/pages/buyer_pages.dart` | ✅ DONE — 4 filter chips + _OrderCard |
| B-10 | Order Tracking | `features/buyer/pages/buyer_pages.dart` | ✅ DONE |

### DISTRIBUTOR (Role: Distributor)
| # | Layar | File Target | Status |
|---|-------|-------------|--------|
| D-1 | Home Distributor (ss 25, 46) | `features/distributor/pages/distributor_pages.dart` | ✅ DONE |
| D-2 | Tawaran dari Petani (ss 26) | `features/distributor/pages/distributor_pages.dart` | ✅ DONE |
| D-3 | Detail Tawaran Petani (ss 27, 29) | `features/distributor/pages/distributor_pages.dart` | ✅ DONE |
| D-4 | Halaman Pembayaran Dist (ss 28) | `features/distributor/pages/distributor_pages.dart` | ✅ DONE |
| D-5 | Negosiasi Harga (ss 30) | `features/distributor/pages/distributor_pages.dart` | ✅ DONE |
| D-6 | Tawaran Diterima (ss 31) | `features/distributor/pages/distributor_pages.dart` | ✅ DONE |
| D-7 | Ringkasan Stok (ss 32) | `features/distributor/pages/distributor_pages.dart` | ✅ DONE |
| D-8 | Detail Stok (ss 33) | `features/distributor/pages/distributor_pages.dart` | ✅ DONE |
| D-9 | Buat Produk Baru Wizard (ss 34) | `features/distributor/pages/distributor_pages.dart` | ✅ DONE |
| D-10 | Input Info Produk (ss 35) | `features/distributor/pages/distributor_pages.dart` | ✅ DONE |
| D-11 | Stok & Harga (ss 36) | `features/distributor/pages/distributor_pages.dart` | ✅ DONE |
| D-12 | Produk Berhasil Dibuat (ss 37) | `features/distributor/pages/distributor_pages.dart` | ✅ DONE |
| D-13 | Produk Aktif List (ss 38) | `features/distributor/pages/distributor_pages.dart` | ✅ DONE |
| D-14 | Detail Produk Aktif (ss 39) | `features/distributor/pages/distributor_pages.dart` | ✅ DONE |
| D-15 | Ubah Status Produk (ss 40) | `features/distributor/pages/distributor_pages.dart` | ✅ DONE |
| D-16 | Pesanan Masuk (ss 41) | `features/distributor/pages/distributor_pages.dart` | ✅ DONE |
| D-17 | Detail Pesanan (ss 42) | `features/distributor/pages/distributor_pages.dart` | ✅ DONE |
| D-18 | Ubah Status Pesanan (ss 43) | `features/distributor/pages/distributor_pages.dart` | ✅ DONE |
| D-19 | Pesanan Dikirim Success (ss 44) | `features/distributor/pages/distributor_pages.dart` | ✅ DONE |
| D-20 | Pendapatan (ss 45) | `features/distributor/pages/distributor_pages.dart` | ✅ DONE — green card Rp.24.500.000 |

### PETANI (Role: Farmer)
| # | Layar | File Target | Status |
|---|-------|-------------|--------|
| F-1 | Home Petani (ss 47) | `features/farmer/pages/farmer_pages.dart` | ✅ DONE — greeting, summary, menu 5 item |
| F-2 | Buat Tawaran - Form (ss 48-49) | `features/farmer/pages/farmer_pages.dart` | ✅ DONE — 3-step wizard |
| F-3 | Tawaran Terkirim (ss 48) | `features/farmer/pages/farmer_pages.dart` | ✅ DONE — green check page |
| F-4 | Tawaran Aktif (ss 50) | `features/farmer/pages/farmer_pages.dart` | ✅ DONE — filter chips + list |
| F-5 | Tawaran Terbaru (ss 51) | `features/farmer/pages/farmer_pages.dart` | ✅ DONE |
| F-6 | Detail Tawaran Masuk (ss 52) | `features/farmer/pages/farmer_pages.dart` | ✅ DONE |
| F-7 | Pendapatan Petani (ss 53) | `features/farmer/pages/farmer_pages.dart` | ✅ DONE — reuse green card pattern |

---

## Execution Log

### Session A (2026-08-27)
- Audit 53 screenshot referensi
- Setup implementation plan & task tracking
- Identifikasi gap antara kode dengan desain

### Session B (2026-08-27)  
**Files Modified:**
- `lib/features/auth/pages/splash_page.dart` — improved warm amber gradient + teal logo colors
- `lib/features/buyer/pages/buyer_pages.dart` — 6 major gaps fixed:
  - BuyerCartPage: checkbox-left layout, orange qty stepper, "Checkout" CTA orange
  - BuyerCheckoutPage: Qris/BCA VA/Credit Card radio orange-filled, full redesign
  - BuyerPaymentPage: "Menunggu Konfirmasi..." + timer 25 menit + Midtrans area
  - _PaymentResultSheet: reusable modal bottom sheet (success + failed)
  - BuyerOrderStatusPage: 4 filter tabs (Diproses/Dikirim/Selesai/Dibatalkan) + _OrderCard
  - Cleanup: removed dead code _StatusStep + _totalChecked

**Status:** `flutter analyze` — 1 warning (intentional: `checked` param default false), 0 errors

---

## Notes
- Screenshot 1-13: Auth + Buyer Home + Katalog
- Screenshot 14-24: Buyer flow (detail produk, checkout, status pesanan, keranjang)
- Screenshot 25-45: Distributor flow (home, tawaran, stok, produk, pesanan, pendapatan)
- Screenshot 46: Distributor home variant 2
- Screenshot 47-53: Petani flow
- Bottom Nav Pembeli: 4 icon (Home, Stok/Bag, Cart, Profile)
- Bottom Nav Distributor: 3 icon (Home, Pendapatan/Money Bag, Profile)
- Bottom Nav Petani: 3 icon (Home, Pendapatan/Money Bag, Profile)

## Architecture Decisions
- `_PaymentResultSheet` digunakan sebagai modal bottom sheet (bukan full page) — sesuai ss 17 & 18
- `BuyerCheckoutPage` diubah menjadi StatefulWidget untuk mendukung radio button selection
- Orange color (`accentOrange #E8711A`) digunakan secara konsisten sebagai CTA sekunder dan state "menunggu"
- `_CartItem` sebagai data class sederhana (tanpa provider) sesuai dengan pola StatefulWidget yang sudah ada
