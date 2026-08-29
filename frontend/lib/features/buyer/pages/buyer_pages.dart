import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/shared_widgets.dart';

// ─────────────────────────────────────────────
// BUYER HOME PAGE
// Referensi: Screenshot buyer home - Good Morning, Ara | Welcome to CropChain
// ─────────────────────────────────────────────
class BuyerHomePage extends StatefulWidget {
  const BuyerHomePage({super.key});

  @override
  State<BuyerHomePage> createState() => _BuyerHomePageState();
}

class _BuyerHomePageState extends State<BuyerHomePage> {
  int _currentNavIndex = 0;

  final _buyerMenus = [
    const _MenuData(icon: Icons.store_outlined, label: 'Toko'),
    const _MenuData(icon: Icons.category_outlined, label: 'Kategori'),
    const _MenuData(icon: Icons.history_outlined, label: 'Riwayat'),
    const _MenuData(icon: Icons.local_offer_outlined, label: 'Promo'),
  ];

  void _navigate(int index) {
    setState(() => _currentNavIndex = index);
    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.pushNamed(context, '/buyer/shop');
        break;
      case 2:
        Navigator.pushNamed(context, '/buyer/cart');
        break;
      case 3:
        Navigator.pushNamed(context, '/buyer/profile');
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
              'Good Morning, Ara 👋',
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
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 14),

            // Search bar (read-only, navigates to search)
            CropChainSearchBar(
              readOnly: true,
              onTap: () => Navigator.pushNamed(context, '/buyer/search'),
            ),
            const SizedBox(height: 16),

            // Banner / Hero image placeholder
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/buyer/shop'),
              child: Container(
                height: 160,
                decoration: BoxDecoration(
                  color: AppColors.lightGreenBg2,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderColor),
                ),
                child: Stack(
                  children: [
                    const Align(
                      alignment: Alignment.bottomRight,
                      child: Padding(
                        padding: EdgeInsets.all(14),
                        child: _ShopNowButton(),
                      ),
                    ),
                  ],
                ),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: _buyerMenus
                  .map((m) => MenuGridItem(
                        icon: m.icon,
                        label: m.label,
                        onTap: () {},
                      ))
                  .toList(),
            ),
            const SizedBox(height: 20),

            // Produk Populer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Produk Populer',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.accentOrange,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/buyer/shop'),
                  child: const Row(
                    children: [
                      Text(
                        'See all',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Icon(Icons.chevron_right,
                          size: 16, color: AppColors.textSecondary),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 120,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: 3,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, i) => GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/buyer/product-detail'),
                  child: const ProductImagePlaceholder(size: 110),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CropChainBottomNav(
        currentIndex: _currentNavIndex,
        items: const [
          BottomNavItem(icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Home'),
          BottomNavItem(icon: Icons.store_outlined, activeIcon: Icons.store, label: 'Shop'),
          BottomNavItem(icon: Icons.shopping_cart_outlined, activeIcon: Icons.shopping_cart, label: 'Cart'),
          BottomNavItem(icon: Icons.person_outline, activeIcon: Icons.person, label: 'Profile'),
        ],
        onTap: _navigate,
      ),
    );
  }
}

class _ShopNowButton extends StatelessWidget {
  const _ShopNowButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Shop Now',
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary),
          ),
          SizedBox(width: 4),
          Icon(Icons.chevron_right, size: 16, color: AppColors.textPrimary),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// BUYER SEARCH PAGE
// Referensi: Screenshot search - dengan "Riwayat Pencarian" chips dan "Populer"
// ─────────────────────────────────────────────
class BuyerSearchPage extends StatefulWidget {
  const BuyerSearchPage({super.key});

  @override
  State<BuyerSearchPage> createState() => _BuyerSearchPageState();
}

class _BuyerSearchPageState extends State<BuyerSearchPage> {
  final _ctrl = TextEditingController();

  final _historyChips = [
    'Alamat kirim',
    'Alamat kirim',
    'Alamat kirim',
    'Alamat kirim',
  ];

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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Alamat kirim',
              style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
            ),
            Row(
              children: [
                const Text(
                  'Telkom University',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.keyboard_arrow_down,
                    size: 18, color: AppColors.textSecondary),
              ],
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CropChainSearchBar(controller: _ctrl),
            const SizedBox(height: 20),
            const Text(
              'Riwayat Pencarian',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _historyChips
                  .map((c) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.borderColor),
                        ),
                        child: Text(c,
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.textSecondary)),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 20),
            const Text(
              'Populer',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// BUYER SHOP / PRODUCT LIST PAGE
// Referensi: Screenshot product list - grid 2 kolom dengan harga + cart button
// ─────────────────────────────────────────────
class BuyerShopPage extends StatefulWidget {
  const BuyerShopPage({super.key});

  @override
  State<BuyerShopPage> createState() => _BuyerShopPageState();
}

class _BuyerShopPageState extends State<BuyerShopPage> {
  final _ctrl = TextEditingController();

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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Alamat kirim',
              style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
            ),
            const Row(
              children: [
                Text(
                  'Telkom University',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(width: 4),
                Icon(Icons.keyboard_arrow_down,
                    size: 18, color: AppColors.textSecondary),
              ],
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CartFab(
              onTap: () => Navigator.pushNamed(context, '/buyer/cart'),
              count: 2,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: CropChainSearchBar(controller: _ctrl),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.72,
              ),
              itemCount: 8,
              itemBuilder: (context, i) =>
                  _ProductCard(onTap: () => Navigator.pushNamed(context, '/buyer/product-detail')),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final VoidCallback onTap;
  const _ProductCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFEEEEEE),
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '15.000',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(Icons.add,
                        color: Colors.white, size: 18),
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
// BUYER PRODUCT DETAIL PAGE
// Referensi: Screenshot product detail - hero image, info, distributor, reviews
// ─────────────────────────────────────────────
class BuyerProductDetailPage extends StatelessWidget {
  const BuyerProductDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            backgroundColor: AppColors.white,
            pinned: true,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back,
                    color: AppColors.primaryGreen, size: 20),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: CartFab(
                  onTap: () => Navigator.pushNamed(context, '/buyer/cart'),
                  count: 2,
                ),
              ),
            ],
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
                  // Title + Rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Beras Premium',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star,
                              color: AppColors.starYellow, size: 18),
                          const Text(
                            ' 5.0',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '15.000',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '15 Stok Tersedia',
                        style: TextStyle(
                            fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),

                  // Deskripsi
                  const Text(
                    'Deskripsi',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
                    style: TextStyle(
                        fontSize: 13, color: AppColors.textSecondary, height: 1.5),
                  ),
                  const SizedBox(height: 16),

                  // Info section
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundGrey,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Informasi',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        DetailRow(label: 'Asal produk', value: 'Bandung, Jawa Barat'),
                        DetailRow(label: 'Jenis', value: 'Beras pulen'),
                        DetailRow(label: 'Berat', value: '1kg'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Distributor info
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(
                          color: AppColors.accentOrange,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('PUTRA JAYA',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold)),
                            Row(
                              children: [
                                Icon(Icons.star,
                                    color: AppColors.starYellow, size: 14),
                                Text(' 5.0  Bandung, Jawa Barat',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chat_bubble_outline,
                          color: AppColors.textSecondary, size: 22),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),

                  // Rating section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Text('5.0',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                          SizedBox(width: 4),
                          Icon(Icons.star,
                              color: AppColors.starYellow, size: 20),
                          SizedBox(width: 8),
                          Text('Penilaian Produk',
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: const Text('Lihat Semua',
                            style: TextStyle(
                                fontSize: 12, color: AppColors.textSecondary)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Review items
                  ...List.generate(2, (i) => _ReviewItem()),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.borderColor)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primaryGreen),
              ),
              child: const Icon(Icons.shopping_cart_outlined,
                  color: AppColors.primaryGreen),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/buyer/checkout'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreenDark,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Beli Sekarang'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: AppColors.accentOrange,
              ),
              SizedBox(width: 8),
              Text('Lihat Semua',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 4),
          const Row(
            children: [
              Icon(Icons.star, color: AppColors.starYellow, size: 14),
              Icon(Icons.star, color: AppColors.starYellow, size: 14),
              Icon(Icons.star, color: AppColors.starYellow, size: 14),
              Icon(Icons.star, color: AppColors.starYellow, size: 14),
              Icon(Icons.star, color: AppColors.starYellow, size: 14),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const ProductImagePlaceholder(size: 60, borderRadius: 8),
              const SizedBox(width: 8),
              const ProductImagePlaceholder(size: 60, borderRadius: 8),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// BUYER CART PAGE
// Referensi: Screenshot 24 - Keranjang dengan checkbox, nama produk, qty stepper orange
// ─────────────────────────────────────────────
class BuyerCartPage extends StatefulWidget {
  const BuyerCartPage({super.key});

  @override
  State<BuyerCartPage> createState() => _BuyerCartPageState();
}

class _BuyerCartPageState extends State<BuyerCartPage> {
  // Cart items: [checked, qty]
  final List<_CartItem> _items = [
    _CartItem(name: 'Beras Premium', description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.', qty: 4),
    _CartItem(name: 'Beras Premium', description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.', qty: 4),
  ];
  bool _selectAll = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Keranjang',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Alamat kirim',
                    style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text('Telkom University',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary)),
                    Icon(Icons.keyboard_arrow_down,
                        size: 16, color: AppColors.textSecondary),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _items.isEmpty
                ? const Center(
                    child: Text('Keranjang kosong',
                        style: TextStyle(color: AppColors.textSecondary)))
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
                    itemCount: _items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final item = _items[i];
                      return Container(
                        color: AppColors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Checkbox
                            GestureDetector(
                              onTap: () => setState(() => item.checked = !item.checked),
                              child: Container(
                                width: 20,
                                height: 20,
                                margin: const EdgeInsets.only(top: 2),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: item.checked
                                        ? AppColors.accentOrange
                                        : AppColors.borderColor,
                                    width: 1.5,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: item.checked
                                    ? const Icon(Icons.check,
                                        size: 14,
                                        color: AppColors.accentOrange)
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 10),
                            // Product image
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: const Color(0xFFEEEEEE),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.borderColor),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Product info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(item.name,
                                                style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    color: AppColors.textPrimary)),
                                            const SizedBox(height: 4),
                                            Text(item.description,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                    fontSize: 11,
                                                    color: AppColors.textSecondary)),
                                          ],
                                        ),
                                      ),
                                      // Qty stepper — orange
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          _OrangeQtyBtn(
                                            icon: Icons.remove,
                                            onTap: () {
                                              if (item.qty > 1) {
                                                setState(() => item.qty--);
                                              }
                                            },
                                          ),
                                          Container(
                                            width: 28,
                                            height: 28,
                                            decoration: BoxDecoration(
                                              color: AppColors.accentOrange,
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            alignment: Alignment.center,
                                            child: Text(
                                              '${item.qty}',
                                              style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white),
                                            ),
                                          ),
                                          _OrangeQtyBtn(
                                            icon: Icons.add,
                                            onTap: () =>
                                                setState(() => item.qty++),
                                          ),
                                        ],
                                      ),
                                    ],
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

          // Bottom bar: checkbox Semua + Checkout orange
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppColors.borderColor)),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => setState(() {
                    _selectAll = !_selectAll;
                    for (final item in _items) {
                      item.checked = _selectAll;
                    }
                  }),
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _selectAll
                            ? AppColors.accentOrange
                            : AppColors.borderColor,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: _selectAll
                        ? const Icon(Icons.check,
                            size: 14, color: AppColors.accentOrange)
                        : null,
                  ),
                ),
                const SizedBox(width: 8),
                const Text('Semua',
                    style:
                        TextStyle(fontSize: 14, color: AppColors.textPrimary)),
                const Spacer(),
                SizedBox(
                  height: 46,
                  child: ElevatedButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, '/buyer/checkout'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentOrange,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                    ),
                    child: const Text(
                      'Checkout',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: CropChainBottomNav(
        currentIndex: 2,
        items: const [
          BottomNavItem(icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Home'),
          BottomNavItem(icon: Icons.store_outlined, activeIcon: Icons.store, label: 'Shop'),
          BottomNavItem(icon: Icons.shopping_cart_outlined, activeIcon: Icons.shopping_cart, label: 'Cart'),
          BottomNavItem(icon: Icons.person_outline, activeIcon: Icons.person, label: 'Profile'),
        ],
        onTap: (i) {
          if (i == 0) {
            Navigator.pushNamedAndRemoveUntil(
                context, '/buyer/home', (route) => false);
          } else if (i == 1) {
            Navigator.pushNamed(context, '/buyer/shop');
          } else if (i == 3) {
            Navigator.pushNamed(context, '/buyer/profile');
          }
        },
      ),
    );
  }
}

class _CartItem {
  final String name;
  final String description;
  int qty;
  bool checked;
  _CartItem(
      {required this.name,
      required this.description,
      this.qty = 1,
      // ignore: unused_element_parameter
      this.checked = false});
}

class _OrangeQtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _OrangeQtyBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        alignment: Alignment.center,
        child: Icon(icon, size: 18, color: AppColors.accentOrange),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// BUYER CHECKOUT PAGE
// Referensi: Screenshot 15 - Checkout dengan Qris/BCA VA/Credit Card radio orange
// ─────────────────────────────────────────────
class BuyerCheckoutPage extends StatefulWidget {
  const BuyerCheckoutPage({super.key});

  @override
  State<BuyerCheckoutPage> createState() => _BuyerCheckoutPageState();
}

class _BuyerCheckoutPageState extends State<BuyerCheckoutPage> {
  String _selectedPayment = 'Qris';

  final _paymentMethods = ['Qris', 'BCA Virtual Account', 'Credit Card/ Debit Online'];

  final _orderItems = [
    {'name': 'Beras Premium', 'qty': '1x', 'price': '15.000'},
    {'name': 'Beras Premium', 'qty': '1x', 'price': '15.000'},
    {'name': 'Beras Premium', 'qty': '1x', 'price': '15.000'},
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
          'Checkout',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryGreen,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Address bar
            Container(
              color: AppColors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  const Icon(Icons.location_on_outlined,
                      color: AppColors.accentOrange, size: 18),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Bu dedeh',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary),
                            ),
                            SizedBox(width: 4),
                            Icon(Icons.chevron_right,
                                size: 16, color: AppColors.textSecondary),
                          ],
                        ),
                        Text(
                          'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
                          style: TextStyle(
                              fontSize: 11, color: AppColors.textSecondary),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Order items list
            Container(
              color: AppColors.white,
              child: Column(
                children: _orderItems.map((item) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEEEEE),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(item['name']!,
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500)),
                        ),
                        Text(item['qty']!,
                            style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary)),
                        const SizedBox(width: 16),
                        Text(item['price']!,
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 10),

            // Metode Pembayaran
            Container(
              color: AppColors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Metode Pembayaran',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ..._paymentMethods.map((method) {
                    final isSelected = method == _selectedPayment;
                    return GestureDetector(
                      onTap: () =>
                          setState(() => _selectedPayment = method),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Row(
                          children: [
                            // Radio circle
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: const Color(0xFFEEEEEE),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(method,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textPrimary)),
                            ),
                            // Orange radio button
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.accentOrange
                                      : AppColors.borderColor,
                                  width: 2,
                                ),
                              ),
                              child: isSelected
                                  ? Center(
                                      child: Container(
                                        width: 10,
                                        height: 10,
                                        decoration: const BoxDecoration(
                                          color: AppColors.accentOrange,
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
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Rincian Pembiayaan
            Container(
              color: AppColors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Rincian Pembiayaan',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ..._orderItems.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(item['name']!,
                            style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textPrimary)),
                        Text(item['price']!,
                            style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textPrimary)),
                      ],
                    ),
                  )),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      SizedBox(), // empty left
                      Text(
                        '75.000',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: Colors.white,
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/buyer/payment'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreenDark,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text(
              'Lanjut Bayar',
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// BUYER PAYMENT PAGE
// Referensi: Screenshot 16 — "Menunggu Konfirmasi..." orange + timer + Midtrans area
// ─────────────────────────────────────────────
class BuyerPaymentPage extends StatefulWidget {
  const BuyerPaymentPage({super.key});

  @override
  State<BuyerPaymentPage> createState() => _BuyerPaymentPageState();
}

class _BuyerPaymentPageState extends State<BuyerPaymentPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: const Text(
          'Checkout',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryGreen,
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Menunggu Konfirmasi header
              Container(
                color: AppColors.white,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Menunggu Konfirmasi...',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.accentOrange,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('Total Pembiayaan',
                            style: TextStyle(
                                fontSize: 14, color: AppColors.textPrimary)),
                        Text('75.000',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimary)),
                      ],
                    ),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Bayar Dalam',
                            style: TextStyle(
                                fontSize: 14, color: AppColors.textPrimary)),
                        Row(
                          children: const [
                            Icon(Icons.access_time,
                                size: 14, color: AppColors.accentOrange),
                            SizedBox(width: 4),
                            Text(
                              '25 Menit',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.accentOrange,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              // Midtrans payment area placeholder
              Expanded(
                child: Container(
                  color: AppColors.backgroundGrey,
                ),
              ),
            ],
          ),
          // Demo: Tap anywhere to show payment result
          Positioned.fill(
            child: GestureDetector(
              onTap: () => _showPaymentResult(context, success: true),
              child: const SizedBox.shrink(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () => Navigator.pushNamedAndRemoveUntil(
                context, '/buyer/home', (route) => false),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentOrange,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
            ),
            child: const Text(
              'Back to Home',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  void _showPaymentResult(BuildContext context, {required bool success}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PaymentResultSheet(
        success: success,
        onTrack: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, '/buyer/order-status');
        },
        onHome: () => Navigator.pushNamedAndRemoveUntil(
            context, '/buyer/home', (route) => false),
      ),
    );
  }
}

/// Payment result bottom sheet — reused for success (ss 17) and failed (ss 18)
class _PaymentResultSheet extends StatelessWidget {
  final bool success;
  final VoidCallback onTrack;
  final VoidCallback onHome;

  const _PaymentResultSheet({
    required this.success,
    required this.onTrack,
    required this.onHome,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.4,
      maxChildSize: 0.7,
      builder: (_, scrollController) {
        return Container(
          padding: const EdgeInsets.all(28),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon circle
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: success
                      ? AppColors.primaryGreenDark
                      : const Color(0xFFE53935),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  success ? Icons.check : Icons.close,
                  color: Colors.white,
                  size: 44,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                success ? 'Payment Succesfully!' : 'Payment Failed',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: success
                      ? AppColors.primaryGreen
                      : const Color(0xFFE53935),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                success
                    ? 'Thanks for your order'
                    : 'It seems we have not received money',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 13, color: AppColors.textSecondary),
              ),
              if (success) ...
                [
                  const SizedBox(height: 4),
                  const Text(
                    'Order ID - 12345689',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary),
                  ),
                ],
              const SizedBox(height: 24),
              // CTA buttons
              OutlinedButton(
                onPressed: success ? onTrack : Navigator.of(context).pop,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 46),
                  side: const BorderSide(color: AppColors.primaryGreen),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  success ? 'Track your order' : 'Try Again',
                  style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
// BUYER PAYMENT SUCCESS PAGE
// Referensi: Screenshot 17 — navigasi ke /buyer/payment-success (entry point)
// Sekarang payment result muncul sebagai modal sheet dari BuyerPaymentPage.
// Page ini redirect ke order-status langsung.
// ─────────────────────────────────────────────
class BuyerPaymentSuccessPage extends StatelessWidget {
  const BuyerPaymentSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      body: Center(
        child: ElevatedButton(
          onPressed: () =>
              Navigator.pushNamed(context, '/buyer/order-status'),
          style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreenDark),
          child: const Text('Lihat Status Pesanan'),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// BUYER ORDER STATUS PAGE
// Referensi: Screenshot 19-23 — 4 filter tabs (Diproses/Dikirim/Selesai/Dibatalkan)
// ─────────────────────────────────────────────
class BuyerOrderStatusPage extends StatefulWidget {
  const BuyerOrderStatusPage({super.key});

  @override
  State<BuyerOrderStatusPage> createState() => _BuyerOrderStatusPageState();
}

class _BuyerOrderStatusPageState extends State<BuyerOrderStatusPage> {
  final _tabs = ['Diproses', 'Dikirim', 'Selesai', 'Dibatalkan'];
  String _selectedTab = 'Diproses';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Status Pesanan',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryGreen,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter chips row
          Container(
            color: AppColors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _tabs.map((tab) {
                  final isSelected = tab == _selectedTab;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedTab = tab),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primaryGreen
                            : AppColors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primaryGreen
                              : AppColors.borderColor,
                        ),
                      ),
                      child: Text(
                        tab,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Order list
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _OrderCard(
                  status: _selectedTab,
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: CropChainBottomNav(
        currentIndex: 1,
        items: const [
          BottomNavItem(icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Home'),
          BottomNavItem(icon: Icons.store_outlined, activeIcon: Icons.store, label: 'Shop'),
          BottomNavItem(icon: Icons.shopping_cart_outlined, activeIcon: Icons.shopping_cart, label: 'Cart'),
          BottomNavItem(icon: Icons.person_outline, activeIcon: Icons.person, label: 'Profile'),
        ],
        onTap: (i) {
          if (i == 0) {
            Navigator.pushNamedAndRemoveUntil(
                context, '/buyer/home', (route) => false);
          } else if (i == 2) {
            Navigator.pushNamed(context, '/buyer/cart');
          } else if (i == 3) {
            Navigator.pushNamed(context, '/buyer/profile');
          }
        },
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final String status;
  final VoidCallback onTap;

  const _OrderCard({required this.status, required this.onTap});

  Color get _statusColor {
    switch (status) {
      case 'Selesai':
        return AppColors.primaryGreen;
      case 'Dibatalkan':
        return AppColors.accentOrange;
      default:
        return AppColors.accentOrange;
    }
  }

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
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stacked product thumbnails
                SizedBox(
                  width: 80,
                  height: 80,
                  child: Stack(
                    children: [
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEEEEE),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.borderColor),
                          ),
                        ),
                      ),
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.borderColor),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: _statusColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          status,
                          style: const TextStyle(
                              fontSize: 11,
                              color: Colors.white,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Order ID - 12345689',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      const Text(
                        '4 Produk',
                        style: TextStyle(
                            fontSize: 12, color: AppColors.textSecondary),
                      ),
                      if (status == 'Dikirim' || status == 'Selesai') ...
                        [
                          const SizedBox(height: 4),
                          Row(
                            children: const [
                              Icon(Icons.local_shipping_outlined,
                                  size: 14, color: AppColors.textSecondary),
                              SizedBox(width: 4),
                              Text(
                                'Pesanan sedang dalam pengiriman',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total 4 Produk:',
                    style: TextStyle(
                        fontSize: 12, color: AppColors.textSecondary)),
                const Text('75.000',
                    style: TextStyle(
                        fontSize: 14, fontWeight: FontWeight.bold)),
              ],
            ),
            // Action buttons for Selesai / Dibatalkan
            if (status == 'Selesai') ...
              [
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                            color: AppColors.textSecondary),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        minimumSize: Size.zero,
                      ),
                      child: const Text('Laporkan Masalah',
                          style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary)),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                            color: AppColors.accentOrange),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        minimumSize: Size.zero,
                      ),
                      child: const Text('Berikan Ulasan',
                          style: TextStyle(
                              fontSize: 12,
                              color: AppColors.accentOrange)),
                    ),
                  ],
                ),
              ],
            if (status == 'Dibatalkan') ...
              [
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                          color: AppColors.accentOrange),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      minimumSize: Size.zero,
                    ),
                    child: const Text('Beli Lagi',
                        style: TextStyle(
                            fontSize: 12,
                            color: AppColors.accentOrange)),
                  ),
                ),
              ],
          ],
        ),
      ),
    );
  }
}



// ─────────────────────────────────────────────
// BUYER TRACKING PAGE
// ─────────────────────────────────────────────
class BuyerTrackingPage extends StatelessWidget {
  const BuyerTrackingPage({super.key});

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
          'Lacak Pesanan',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryGreen,
          ),
        ),
      ),
      body: Column(
        children: [
          // Map placeholder
          Container(
            height: 250,
            color: const Color(0xFFE0E0E0),
            child: const Center(
              child: Icon(Icons.map_outlined,
                  size: 60, color: AppColors.textSecondary),
            ),
          ),

          // Tracking detail card
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              color: AppColors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.lightGreenBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.local_shipping_outlined,
                            color: AppColors.primaryGreen),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Dalam Pengiriman',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold)),
                            Text('Estimasi tiba: Besok, 10:00 - 12:00',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 12),
                  const Text('Detail Pengiriman',
                      style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const DetailRow(
                      label: 'Kurir', value: 'JNE Express'),
                  const DetailRow(
                      label: 'No. Resi', value: 'JNE1234567890'),
                  const DetailRow(
                      label: 'Dari', value: 'Bandung, Jawa Barat'),
                  const DetailRow(
                      label: 'Tujuan', value: 'Sukapura, Bandung'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// BUYER PROFILE PAGE
// ─────────────────────────────────────────────
class BuyerProfilePage extends StatelessWidget {
  const BuyerProfilePage({super.key});

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
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile header
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
                    backgroundColor: AppColors.primaryGreen,
                    child: Icon(Icons.person, color: Colors.white, size: 30),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Ara',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        Text('Pembeli',
                            style: TextStyle(
                                fontSize: 13, color: AppColors.textSecondary)),
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

            // Menu items
            _ProfileMenuItem(
              icon: Icons.receipt_long_outlined,
              label: 'Pesanan Saya',
              onTap: () {},
            ),
            _ProfileMenuItem(
              icon: Icons.location_on_outlined,
              label: 'Alamat Pengiriman',
              onTap: () {},
            ),
            _ProfileMenuItem(
              icon: Icons.payment_outlined,
              label: 'Metode Pembayaran',
              onTap: () {},
            ),
            _ProfileMenuItem(
              icon: Icons.notifications_outlined,
              label: 'Notifikasi',
              onTap: () {},
            ),
            _ProfileMenuItem(
              icon: Icons.help_outline,
              label: 'Bantuan',
              onTap: () {},
            ),
            const SizedBox(height: 12),
            _ProfileMenuItem(
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
        currentIndex: 3,
        items: const [
          BottomNavItem(icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Home'),
          BottomNavItem(icon: Icons.store_outlined, activeIcon: Icons.store, label: 'Shop'),
          BottomNavItem(icon: Icons.shopping_cart_outlined, activeIcon: Icons.shopping_cart, label: 'Cart'),
          BottomNavItem(icon: Icons.person_outline, activeIcon: Icons.person, label: 'Profile'),
        ],
        onTap: (i) {
          if (i == 0) {
            Navigator.pushNamedAndRemoveUntil(
                context, '/buyer/home', (route) => false);
          } else if (i == 1) {
            Navigator.pushNamed(context, '/buyer/shop');
          } else if (i == 2) {
            Navigator.pushNamed(context, '/buyer/cart');
          }
        },
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? textColor;

  const _ProfileMenuItem({
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
        title: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: textColor ?? AppColors.textPrimary,
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        onTap: onTap,
      ),
    );
  }
}

// ─────────────────────────────────────────────
// MENU DATA HELPER
// ─────────────────────────────────────────────
class _MenuData {
  final IconData icon;
  final String label;
  const _MenuData({required this.icon, required this.label});
}
