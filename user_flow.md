# User Flow - CropChain

Field wajib ditandai **(wajib)**, opsional ditandai **(opsional)**. Nama field di kurung siku `[field_name]` mengacu ke field di `srs.md`.

---

## 1. Alur Autentikasi (Umum)

### Landing Page
- Login
- Sign Up

### Login
- `email` **(wajib)**
- `password` **(wajib)**
- Link "Lupa Password" → alur reset password (kirim link/kode ke email)

### Sign Up
1. Input data:
   - `full_name` **(wajib)**
   - `email` **(wajib, unik)**
   - `password` **(wajib, min 8 karakter)**
2. Sistem kirim kode OTP ke email
3. Input kode OTP:
   - `otp_code` **(wajib, 6 digit, berlaku 5 menit)**
   - Aksi: **Verifikasi**
   - Aksi: **Kirim Ulang Kode** (cooldown 60 detik)
4. Setelah verifikasi sukses → akun dibuat dengan `active_role = "pembeli"` (default) → redirect ke **Home**

### Home
Halaman utama setelah Login/Sign Up berhasil. Tampilan Home mengikuti `active_role` user saat ini (default: Pembeli).

---

## 2. Role & Verifikasi (Profil)

Di halaman **Profil**, terdapat role-switcher tab: `[Pembeli] [Distributor] [Petani]`

- **Pembeli**: aktif otomatis, tidak perlu verifikasi.
- **Petani / Distributor**: tab menampilkan badge status:
  - Belum mengajukan → tombol **"Ajukan Verifikasi"**
  - `pending` → label "Sedang Diverifikasi"
  - `rejected` → label "Ditolak" + alasan + tombol "Ajukan Ulang"
  - `approved` → tab bisa diklik untuk pindah `active_role`

### Form Ajukan Verifikasi (Petani/Distributor)
- `role_type` (petani/distributor) **(wajib)**
- `ktp_number` **(wajib)**
- `ktp_photo` **(wajib, upload)**
- `location` — lokasi lahan (Petani) / wilayah operasional (Distributor) **(wajib)**
- Aksi: **Kirim Pengajuan** → status `pending` → menunggu approval admin

---

## 3. Alur Petani (Page Petani)

Diakses setelah `active_role = "petani"` (harus `approved`).

### 3.1 Membuat Tawaran Baru
Field sesuai urutan input:
1. `category` — jenis hasil panen **(wajib, pilih dari daftar kategori)**
2. `quantity` **(wajib, angka)**
3. `unit` — kg/ton **(wajib, pilihan)**
4. `proposed_price` — harga yang diinginkan **(wajib, per unit)**
5. `location` — lokasi hasil panen **(wajib)**
6. `photo` — upload foto hasil panen **(wajib, min 1 foto, max 5)**
7. `notes` — catatan tambahan **(opsional)**
- Aksi: **Buat Tawaran** → offer tersimpan dengan `status = "menunggu"`

### 3.2 Jumlah Tawaran Aktif
- Daftar semua tawaran yang pernah dibuat petani
- Filter status: `Semua`, `Menunggu`, `Diterima`, `Selesai`

### 3.3 Daftar Tawaran Terbaru
- Menampilkan info lengkap tawaran: `category`, `quantity`, `unit`, `proposed_price`, `location`, `photo`
- Status yang bisa muncul dari sisi distributor:
  - `Setuju Harga Baru` (hasil nego) → petani bisa **Terima** / **Tolak**
  - `Tolak`

### 3.4 Hasil Panen Terjual
- Rekap tawaran dengan `status = "selesai"` (sudah terjual & terbayar)

### 3.5 Ringkasan Saldo
- Total saldo masuk dari transaksi selesai
- Riwayat payout

---

## 4. Alur Distributor (Page Distributor)

Diakses setelah `active_role = "distributor"` (harus `approved`).

### 4.1 Lihat Tawaran Petani
- Daftar tawaran masuk dari petani
- Filter status: `Baru`, `Diproses`, `Selesai`
- Info lengkap tawaran: `category`, `quantity`, `unit`, `proposed_price`, `location`, `photo`
- Aksi **Negosiasi Harga**:
  - `negotiated_price` (usulan baru dari distributor)
  - Kirim ke petani → status offer petani berubah jadi `Setuju Harga Baru` (menunggu respon petani)
- Aksi **Terima** → offer `status = "diterima"` → stok otomatis masuk ke **Ringkasan Stok Dimiliki** → lanjut ke **Halaman Pembayaran** (distributor bayar ke petani)

### 4.2 Ringkasan Stok Dimiliki
- Daftar hasil panen yang sudah diterima (dari offer yang `diterima`)
- `total_quantity_available` per kategori
- Aksi: **Jual Stok Ini** → lanjut ke Buat Produk Baru

### 4.3 Buat Produk Baru
1. `stock_selected` — pilih stok yang mau dijual **(wajib)**
2. `public_price` — harga jual untuk publik/retail **(wajib)**
3. `wholesale_price` — harga jual untuk pasar induk/grosir **(wajib)**
4. `location` — lokasi produk (bisa konfirmasi dari lokasi stok) **(wajib)**
5. `photo` — upload foto produk **(wajib, min 1)**
6. `show_farmer_info` — tampilkan/sembunyikan info petani asal **(wajib, toggle boolean, default: sembunyikan)**
- Aksi: **Simpan & Tampilkan** → produk `status = "aktif"` di marketplace pembeli

### 4.4 Ringkasan Produk Aktif
- Daftar produk yang sedang dijual
- `stock_remaining` per produk
- `status` (aktif/nonaktif)
- Aksi: **Ubah** / **Hapus** produk

### 4.5 Daftar Pesanan Terbaru dari Pembeli
- Daftar pesanan masuk
- Filter status: `Baru`, `Diproses`, `Dikirim`, `Selesai`, `Dibatalkan`
- Detail pesanan: info pembeli, barang dipesan, alamat kirim
- Aksi Konfirmasi Pesanan: **Tandai Dikirim** / **Tandai Selesai**

### 4.6 Ringkasan Pendapatan
- Rekap keuangan distributor (margin dari selisih harga beli-jual)

---

## 5. Alur Pembeli (Page Pembeli)

Role default (`active_role = "pembeli"`), tidak perlu verifikasi.

### 5.1 Kategori Produk
- Klik produk → **Detail Produk**:
  - `photo`
  - `name`, `price` (retail atau grosir sesuai mode)
  - `location`
  - `seller_info` — info distributor penjual
  - `farmer_origin_info` — info asal petani (tampil hanya jika `show_farmer_info = true`)
  - `stock_available`
  - `quantity_selector` — pilihan jumlah beli
  - `reviews` — ulasan pembeli lain

**Opsi Pembelian:**
1. **Tambah ke Keranjang** → masuk ke halaman **Keranjang** (opsi: ubah `quantity`, hapus item) → tampilkan `total_price` → klik **Lanjut Bayar**
2. **Beli Sekarang** → tampilkan `total_price` → klik **Lanjut Bayar**

### 5.2 Proses Checkout & Pembayaran
Setelah klik **Lanjut Bayar**:
1. `shipping_address` — pilih dari alamat tersimpan atau tambah alamat baru **(wajib)**
   - Field alamat baru: `label`, `recipient_name`, `phone`, `full_address`, `is_default`
2. `order_summary` — ringkasan barang
3. `payment_method` — pilihan cara bayar (e-wallet/QRIS/transfer/kartu via Midtrans) **(wajib)**
4. `cost_breakdown` — rincian biaya (harga + ongkir + fee platform)
5. Aksi: **Bayar Sekarang**

**Status Pembayaran:**
- `menunggu` — menunggu konfirmasi Midtrans
- `gagal` → tombol **Coba Bayar Lagi**
- `berhasil` → redirect ke **Lihat Pesanan Saya**

### 5.3 Lihat Pesanan Saya / Manajemen Pesanan
Filter status:
- `Diproses` → tampilkan info barang
- `Dikirim` → tampilkan info distributor pengirim
- `Selesai` → tampilkan opsi **Beri Ulasan** dan **Laporkan Masalah** (→ Halaman Bantuan)
- `Dibatalkan`

### 5.4 Kolom Pencarian Produk
- `search_query` → menampilkan daftar produk dari distributor (semua produk aktif, dengan info petani asal jika diizinkan)

---

## 6. Ringkasan Konsistensi Field (Cross-check dengan SRS)

| Istilah User Flow | Istilah SRS Lama | Digunakan Final |
|---|---|---|
| Distributor | Tengkulak | **Distributor** |
| Tawaran (Petani) | Offer Petani→Tengkulak | **Offer** |
| Produk (Distributor) | Offer Tengkulak→Pembeli / Listing | **Product** |
| jumlah kg/ton | estimasi jumlah | **quantity + unit** |
| harga yang diinginkan | harga usulan | **proposed_price** |
| Setuju Harga Baru | nego harga (belum ada field jelas) | **negotiated_price + status "Setuju Harga Baru"** |
| Ringkasan Saldo/Pendapatan | Pembukuan otomatis | **saldo (petani) / pendapatan (distributor)**, dua istilah beda tapi sumber data sama (`transactions`) |
