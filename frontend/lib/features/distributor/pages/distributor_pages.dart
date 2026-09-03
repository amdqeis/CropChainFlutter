import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/shared_widgets.dart';

// ─────────────────────────────────────────────
// DISTRIBUTOR HOME PAGE
// Referensi: Screenshot 45 - "Halo Distributor 👋 Welcome to CropChain"
// dengan menu: Lihat Tawaran Petani, Ringkasan Stok, Buat Produk Baru, Produk Aktif
// ─────────────────────────────────────────────
class DistributorHomePage extends StatefulWidget {
  const DistributorHomePage({super.key});

  @override
  State<DistributorHomePage> createState() => _DistributorHomePageState();
}

class _DistributorHomePageState extends State<DistributorHomePage> {
  int _currentNavIndex = 0;

  static const _recentFarmerOffers = [
    {
      'farmer': 'Pak Budi Santoso',
      'commodity': 'Cabai Merah Keriting',
      'amount': '500 kg — Rp 30.000/kg',
      'status': 'Baru',
    },
    {
      'farmer': 'Bu Siti Rahayu',
      'commodity': 'Tomat Cherry',
      'amount': '200 kg — Rp 18.000/kg',
      'status': 'Baru',
    },
  ];

  static const _recentOrders = [
    {
      'id': '#ORD-2026-001',
      'product': 'Cabai Merah Keriting',
      'buyer': 'Ahmad Fauzi',
      'total': 'Rp 150.000',
      'status': 'Diproses',
    },
    {
      'id': '#ORD-2026-002',
      'product': 'Tomat Cherry',
      'buyer': 'Dewi Kusuma',
      'total': 'Rp 90.000',
      'status': 'Dikirim',
    },
  ];

  void _onNavTap(int index) {
    setState(() => _currentNavIndex = index);
    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.pushNamed(context, '/distributor/income');
        break;
      case 2:
        Navigator.pushNamed(context, '/distributor/profile');
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
              'Halo Distributor 👋',
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
            const SizedBox(height: 14),

            // Ringkasan Hari ini card (matching Screenshot 25)
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
                                  'Pesanan Masuk',
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

            // Tawaran Terbaru dari Petani
            const Text(
              'Tawaran Terbaru',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.accentOrange,
              ),
            ),
            const SizedBox(height: 10),
            ..._recentFarmerOffers.map(
              (o) => _DistributorOfferPreviewCard(
                farmerName: o['farmer']!,
                commodity: o['commodity']!,
                amount: o['amount']!,
                status: o['status']!,
                onTap: () => Navigator.pushNamed(
                    context, '/distributor/farmer-offer-detail'),
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
                  icon: Icons.agriculture_outlined,
                  label: 'Lihat Tawaran Petani',
                  onTap: () =>
                      Navigator.pushNamed(context, '/distributor/farmer-offers'),
                ),
                MenuGridItem(
                  icon: Icons.inventory_2_outlined,
                  label: 'Ringkasan Stok',
                  onTap: () =>
                      Navigator.pushNamed(context, '/distributor/stock'),
                ),
                MenuGridItem(
                  icon: Icons.add_box_outlined,
                  label: 'Buat Produk Baru',
                  onTap: () =>
                      Navigator.pushNamed(context, '/distributor/create-product'),
                ),
                MenuGridItem(
                  icon: Icons.storefront_outlined,
                  label: 'Produk Aktif',
                  onTap: () =>
                      Navigator.pushNamed(context, '/distributor/active-products'),
                ),
                MenuGridItem(
                  icon: Icons.shopping_bag_outlined,
                  label: 'Pesanan Masuk',
                  onTap: () =>
                      Navigator.pushNamed(context, '/distributor/orders'),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Pesanan Masuk Terbaru
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Pesanan Masuk Terbaru',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.accentOrange,
                  ),
                ),
                GestureDetector(
                  onTap: () =>
                      Navigator.pushNamed(context, '/distributor/orders'),
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
            ..._recentOrders.map(
              (o) => _DistributorRecentOrderCard(
                orderId: o['id']!,
                product: o['product']!,
                buyer: o['buyer']!,
                total: o['total']!,
                status: o['status']!,
                onTap: () =>
                    Navigator.pushNamed(context, '/distributor/order-detail'),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CropChainBottomNav(
        currentIndex: _currentNavIndex,
        items: const [
          BottomNavItem(icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Home'),
          BottomNavItem(icon: Icons.account_balance_wallet_outlined, activeIcon: Icons.account_balance_wallet, label: 'Income'),
          BottomNavItem(icon: Icons.person_outline, activeIcon: Icons.person, label: 'Profile'),
        ],
        onTap: _onNavTap,
      ),
    );
  }
}

// ─────────────────────────────────────────────
// DISTRIBUTOR HOME — Offer Preview Card
// ─────────────────────────────────────────────
class _DistributorOfferPreviewCard extends StatelessWidget {
  final String farmerName;
  final String commodity;
  final String amount;
  final String status;
  final VoidCallback onTap;

  const _DistributorOfferPreviewCard({
    required this.farmerName,
    required this.commodity,
    required this.amount,
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
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.lightGreenBg,
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(Icons.agriculture_outlined,
                  color: AppColors.primaryGreen, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    farmerName,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    commodity,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    amount,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.primaryGreen),
                  ),
                ],
              ),
            ),
            StatusBadge.fromStatus(status),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right,
                size: 18, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// DISTRIBUTOR HOME — Recent Order Card
// ─────────────────────────────────────────────
class _DistributorRecentOrderCard extends StatelessWidget {
  final String orderId;
  final String product;
  final String buyer;
  final String total;
  final String status;
  final VoidCallback onTap;

  const _DistributorRecentOrderCard({
    required this.orderId,
    required this.product,
    required this.buyer,
    required this.total,
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
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.lightGreenBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.shopping_bag_outlined,
                  color: AppColors.primaryGreen, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    orderId,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textSecondary),
                  ),
                  Text(
                    product,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'Pembeli: $buyer  •  $total',
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            StatusBadge.fromStatus(status),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right,
                size: 18, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// DISTRIBUTOR - LIHAT TAWARAN PETANI
// Referensi: Screenshot farmer offers list (dari distributor)
// ─────────────────────────────────────────────
class DistributorFarmerOffersPage extends StatefulWidget {
  const DistributorFarmerOffersPage({super.key});

  @override
  State<DistributorFarmerOffersPage> createState() =>
      _DistributorFarmerOffersPageState();
}

class _DistributorFarmerOffersPageState
    extends State<DistributorFarmerOffersPage> {
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
          'Tawaran Petani',
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
            child: Column(
              children: [
                const CropChainSearchBar(),
                const SizedBox(height: 12),
                FilterChipRow(
                  items: const ['Semua', 'Baru', 'Diproses', 'Selesai', 'Dibatalkan'],
                  selected: _filter,
                  onSelected: (v) => setState(() => _filter = v),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 5,
              itemBuilder: (context, i) => _FarmerOfferCard(
                onTap: () => Navigator.pushNamed(
                    context, '/distributor/farmer-offer-detail'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FarmerOfferCard extends StatelessWidget {
  final VoidCallback onTap;
  const _FarmerOfferCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                const ProductImagePlaceholder(size: 70),
                const Positioned(
                  top: -4,
                  left: -4,
                  child: ProductImagePlaceholder(size: 70),
                ),
                const Positioned(
                  top: -8,
                  left: -8,
                  child: ProductImagePlaceholder(size: 70),
                ),
              ],
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const StatusBadge(label: 'Baru'),
                      const Spacer(),
                      const Text('1 jam',
                          style: TextStyle(
                              fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text('Order ID - 12345689',
                      style: TextStyle(
                          fontSize: 13, fontWeight: FontWeight.bold)),
                  const Text('Beras Premium',
                      style: TextStyle(
                          fontSize: 12, color: AppColors.textSecondary)),
                  const Text('5 kg',
                      style: TextStyle(
                          fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(height: 4),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text('Total 4 Produk: ',
                          style: TextStyle(
                              fontSize: 12, color: AppColors.textSecondary)),
                      Text('75.000',
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.bold)),
                    ],
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
// DISTRIBUTOR - RINGKASAN STOK
// Referensi: Screenshot 31 - header chips + "Daftar Stok" list
// ─────────────────────────────────────────────
class DistributorStockPage extends StatelessWidget {
  const DistributorStockPage({super.key});

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
          'Ringkasan Stok',
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryGreen),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary chips (3 stat boxes)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: List.generate(
                3,
                (i) => Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    height: 70,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderColor),
                    ),
                  ),
                ),
              ),
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Daftar Stok',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 6,
              itemBuilder: (context, i) => GestureDetector(
                onTap: () =>
                    Navigator.pushNamed(context, '/distributor/stock-detail'),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.borderColor, width: 0.5),
                  ),
                  child: Row(
                    children: [
                      const ProductImagePlaceholder(size: 56, borderRadius: 8),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text('Daftar Stok',
                            style: TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w500)),
                      ),
                      const Text('120 kg',
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// DISTRIBUTOR - DETAIL STOK
// Referensi: Screenshot 32 - hero image, "Beras Premium" 120 kg Tersedia, stats + CTA
// ─────────────────────────────────────────────
class DistributorStockDetailPage extends StatelessWidget {
  const DistributorStockDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 260,
            backgroundColor: AppColors.white,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.primaryGreen),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(color: const Color(0xFFEEEEEE)),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              color: AppColors.backgroundGrey,
              child: Column(
                children: [
                  Container(
                    color: AppColors.white,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Beras Premium',
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        Row(
                          children: [
                            const Text('120 kg',
                                style: TextStyle(fontSize: 14)),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.primaryGreen,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text('Tersedia',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 11)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const DetailRow(label: 'Total Stok', value: '120kg'),
                        const DetailRow(label: 'Jumlah', value: '70kg'),
                        const DetailRow(
                            label: 'Nilai stok', value: 'Rp 600.000'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.white,
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: () =>
                Navigator.pushNamed(context, '/distributor/create-product'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreenDark,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Jual Stok Ini'),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// DISTRIBUTOR - BUAT PRODUK BARU (Wizard)
// Referensi: Screenshot 33 - wizard steps: Input Informasi, Stok & Harga, Konfirmasi
// ─────────────────────────────────────────────
class DistributorCreateProductPage extends StatefulWidget {
  const DistributorCreateProductPage({super.key});

  @override
  State<DistributorCreateProductPage> createState() =>
      _DistributorCreateProductPageState();
}

class _DistributorCreateProductPageState
    extends State<DistributorCreateProductPage> {
  int _step = 0;

  final _steps = ['Input Informasi', 'Stok & Harga', 'Konfirmasi'];

  // Step 1 controllers
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String? _category;
  String? _location;

  // Step 2 controllers
  final _stockCtrl = TextEditingController();
  final _publicPriceCtrl = TextEditingController();
  final _marketPriceCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: _step > 0
          ? AppBar(
              backgroundColor: AppColors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.primaryGreen),
                onPressed: () => setState(() => _step--),
              ),
              title: Text(
                _steps[_step],
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryGreen),
              ),
            )
          : null,
      body: _step == 0
          ? _buildWizardOverview()
          : _step == 1
              ? _buildStep1()
              : _buildStep2(),
    );
  }

  Widget _buildWizardOverview() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Buat Produk Baru',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            ...List.generate(_steps.length, (i) {
              final isActive = i == 0;
              return _WizardStep(
                index: i + 1,
                label: _steps[i],
                isActive: isActive,
                isLast: i == _steps.length - 1,
                onTap: isActive ? () => setState(() => _step = 1) : null,
              );
            }),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.borderColor),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Batalkan',
                    style: TextStyle(color: AppColors.textSecondary)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel('Nama Produk'),
          _buildTextField(_nameCtrl, '11.500'),
          const SizedBox(height: 14),
          _buildLabel('Deskripsi'),
          _buildTextField(_descCtrl, ''),
          const SizedBox(height: 14),
          _buildLabel('kategori'),
          _buildDropdown('kategori', _category, (v) => setState(() => _category = v)),
          const SizedBox(height: 14),
          _buildLabel('Lokasi Produk'),
          _buildDropdown('Lokasi', _location, (v) => setState(() => _location = v)),
          const SizedBox(height: 14),
          _buildLabel('Foto Produk'),
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
          const SizedBox(height: 30),
          Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              width: 120,
              height: 46,
              child: ElevatedButton(
                onPressed: () => setState(() => _step = 2),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreenDark,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Terima'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLabel('Stok yang akan dijual'),
                _buildTextFieldWithUnit(_stockCtrl, '11.500', '/kg'),
                const SizedBox(height: 14),
                _buildLabel('Harga Jual untuk Publik'),
                _buildTextFieldWithUnit(_publicPriceCtrl, '', '/kg'),
                const SizedBox(height: 14),
                _buildLabel('Harga Jual untuk Pasar Induk'),
                _buildTextFieldWithUnit(_marketPriceCtrl, '', '/kg'),
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
                  Navigator.pushNamed(context, '/distributor/product-created'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreenDark,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Simpan & Tampilkan'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text,
          style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary)),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String hint) {
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

  Widget _buildTextFieldWithUnit(
      TextEditingController ctrl, String hint, String unit) {
    return TextField(
      controller: ctrl,
      decoration: InputDecoration(
        hintText: hint,
        suffixText: unit,
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

  Widget _buildDropdown(
      String hint, String? value, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      hint: Text(hint),
      decoration: InputDecoration(
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.borderColor)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.borderColor)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      items: const [
        DropdownMenuItem(value: 'Beras', child: Text('Beras')),
        DropdownMenuItem(value: 'Sayur', child: Text('Sayur')),
        DropdownMenuItem(value: 'Buah', child: Text('Buah')),
      ],
      onChanged: onChanged,
    );
  }
}

class _WizardStep extends StatelessWidget {
  final int index;
  final String label;
  final bool isActive;
  final bool isLast;
  final VoidCallback? onTap;

  const _WizardStep({
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
                  color: isActive ? AppColors.primaryGreen : AppColors.lightGreenBg2,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$index',
                    style: TextStyle(
                      color:
                          isActive ? Colors.white : AppColors.textSecondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
            if (!isLast)
              Container(width: 2, height: 40, color: AppColors.borderColor),
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
// DISTRIBUTOR - PRODUK BERHASIL DIBUAT
// Referensi: Screenshot 36 - success screen
// ─────────────────────────────────────────────
class DistributorProductCreatedPage extends StatelessWidget {
  const DistributorProductCreatedPage({super.key});

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
              const Text(
                'Produk Berhasil dibuat',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: AppColors.primaryGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 44),
              ),
              const SizedBox(height: 24),
              const Text(
                'Produk berhasil dibuat!',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryGreen),
              ),
              const SizedBox(height: 6),
              const Text(
                'Beras premium siap dijual',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              const DetailRow(label: 'Stok yang akan dijual', value: 'Beras pulen'),
              const DetailRow(label: 'Harga Jual untuk Publik', value: '120kg'),
              const DetailRow(
                  label: 'Harga Jual untuk Pasar Induk', value: 'Rp 13.500/kg'),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, '/distributor/active-products'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreenDark,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Lihat Produk'),
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
// DISTRIBUTOR - PRODUK AKTIF LIST
// Referensi: Screenshot 37 - search + list with Aktif/Nonaktif badge
// ─────────────────────────────────────────────
class DistributorActiveProductsPage extends StatelessWidget {
  const DistributorActiveProductsPage({super.key});

  static const _items = [
    ('Beras Premium', true),
    ('Beras Premium', false),
    ('Beras Premium', true),
    ('Beras Premium', false),
  ];

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
          'Produk Aktif',
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryGreen),
        ),
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: CropChainSearchBar(),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _items.length,
              itemBuilder: (context, i) {
                final (name, isActive) = _items[i];
                return GestureDetector(
                  onTap: () => Navigator.pushNamed(
                      context, '/distributor/product-detail'),
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
                              Text(name,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold)),
                              const Text('Pak Asep',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary)),
                              const Text('Bandung, Jawa Barat',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary)),
                              const Text('Rp 12.000/ kg',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                        StatusBadge.fromStatus(isActive ? 'Aktif' : 'Nonaktif'),
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
// DISTRIBUTOR - PRODUCT DETAIL (own listing)
// Referensi: Screenshot 38 - hero + "Beras Premium" details + 2 CTAs
// ─────────────────────────────────────────────
class DistributorProductDetailPage extends StatelessWidget {
  const DistributorProductDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 260,
            backgroundColor: AppColors.white,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.primaryGreen),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(color: const Color(0xFFEEEEEE)),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Beras Premium',
                      style: TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold)),
                  Text('50 kg',
                      style: TextStyle(
                          fontSize: 14, color: AppColors.textSecondary)),
                  SizedBox(height: 16),
                  DetailRow(label: 'Stok Tersedia', value: 'Beras pulen'),
                  DetailRow(label: 'Harga Jual untuk (Publik)', value: '120kg'),
                  DetailRow(
                      label: 'Harga Jual untuk (Pasar Induk)',
                      value: 'Rp 13.500/kg'),
                  DetailRow(
                      label: 'Status',
                      value: 'Aktif',
                      valueColor: AppColors.primaryGreen),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: Colors.white,
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, '/distributor/change-product-status'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentOrange,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Ubah Status'),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 48,
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primaryGreen),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Nonaktifkan'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// DISTRIBUTOR - UBAH STATUS PRODUK
// Referensi: Screenshot 39 - Aktif / Nonaktif radio
// ─────────────────────────────────────────────
class DistributorChangeProductStatusPage extends StatelessWidget {
  const DistributorChangeProductStatusPage({super.key});

  @override
  Widget build(BuildContext context) {
    return UbahStatusPage(
      title: 'Ubah Status',
      options: const ['Aktif', 'Nonaktif'],
      initialSelected: 'Aktif',
      onSave: (status, _) => Navigator.pop(context),
    );
  }
}

// ─────────────────────────────────────────────
// DISTRIBUTOR - PESANAN MASUK
// Referensi: Screenshot 40 - filter chips + order cards
// ─────────────────────────────────────────────
class DistributorOrdersPage extends StatefulWidget {
  const DistributorOrdersPage({super.key});

  @override
  State<DistributorOrdersPage> createState() => _DistributorOrdersPageState();
}

class _DistributorOrdersPageState extends State<DistributorOrdersPage> {
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
          'Pesanan Masuk',
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
            child: Column(
              children: [
                const CropChainSearchBar(),
                const SizedBox(height: 10),
                FilterChipRow(
                  items: const ['Semua', 'Baru', 'Diproses', 'Selesai', 'Dibatalkan'],
                  selected: _filter,
                  onSelected: (v) => setState(() => _filter = v),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 1,
              itemBuilder: (context, i) => GestureDetector(
                onTap: () =>
                    Navigator.pushNamed(context, '/distributor/order-detail'),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          const ProductImagePlaceholder(size: 70),
                          const Positioned(
                            top: -4, left: -4,
                            child: ProductImagePlaceholder(size: 70),
                          ),
                          const Positioned(
                            top: -8, left: -8,
                            child: ProductImagePlaceholder(size: 70),
                          ),
                        ],
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: const [
                                StatusBadge(label: 'Baru'),
                                Spacer(),
                                Text('1 jam',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            const Text('Order ID - 12345689',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold)),
                            const Text('Beras Premium',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary)),
                            const Text('5 kg',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary)),
                            const SizedBox(height: 4),
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text('Total 4 Produk: ',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary)),
                                Text('75.000',
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// DISTRIBUTOR - DETAIL PESANAN
// Referensi: Screenshot 41 - Order ID, Info Pembeli, Barang dipesan, Rincian
// ─────────────────────────────────────────────
class DistributorOrderDetailPage extends StatelessWidget {
  const DistributorOrderDetailPage({super.key});

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
          'Detail Pesanan',
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
            // Header
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('Order ID - 12345689',
                      style: TextStyle(
                          fontSize: 13, fontWeight: FontWeight.bold)),
                  StatusBadge(label: 'Baru'),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Info pembeli
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('Info Pembeli',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold)),
                      Text('Beras Premium',
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const Divider(),
                  const DetailRow(label: 'Nama', value: 'Bu Susi'),
                  const DetailRow(label: 'No handphone', value: '+12345678'),
                  const DetailRow(
                      label: 'Alamat kirim', value: 'Sukapura, Bandung'),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Barang dipesan
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Barang yang dipesan',
                      style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Row(
                    children: const [
                      ProductImagePlaceholder(size: 56),
                      SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Beras Premium',
                              style: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.bold)),
                          Text('5 kg',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary)),
                        ],
                      ),
                    ],
                  ),
                  const Divider(),
                  const DetailRow(
                      label: 'Rincian Pembiayaan',
                      value: 'Rp 1.440.000',
                      bold: true),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.white,
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: () =>
                Navigator.pushNamed(context, '/distributor/change-order-status'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreenDark,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Proses Pesanan'),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// DISTRIBUTOR - UBAH STATUS PESANAN
// Referensi: Screenshot 42 - Diproses, Dikirim, Selesai, Dibatalkan + Catatan
// ─────────────────────────────────────────────
class DistributorChangeOrderStatusPage extends StatelessWidget {
  const DistributorChangeOrderStatusPage({super.key});

  @override
  Widget build(BuildContext context) {
    return UbahStatusPage(
      title: 'Ubah Status',
      options: const ['Diproses', 'Dikirim', 'Selesai', 'Dibatalkan'],
      initialSelected: 'Diproses',
      showNote: true,
      onSave: (status, catatan) =>
          Navigator.pushNamed(context, '/distributor/order-shipped'),
    );
  }
}

// ─────────────────────────────────────────────
// DISTRIBUTOR - PESANAN DIKIRIM SUCCESS
// Referensi: Screenshot 43 - truck icon + "Pesanan berhasil diperbarui!"
// ─────────────────────────────────────────────
class DistributorOrderShippedPage extends StatelessWidget {
  const DistributorOrderShippedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back,
                      color: AppColors.primaryGreen),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const Spacer(),
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: AppColors.lightGreenBg,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.local_shipping_outlined,
                    color: AppColors.primaryGreen, size: 40),
              ),
              const SizedBox(height: 20),
              const Text(
                'Pesanan Dikirim',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'Pesanan berhasil diperbarui!',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryGreen),
              ),
              const SizedBox(height: 6),
              const Text(
                'Status pesanan telah diubah menjadi',
                style:
                    TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 4),
              const Text(
                'Dikirim',
                style:
                    TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, '/distributor/orders'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreenDark,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Lihat Pesanan'),
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
// DISTRIBUTOR - PENDAPATAN
// Referensi: Screenshot 44 - green card total + 4 menu items + bottom nav
// ─────────────────────────────────────────────
class DistributorIncomePage extends StatelessWidget {
  const DistributorIncomePage({super.key});

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
                          style: TextStyle(color: Colors.white70, fontSize: 12)),
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

            // Menu items
            _IncomeMenuItem(
              title: 'Ringkasan Pendapatan',
              subtitle: 'Lihat ringkasan pendapatan anda',
              onTap: () {},
            ),
            const SizedBox(height: 8),
            _IncomeMenuItem(
              title: 'Riwayat Pendapatan',
              subtitle: 'Lihat rdetail pemasukan',
              onTap: () {},
            ),
            const SizedBox(height: 8),
            _IncomeMenuItem(
              title: 'Komisi & Keuangan',
              subtitle: 'Lihat komisi dan keuangan',
              onTap: () {},
            ),
            const SizedBox(height: 8),
            _IncomeMenuItem(
              title: 'Metode Pembayaran',
              subtitle: 'Kelola metode pembayaran',
              onTap: () {},
            ),
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
                context, '/distributor/home', (route) => false);
          } else if (i == 2) {
            Navigator.pushNamed(context, '/distributor/profile');
          }
        },
      ),
    );
  }
}

class _IncomeMenuItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _IncomeMenuItem({
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
            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// DISTRIBUTOR - PROFILE PAGE
// ─────────────────────────────────────────────
class DistributorProfilePage extends StatelessWidget {
  const DistributorProfilePage({super.key});

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
                    backgroundColor: AppColors.accentOrange,
                    child:
                        Icon(Icons.person, color: Colors.white, size: 30),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Putra Jaya',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        Text('Distributor',
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
            _DistProfileItem(
                icon: Icons.inventory_2_outlined,
                label: 'Produk Saya',
                onTap: () =>
                    Navigator.pushNamed(context, '/distributor/active-products')),
            _DistProfileItem(
                icon: Icons.shopping_bag_outlined,
                label: 'Pesanan',
                onTap: () =>
                    Navigator.pushNamed(context, '/distributor/orders')),
            _DistProfileItem(
                icon: Icons.account_balance_wallet_outlined,
                label: 'Pendapatan',
                onTap: () =>
                    Navigator.pushNamed(context, '/distributor/income')),
            _DistProfileItem(
                icon: Icons.notifications_outlined,
                label: 'Notifikasi',
                onTap: () =>
                    Navigator.pushNamed(context, '/buyer/notifications')),
            _DistProfileItem(
                icon: Icons.help_outline,
                label: 'Bantuan & FAQ',
                onTap: () =>
                    Navigator.pushNamed(context, '/buyer/help')),
            const SizedBox(height: 12),
            // Switch role section
            _DistProfileItem(
              icon: Icons.swap_horiz_rounded,
              label: 'Beralih ke Mode Pembeli',
              onTap: () => Navigator.pushNamedAndRemoveUntil(
                  context, '/buyer/home', (route) => false),
            ),
            const SizedBox(height: 4),
            _DistProfileItem(
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
                context, '/distributor/home', (route) => false);
          } else if (i == 1) {
            Navigator.pushNamed(context, '/distributor/income');
          }
        },
      ),
    );
  }
}

class _DistProfileItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? textColor;

  const _DistProfileItem({
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
                fontSize: 14, color: textColor ?? AppColors.textPrimary)),
        trailing: const Icon(Icons.chevron_right,
            color: AppColors.textSecondary),
        onTap: onTap,
      ),
    );
  }
}

// ─────────────────────────────────────────────
// DISTRIBUTOR - FARMER OFFER DETAIL
// (dari sisi distributor melihat tawaran petani)
// ─────────────────────────────────────────────
class DistributorFarmerOfferDetailPage extends StatelessWidget {
  const DistributorFarmerOfferDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 240,
            backgroundColor: AppColors.white,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back,
                  color: AppColors.primaryGreen),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(color: const Color(0xFFEEEEEE)),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Beras Premium',
                      style: TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  const DetailRow(
                      label: 'Nama Penawar', value: 'Putra Jaya'),
                  const DetailRow(label: 'Jumlah', value: '120kg'),
                  const DetailRow(
                      label: 'Harga Sebelumnya', value: 'Rp 12.000/kg'),
                  const DetailRow(
                      label: 'Harga Tawar', value: 'Rp 11.500/kg'),
                  const DetailRow(
                      label: 'Lokasi', value: 'Bandung, Jawa Barat'),
                  const SizedBox(height: 10),
                  const Text('Catatan Penawar:',
                      style: TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  const Text(
                    'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
                    style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        height: 1.5),
                  ),
                  const SizedBox(height: 16),
                  const Text('Catatan (Opsional)',
                      style: TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  TextField(
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Tuliskan catatan untuk petani...',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: AppColors.borderColor)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: AppColors.borderColor)),
                      contentPadding: const EdgeInsets.all(14),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: Colors.white,
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentOrange,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Tolak'),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreenDark,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Terima'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
