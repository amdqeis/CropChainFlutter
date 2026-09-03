import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/shared_widgets.dart';

// ─────────────────────────────────────────────
// FARMER HOME PAGE
// Referensi: Screenshot 46 - "Halo Petani 👋 Welcome to CropChain"
// menu: Buat Tawaran, Tawaran Aktif, Tawaran Terbaru, Hasil Panen, Pendapatan
// ─────────────────────────────────────────────
class FarmerHomePage extends StatefulWidget {
  const FarmerHomePage({super.key});

  @override
  State<FarmerHomePage> createState() => _FarmerHomePageState();
}

class _FarmerHomePageState extends State<FarmerHomePage> {
  int _currentNavIndex = 0;

  static const _recentActiveOffers = [
    {
      'commodity': 'Beras Premium',
      'price': 'Rp 11.500/kg',
      'qty': '150 kg',
      'status': 'Aktif',
    },
    {
      'commodity': 'Cabai Merah',
      'price': 'Rp 30.000/kg',
      'qty': '80 kg',
      'status': 'Aktif',
    },
  ];

  void _onNavTap(int index) {
    setState(() => _currentNavIndex = index);
    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.pushNamed(context, '/farmer/income');
        break;
      case 2:
        Navigator.pushNamed(context, '/farmer/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: const CropChainAppBar(title: 'CROPCHAIN'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting
            const Text(
              'Halo Petani 👋',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.accentOrange,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Text(
              'Welcome to CropChain',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary),
            ),
            const SizedBox(height: 16),

            // Ringkasan Hari ini card (matching Screenshot 47)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ringkasan Hari ini',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  IntrinsicHeight(
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '5',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const Text(
                                'Tawaran Aktif',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        const VerticalDivider(thickness: 1),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '3',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const Text(
                                  'Tawaran Terjual',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Banner area
            Container(
              height: 160,
              decoration: BoxDecoration(
                color: AppColors.lightGreenBg2,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderColor),
              ),
            ),
            const SizedBox(height: 20),

            // Menu Utama
            const Text(
              'Menu Utama',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.accentOrange,
              ),
            ),
            const SizedBox(height: 12),

            Wrap(
              spacing: 20,
              runSpacing: 16,
              children: [
                MenuGridItem(
                  icon: Icons.add_box_outlined,
                  label: 'Buat Tawaran',
                  onTap: () =>
                      Navigator.pushNamed(context, '/farmer/create-offer'),
                ),
                MenuGridItem(
                  icon: Icons.storefront_outlined,
                  label: 'Tawaran Aktif',
                  onTap: () =>
                      Navigator.pushNamed(context, '/farmer/active-offers'),
                ),
                MenuGridItem(
                  icon: Icons.history_outlined,
                  label: 'Tawaran Terbaru',
                  onTap: () =>
                      Navigator.pushNamed(context, '/farmer/recent-offers'),
                ),
                MenuGridItem(
                  icon: Icons.agriculture_outlined,
                  label: 'Hasil Panen',
                  onTap: () =>
                      Navigator.pushNamed(context, '/farmer/harvest'),
                ),
                MenuGridItem(
                  icon: Icons.account_balance_wallet_outlined,
                  label: 'Pendapatan',
                  onTap: () =>
                      Navigator.pushNamed(context, '/farmer/income'),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Tawaran Aktif Terbaru section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tawaran Aktif Terbaru',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.accentOrange,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pushNamed(
                      context, '/farmer/active-offers'),
                  child: const Row(
                    children: [
                      Text('Lihat Semua',
                          style: TextStyle(
                              fontSize: 12, color: AppColors.textSecondary)),
                      Icon(Icons.chevron_right,
                          size: 16, color: AppColors.textSecondary),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ..._recentActiveOffers.map(
              (o) => _FarmerOfferPreviewCard(
                commodity: o['commodity']!,
                price: o['price']!,
                qty: o['qty']!,
                status: o['status']!,
                onTap: () => Navigator.pushNamed(
                    context, '/farmer/active-offers'),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CropChainBottomNav(
        currentIndex: _currentNavIndex,
        items: const [
          BottomNavItem(icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Home'),
          BottomNavItem(
              icon: Icons.account_balance_wallet_outlined, label: 'Income'),
          BottomNavItem(icon: Icons.person_outline, activeIcon: Icons.person, label: 'Profile'),
        ],
        onTap: _onNavTap,
      ),
    );
  }
}

// ─────────────────────────────────────────────
// FARMER HOME — Offer Preview Card
// ─────────────────────────────────────────────
class _FarmerOfferPreviewCard extends StatelessWidget {
  final String commodity;
  final String price;
  final String qty;
  final String status;
  final VoidCallback onTap;

  const _FarmerOfferPreviewCard({
    required this.commodity,
    required this.price,
    required this.qty,
    required this.status,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderColor),
        ),
        child: Row(
          children: [
            const ProductImagePlaceholder(size: 60),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      StatusBadge.fromStatus(status),
                      const Icon(Icons.chevron_right,
                          size: 16, color: AppColors.textSecondary),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    commodity,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$price  •  $qty',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// FARMER - BUAT TAWARAN (Wizard 2-step sesuai Figma)
// Frame 48: Pilih Kategori | Frame 49: Form Detail
// ─────────────────────────────────────────────
class FarmerCreateOfferPage extends StatefulWidget {
  const FarmerCreateOfferPage({super.key});

  @override
  State<FarmerCreateOfferPage> createState() => _FarmerCreateOfferPageState();
}

class _FarmerCreateOfferPageState extends State<FarmerCreateOfferPage> {
  // Step 0 = pilih kategori, Step 1 = form detail
  int _step = 0;
  String? _selectedCategory;

  // Form controllers (step 2)
  final _qtyCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  static const _categories = [
    'Beras', 'Cabai', 'Tomat', 'Jagung', 'Bawang', 'Sayuran', 'Buah-buahan',
  ];

  @override
  void dispose() {
    _qtyCtrl.dispose();
    _priceCtrl.dispose();
    _locationCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryGreen),
          onPressed: () {
            if (_step > 0) {
              setState(() => _step--);
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: Text(
          _step == 0 ? 'Buat Tawaran Baru' : 'Buat Produk Baru',
          style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryGreen),
        ),
      ),
      body: _step == 0 ? _buildCategoryPicker() : _buildFormDetail(),
    );
  }

  // ── STEP 0: Pilih Kategori (Figma Frame 48) ──
  Widget _buildCategoryPicker() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pilih jenis hasil panen\n(kategori)',
              style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: _categories.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  final cat = _categories[i];
                  return GestureDetector(
                    onTap: () => setState(() {
                      _selectedCategory = cat;
                      _step = 1;
                    }),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 20),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _selectedCategory == cat
                              ? AppColors.primaryGreen
                              : AppColors.borderColor,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        cat,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: _selectedCategory == cat
                              ? AppColors.primaryGreen
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── STEP 1: Form Detail (Figma Frame 49) ──
  Widget _buildFormDetail() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _formLabel('Input jumlah'),
                _textField(_qtyCtrl, '11.500'),
                const SizedBox(height: 14),
                _formLabel('Input harga yang diinginkan'),
                _textField(_priceCtrl, ''),
                const SizedBox(height: 14),
                _formLabel('Input lokasi hasil panen'),
                _textField(_locationCtrl, ''),
                const SizedBox(height: 14),
                _formLabel('Upload foto hasil panen'),
                Row(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.borderColor),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.borderColor),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.add,
                          color: AppColors.primaryGreen, size: 28),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _formLabel('Catatan Tambahan (Opsional)'),
                _textField(_noteCtrl, ''),
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () =>
                  Navigator.pushNamed(context, '/farmer/offer-sent'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreenDark,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Buat Tawaran',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _formLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text,
          style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary)),
    );
  }

  Widget _textField(TextEditingController ctrl, String hint) {
    return TextField(
      controller: ctrl,
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.borderColor)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.borderColor)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
                color: AppColors.primaryGreen, width: 1.5)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }
}

class _WizardStepItem extends StatelessWidget {
  final int index;
  final String label;
  final bool isActive;
  final bool isLast;
  final VoidCallback? onTap;

  const _WizardStepItem({
    required this.index,
    required this.label,
    required this.isActive,
    required this.isLast,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            GestureDetector(
              onTap: onTap,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.primaryGreen
                      : AppColors.lightGreenBg2,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$index',
                    style: TextStyle(
                      color: isActive
                          ? Colors.white
                          : AppColors.textSecondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
            if (!isLast)
              Container(
                  width: 2, height: 40, color: AppColors.borderColor),
          ],
        ),
        const SizedBox(width: 14),
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Row(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight:
                      isActive ? FontWeight.bold : FontWeight.normal,
                  color: isActive
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                ),
              ),
              if (isActive)
                const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(Icons.chevron_right,
                      color: AppColors.textSecondary, size: 18),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// FARMER - TAWARAN TERKIRIM SUCCESS
// Referensi: Screenshot 48 - "Tawaran Berhasil Dikirim!" green check
// ─────────────────────────────────────────────
class FarmerOfferSentPage extends StatelessWidget {
  const FarmerOfferSentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: AppColors.primaryGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 44),
              ),
              const SizedBox(height: 20),
              const Text(
                'Tawaran Berhasil Dikirim!',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Tawaran kamu telah berhasil dikirim. Tunggu distributor merespons.',
                style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              const DetailRow(label: 'Produk', value: 'Beras Premium'),
              const DetailRow(label: 'Jumlah', value: '120 kg'),
              const DetailRow(label: 'Harga Tawar', value: 'Rp 11.500/kg'),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, '/farmer/active-offers'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreenDark,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Lihat Tawaran Aktif'),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () => Navigator.pushNamedAndRemoveUntil(
                      context, '/farmer/home', (route) => false),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primaryGreen),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Kembali ke Beranda'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// FARMER - TAWARAN AKTIF
// Referensi: Screenshot 49 - list tawaran aktif dgn status badge
// ─────────────────────────────────────────────
class FarmerActiveOffersPage extends StatefulWidget {
  const FarmerActiveOffersPage({super.key});

  @override
  State<FarmerActiveOffersPage> createState() =>
      _FarmerActiveOffersPageState();
}

class _FarmerActiveOffersPageState extends State<FarmerActiveOffersPage> {
  String _filter = 'Semua';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryGreen),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Tawaran Aktif',
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryGreen),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: FilterChipRow(
              items: const ['Semua', 'Diproses', 'Ditolak', 'Negosiasi'],
              selected: _filter,
              onSelected: (v) => setState(() => _filter = v),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 4,
              itemBuilder: (context, i) {
                final statuses = [
                  ('Diproses', false),
                  ('Ditolak', false),
                  ('Diproses', false),
                  ('Negosiasi', false),
                ];
                final (status, _) = statuses[i % statuses.length];
                return GestureDetector(
                  onTap: status == 'Negosiasi'
                      ? () => Navigator.pushNamed(
                          context, '/farmer/counter-offer')
                      : null,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const ProductImagePlaceholder(size: 72),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  StatusBadge.fromStatus(status),
                                  const Spacer(),
                                  const Text('1 jam',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textSecondary)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              const Text('Tawaran ID - 12345689',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold)),
                              const Text('Beras Premium',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary)),
                              const Text('120 kg • Rp 11.500/kg',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// FARMER - TAWARAN TERBARU / RIWAYAT
// Referensi: Similar to active offers but historical
// ─────────────────────────────────────────────
class FarmerRecentOffersPage extends StatefulWidget {
  const FarmerRecentOffersPage({super.key});

  @override
  State<FarmerRecentOffersPage> createState() =>
      _FarmerRecentOffersPageState();
}

class _FarmerRecentOffersPageState extends State<FarmerRecentOffersPage> {
  String _filter = 'Semua';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryGreen),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Tawaran Terbaru',
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryGreen),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: FilterChipRow(
              items: const ['Semua', 'Diterima', 'Ditolak', 'Selesai'],
              selected: _filter,
              onSelected: (v) => setState(() => _filter = v),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 5,
              itemBuilder: (context, i) {
                final statuses = ['Baru', 'Baru', 'Diterima', 'Baru', 'Diterima'];
                final times = ['1 Jam yang lalu', '2 Jam yang lalu', '3 Jam yang lalu', '5 Jam yang lalu', '1 hari yang lalu'];
                final status = statuses[i % statuses.length];
                final timeAgo = times[i % times.length];
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const ProductImagePlaceholder(size: 72),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            StatusBadge.fromStatus(status),
                            const SizedBox(height: 4),
                            const Text('Beras Premium',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary)),
                            const Text('11.500/kg',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary)),
                            const Text('150 kg',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary)),
                            const SizedBox(height: 6),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                timeAgo,
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// FARMER - COUNTER OFFER (Negosiasi)
// Referensi: Screenshot 50 - counter offer page
// ─────────────────────────────────────────────
class FarmerCounterOfferPage extends StatefulWidget {
  const FarmerCounterOfferPage({super.key});

  @override
  State<FarmerCounterOfferPage> createState() =>
      _FarmerCounterOfferPageState();
}

class _FarmerCounterOfferPageState extends State<FarmerCounterOfferPage> {
  final _counterPriceCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  String? _action; // 'accept' | 'counter' | 'reject'

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryGreen),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Respon Negosiasi',
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryGreen),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Offer summary card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.backgroundGrey,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                children: [
                  DetailRow(
                      label: 'Nama Penawar', value: 'Putra Jaya'),
                  DetailRow(
                      label: 'Produk', value: 'Beras Premium 120kg'),
                  DetailRow(
                      label: 'Harga Awal Anda', value: 'Rp 12.000/kg'),
                  DetailRow(
                      label: 'Harga Ditawar', value: 'Rp 11.500/kg'),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Action options
            const Text('Pilih Tindakan',
                style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...[
              ('accept', 'Terima Tawaran', AppColors.primaryGreen),
              ('counter', 'Ajukan Counter Offer', AppColors.accentOrange),
              ('reject', 'Tolak Tawaran', AppColors.error),
            ].map(((String id, String label, Color color) item) {
              final (id, label, color) = item;
              final isSelected = _action == id;
              return GestureDetector(
                onTap: () => setState(() => _action = id),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? color : AppColors.borderColor,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(label, style: const TextStyle(fontSize: 14)),
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? color : AppColors.borderColor,
                            width: 2,
                          ),
                        ),
                        child: isSelected
                            ? Center(
                                child: Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: color,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              )
                            : null,
                      ),
                    ],
                  ),
                ),
              );
            }),

            if (_action == 'counter') ...[
              const SizedBox(height: 14),
              const Text('Harga Counter',
                  style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: Text('Rp',
                        style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary)),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _counterPriceCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: '11.800',
                        suffixText: '/kg',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: AppColors.borderColor)),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: AppColors.borderColor)),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 14),
            const Text('Catatan (Opsional)',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: _noteCtrl,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Tuliskan catatan...',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: AppColors.borderColor)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: AppColors.borderColor)),
                contentPadding: const EdgeInsets.all(14),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _action != null
                    ? () => Navigator.pushNamed(
                        context, '/farmer/active-offers')
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreenDark,
                  disabledBackgroundColor: AppColors.borderColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Kirim Respon'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// FARMER - HASIL PANEN
// Referensi: Screenshot 51 - stok summary + daftar panen list
// ─────────────────────────────────────────────
class FarmerHarvestPage extends StatelessWidget {
  const FarmerHarvestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryGreen),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Hasil Panen',
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryGreen),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary cards
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: _HarvestStatCard(
                      title: 'Total Panen',
                      value: '250 kg',
                      color: AppColors.primaryGreen,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _HarvestStatCard(
                      title: 'Stok Tersisa',
                      value: '130 kg',
                      color: AppColors.accentOrange,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _HarvestStatCard(
                      title: 'Terjual',
                      value: '120 kg',
                      color: AppColors.primaryGreenDark,
                    ),
                  ),
                ],
              ),
            ),

            // Input panen CTA
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Input Hasil Panen Baru'),
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreenDark,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Daftar Panen list
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('Daftar Panen',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 5,
              itemBuilder: (context, i) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const ProductImagePlaceholder(size: 60),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Beras Premium',
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold)),
                          const Text('250 kg • Bandung, Jawa Barat',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary)),
                          Text(
                            'Agustus ${2026 - i}',
                            style: const TextStyle(
                                fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        StatusBadge(
                            label: 'Tersedia', bgColor: AppColors.primaryGreen),
                        SizedBox(height: 4),
                        Text('130 kg',
                            style: TextStyle(
                                fontSize: 13, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HarvestStatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _HarvestStatCard({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 11, color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// FARMER - PENDAPATAN
// Referensi: Screenshot 52 - same layout as distributor income
// ─────────────────────────────────────────────
class FarmerIncomePage extends StatelessWidget {
  const FarmerIncomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryGreen),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Pendapatan',
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryGreen),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Total income card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total Pendapatan',
                      style: TextStyle(color: Colors.white, fontSize: 13)),
                  const SizedBox(height: 6),
                  const Text(
                    'Rp. 24.500.000',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Periode ini',
                          style: TextStyle(
                              color: Colors.white70, fontSize: 12)),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          children: [
                            Text('Agustus 2026',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12)),
                            SizedBox(width: 4),
                            Icon(Icons.keyboard_arrow_down,
                                color: Colors.white, size: 16),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            _FarmerIncomeMenu(
                title: 'Ringkasan Pendapatan',
                subtitle: 'Lihat ringkasan pendapatan anda',
                onTap: () {}),
            const SizedBox(height: 8),
            _FarmerIncomeMenu(
                title: 'Riwayat Pendapatan',
                subtitle: 'Lihat rdetail pemasukan',
                onTap: () {}),
            const SizedBox(height: 8),
            _FarmerIncomeMenu(
                title: 'Komisi & Keuangan',
                subtitle: 'Lihat komisi dan keuangan',
                onTap: () {}),
            const SizedBox(height: 8),
            _FarmerIncomeMenu(
                title: 'Metode Pembayaran',
                subtitle: 'Kelola metode pembayaran',
                onTap: () {}),
          ],
        ),
      ),
      bottomNavigationBar: CropChainBottomNav(
        currentIndex: 1,
        items: const [
          BottomNavItem(icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Home'),
          BottomNavItem(
              icon: Icons.account_balance_wallet_outlined, label: 'Income'),
          BottomNavItem(icon: Icons.person_outline, activeIcon: Icons.person, label: 'Profile'),
        ],
        onTap: (i) {
          if (i == 0) {
            Navigator.pushNamedAndRemoveUntil(
                context, '/farmer/home', (route) => false);
          } else if (i == 2) {
            Navigator.pushNamed(context, '/farmer/profile');
          }
        },
      ),
    );
  }
}

class _FarmerIncomeMenu extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _FarmerIncomeMenu({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.lightGreenBg2,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.bold)),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right,
                color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// FARMER - PROFILE PAGE
// ─────────────────────────────────────────────
class FarmerProfilePage extends StatelessWidget {
  const FarmerProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Profile',
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColors.primaryGreenLight,
                    child: Icon(Icons.person, color: Colors.white, size: 30),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Pak Asep',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                        Text('Petani',
                            style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary)),
                        Text('Bandung, Jawa Barat',
                            style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined,
                        color: AppColors.primaryGreen),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _FarmerProfileItem(
                icon: Icons.agriculture_outlined,
                label: 'Hasil Panen',
                onTap: () =>
                    Navigator.pushNamed(context, '/farmer/harvest')),
            _FarmerProfileItem(
                icon: Icons.local_offer_outlined,
                label: 'Tawaran Saya',
                onTap: () =>
                    Navigator.pushNamed(context, '/farmer/active-offers')),
            _FarmerProfileItem(
                icon: Icons.account_balance_wallet_outlined,
                label: 'Pendapatan',
                onTap: () =>
                    Navigator.pushNamed(context, '/farmer/income')),
            _FarmerProfileItem(
                icon: Icons.notifications_outlined,
                label: 'Notifikasi',
                onTap: () =>
                    Navigator.pushNamed(context, '/buyer/notifications')),
            _FarmerProfileItem(
                icon: Icons.help_outline,
                label: 'Bantuan & FAQ',
                onTap: () =>
                    Navigator.pushNamed(context, '/buyer/help')),
            const SizedBox(height: 12),
            // Switch role
            _FarmerProfileItem(
              icon: Icons.swap_horiz_rounded,
              label: 'Beralih ke Mode Pembeli',
              onTap: () => Navigator.pushNamedAndRemoveUntil(
                  context, '/buyer/home', (route) => false),
            ),
            const SizedBox(height: 4),
            _FarmerProfileItem(
              icon: Icons.logout,
              label: 'Keluar',
              textColor: AppColors.error,
              onTap: () => Navigator.pushNamedAndRemoveUntil(
                  context, '/splash', (route) => false),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CropChainBottomNav(
        currentIndex: 2,
        items: const [
          BottomNavItem(icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Home'),
          BottomNavItem(
              icon: Icons.account_balance_wallet_outlined, label: 'Income'),
          BottomNavItem(icon: Icons.person_outline, activeIcon: Icons.person, label: 'Profile'),
        ],
        onTap: (i) {
          if (i == 0) {
            Navigator.pushNamedAndRemoveUntil(
                context, '/farmer/home', (route) => false);
          } else if (i == 1) {
            Navigator.pushNamed(context, '/farmer/income');
          }
        },
      ),
    );
  }
}

class _FarmerProfileItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? textColor;

  const _FarmerProfileItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: textColor ?? AppColors.primaryGreen),
        title: Text(label,
            style: TextStyle(
                fontSize: 14,
                color: textColor ?? AppColors.textPrimary)),
        trailing: const Icon(Icons.chevron_right,
            color: AppColors.textSecondary),
        onTap: onTap,
      ),
    );
  }
}
