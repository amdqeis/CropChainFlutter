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
    const _MenuData(icon: Icons.store_outlined, label: 'Toko', route: '/buyer/shop'),
    const _MenuData(icon: Icons.category_outlined, label: 'Kategori', route: '/buyer/shop'),
    const _MenuData(icon: Icons.history_outlined, label: 'Riwayat', route: '/buyer/order-status'),
    const _MenuData(icon: Icons.local_offer_outlined, label: 'Promo', route: '/buyer/shop'),
  ];

  static const _popularProducts = [
    _ProductData(
      name: 'Tomat Segar',
      price: 'Rp 12.000/kg',
      imageUrl:
          'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=300&q=80',
    ),
    _ProductData(
      name: 'Cabai Merah',
      price: 'Rp 35.000/kg',
      imageUrl:
          'https://images.unsplash.com/photo-1588166524941-3bf61a9c41db?w=300&q=80',
    ),
    _ProductData(
      name: 'Bayam Organik',
      price: 'Rp 8.000/ikat',
      imageUrl:
          'https://images.unsplash.com/photo-1576045057995-568f588f82fb?w=300&q=80',
    ),
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

            // Banner / Hero image
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/buyer/shop'),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  height: 180,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=800&q=80',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: AppColors.lightGreenBg2,
                          child: const Center(
                            child: Icon(Icons.image_not_supported_outlined,
                                color: AppColors.textHint, size: 40),
                          ),
                        ),
                        loadingBuilder: (_, child, progress) {
                          if (progress == null) return child;
                          return Container(
                            color: AppColors.lightGreenBg2,
                            child: const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primaryGreen,
                              ),
                            ),
                          );
                        },
                      ),
                      // Dark gradient overlay for readability
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.transparent,
                              Color(0x88000000),
                            ],
                          ),
                        ),
                      ),
                      // Shop Now button
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
                        onTap: () {
                          if (m.route != null) {
                            Navigator.pushNamed(context, m.route!);
                          }
                        },
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
              height: 170,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _popularProducts.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, i) => GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/buyer/product-detail'),
                  child: _PopularProductCard(product: _popularProducts[i]),
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
// POPULAR PRODUCT CARD (Buyer Home)
// ─────────────────────────────────────────────
class _PopularProductCard extends StatelessWidget {
  final _ProductData product;
  const _PopularProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.network(
              product.imageUrl,
              width: 120,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 120,
                height: 100,
                color: AppColors.lightGreenBg2,
                child: const Icon(Icons.image_not_supported_outlined,
                    color: AppColors.textHint, size: 24),
              ),
              loadingBuilder: (_, child, progress) {
                if (progress == null) return child;
                return Container(
                  width: 120,
                  height: 100,
                  color: AppColors.lightGreenBg2,
                  child: const Center(
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.primaryGreen),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  product.price,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Data class untuk menu item
class _MenuData {
  final IconData icon;
  final String label;
  final String? route;
  const _MenuData({required this.icon, required this.label, this.route});
}

// Data class untuk produk populer
class _ProductData {
  final String name;
  final String price;
  final String imageUrl;
  const _ProductData({
    required this.name,
    required this.price,
    required this.imageUrl,
  });
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

// ─────────────────────────────────────────────────────────────────────────────
// BUYER PROFILE PAGE
// Standard layout + DANA-style pill tabs ONLY for Peran Saya section
// ─────────────────────────────────────────────────────────────────────────────

enum _RoleStatus { active, pending, notApplied }

class BuyerProfilePage extends StatefulWidget {
  const BuyerProfilePage({super.key});

  @override
  State<BuyerProfilePage> createState() => _BuyerProfilePageState();
}

class _BuyerProfilePageState extends State<BuyerProfilePage>
    with TickerProviderStateMixin {
  int _selectedRoleIndex = 0;

  final Map<String, _RoleStatus> _roleStatus = {
    'pembeli': _RoleStatus.active,
    'distributor': _RoleStatus.notApplied,
    'farmer': _RoleStatus.notApplied,
  };

  static const _roleKeys = ['pembeli', 'distributor', 'farmer'];
  static const _roleLabels = ['Pembeli', 'Distributor', 'Petani'];
  static const _roleIcons = [
    Icons.shopping_bag_outlined,
    Icons.local_shipping_outlined,
    Icons.grass_outlined,
  ];
  static const _roleDescs = [
    'Beli hasil panen segar langsung dari petani & distributor.',
    'Beli dari petani, jual ke pembeli atau pasar dengan harga kompetitif.',
    'Jual hasil panen Anda ke pembeli atau distributor di seluruh Indonesia.',
  ];

  void _handleRoleTap(int index) {
    // Always switch tab immediately
    setState(() => _selectedRoleIndex = index);
  }

  void _submitApply() {
    final key = _roleKeys[_selectedRoleIndex];
    setState(() => _roleStatus[key] = _RoleStatus.pending);
  }

  void _cancelApply() {
    setState(() => _selectedRoleIndex = 0);
  }

  void _simulateApproval(String roleKey) {
    setState(() => _roleStatus[roleKey] = _RoleStatus.active);
  }

  @override
  Widget build(BuildContext context) {
    final currentKey = _roleKeys[_selectedRoleIndex];
    final currentStatus =
        _selectedRoleIndex == 0 ? _RoleStatus.active : _roleStatus[currentKey]!;
    final isApplyView = currentStatus == _RoleStatus.notApplied;

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
        actions: [
          if (!isApplyView)
            IconButton(
              icon: const Icon(Icons.notifications_outlined,
                  color: AppColors.primaryGreen),
              onPressed: () =>
                  Navigator.pushNamed(context, '/buyer/notifications'),
            ),
        ],
      ),
      body: Column(
        children: [
          // ── Role pill tabs — always pinned at top ─────────────────────────
          Container(
            color: AppColors.white,
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.backgroundGrey,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(3),
              child: Row(
                children: List.generate(3, (i) {
                  final isSelected = _selectedRoleIndex == i;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => _handleRoleTap(i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOut,
                        padding: const EdgeInsets.symmetric(vertical: 9),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.white
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.08),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  ),
                                ]
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          _roleLabels[i],
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w400,
                            color: isSelected
                                ? AppColors.primaryGreen
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),

          // ── Body: apply screen OR normal profile ──────────────────────────
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              transitionBuilder: (child, anim) => FadeTransition(
                opacity: anim,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.04),
                    end: Offset.zero,
                  ).animate(anim),
                  child: child,
                ),
              ),
              child: isApplyView
                  ? _applyScreen(key: ValueKey('apply_$_selectedRoleIndex'))
                  : _profileBody(
                      key: ValueKey('profile_$_selectedRoleIndex'),
                      currentStatus: currentStatus,
                    ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CropChainBottomNav(
        currentIndex: 3,
        items: const [
          BottomNavItem(
              icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Home'),
          BottomNavItem(
              icon: Icons.store_outlined, activeIcon: Icons.store, label: 'Shop'),
          BottomNavItem(
              icon: Icons.shopping_cart_outlined,
              activeIcon: Icons.shopping_cart,
              label: 'Cart'),
          BottomNavItem(
              icon: Icons.person_outline,
              activeIcon: Icons.person,
              label: 'Profile'),
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

  // ── Apply screen — replaces menu body when role notApplied ────────────────
  Widget _applyScreen({required Key key}) {
    final label = _roleLabels[_selectedRoleIndex];
    final icon = _roleIcons[_selectedRoleIndex];
    final desc = _roleDescs[_selectedRoleIndex];
    final isDistributor = _selectedRoleIndex == 1;

    final benefits = isDistributor
        ? [
            'Beli langsung dari petani dengan harga lebih kompetitif',
            'Pasarkan produk ke ribuan pembeli di platform',
            'Kelola stok & pengiriman dari satu dashboard',
            'Laporan pendapatan real-time',
          ]
        : [
            'Tawarkan hasil panen ke distributor & pembeli langsung',
            'Negosiasi harga secara transparan',
            'Pantau status tawaran kapan saja',
            'Pembayaran aman & tepat waktu',
          ];

    return SingleChildScrollView(
      key: key,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 16),
          // Icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.lightGreenBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: AppColors.primaryGreen, size: 38),
          ),
          const SizedBox(height: 20),
          Text(
            'Ajukan sebagai $label',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            desc,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),

          // Benefits
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Keuntungan bergabung:',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                ...benefits.map((b) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.check_circle,
                              size: 16, color: AppColors.primaryGreen),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              b,
                              style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textPrimary,
                                  height: 1.4),
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Verification note
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.accentOrange.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline,
                    size: 16, color: AppColors.accentOrange),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Proses verifikasi 1–3 hari kerja oleh tim CropChain.',
                    style: TextStyle(
                        fontSize: 12, color: AppColors.accentOrange),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // CTA button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _submitApply,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreenDark,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                'Kirim Pengajuan',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Cancel link
          GestureDetector(
            onTap: _cancelApply,
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Batal',
                style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ── Normal profile body (active/pending) ──────────────────────────────────
  Widget _profileBody({required Key key, required _RoleStatus currentStatus}) {
    final currentKey = _roleKeys[_selectedRoleIndex];
    final isActive = currentStatus == _RoleStatus.active;
    final isPending = currentStatus == _RoleStatus.pending;

    return SingleChildScrollView(
      key: key,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Role status strip (if not Pembeli)
          if (_selectedRoleIndex != 0) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.lightGreenBg
                          : AppColors.backgroundGrey,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(_roleIcons[_selectedRoleIndex],
                        color: isActive
                            ? AppColors.primaryGreen
                            : AppColors.textSecondary,
                        size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _roleLabels[_selectedRoleIndex],
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 2),
                        if (isActive)
                          const Text('Aktif',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.primaryGreen,
                                  fontWeight: FontWeight.w600))
                        else
                          const Text('Menunggu Verifikasi',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.accentOrange,
                                  fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  if (isActive)
                    GestureDetector(
                      onTap: () {
                        if (currentKey == 'distributor') {
                          Navigator.pushNamedAndRemoveUntil(
                              context, '/distributor/home', (r) => false);
                        } else if (currentKey == 'farmer') {
                          Navigator.pushNamedAndRemoveUntil(
                              context, '/farmer/home', (r) => false);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreenDark,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('Buka',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                      ),
                    )
                  else if (isPending)
                    GestureDetector(
                      onTap: () => _simulateApproval(currentKey),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.accentOrange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color:
                                  AppColors.accentOrange.withValues(alpha: 0.5)),
                        ),
                        child: const Text('Demo: Aktifkan',
                            style: TextStyle(
                                fontSize: 11,
                                color: AppColors.accentOrange,
                                fontWeight: FontWeight.w600)),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // ── Profile card ───────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundColor: AppColors.lightGreenBg,
                      child: Icon(Icons.person,
                          color: AppColors.primaryGreen, size: 30),
                    ),
                    Positioned(
                      right: -2,
                      bottom: -2,
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: AppColors.accentOrange,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        child: const Icon(Icons.edit,
                            size: 11, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ara',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.lightGreenBg,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              '🛒 Pembeli',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryGreen,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'Jakarta',
                            style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primaryGreen,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                  ),
                  child: const Text('Edit',
                      style: TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Transaksi ──────────────────────────────────────────────────────
          _ProfileSection(
            label: 'Transaksi',
            children: [
              _ProfileMenuItem(
                icon: Icons.receipt_long_outlined,
                label: 'Pesanan Saya',
                onTap: () =>
                    Navigator.pushNamed(context, '/buyer/order-status'),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ── Pengaturan Akun ────────────────────────────────────────────────
          _ProfileSection(
            label: 'Pengaturan Akun',
            children: [
              _ProfileMenuItem(
                icon: Icons.location_on_outlined,
                label: 'Alamat Pengiriman',
                onTap: () => Navigator.pushNamed(context, '/buyer/address'),
              ),
              _ProfileMenuItem(
                icon: Icons.payment_outlined,
                label: 'Metode Pembayaran',
                onTap: () =>
                    Navigator.pushNamed(context, '/buyer/payment-method'),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ── Dukungan ──────────────────────────────────────────────────────
          _ProfileSection(
            label: 'Dukungan',
            children: [
              _ProfileMenuItem(
                icon: Icons.help_outline,
                label: 'Bantuan & FAQ',
                onTap: () => Navigator.pushNamed(context, '/buyer/help'),
              ),
              _ProfileMenuItem(
                icon: Icons.info_outline,
                label: 'Tentang CropChain',
                onTap: () => Navigator.pushNamed(context, '/buyer/about'),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ── Keluar ────────────────────────────────────────────────────────
          _ProfileSection(
            children: [
              _ProfileMenuItem(
                icon: Icons.logout,
                label: 'Keluar',
                textColor: AppColors.error,
                onTap: () => Navigator.pushNamedAndRemoveUntil(
                    context, '/splash', (route) => false),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
class _ProfileSection extends StatelessWidget {
  final String? label;
  final List<Widget> children;

  const _ProfileSection({this.label, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              label!.toUpperCase(),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ],
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: List.generate(children.length, (i) {
              return Column(
                children: [
                  children[i],
                  if (i < children.length - 1)
                    const Divider(
                        height: 1,
                        indent: 52,
                        endIndent: 16,
                        color: AppColors.borderColor),
                ],
              );
            }),
          ),
        ),
      ],
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
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: textColor != null
              ? textColor!.withValues(alpha: 0.1)
              : AppColors.lightGreenBg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon,
            color: textColor ?? AppColors.primaryGreen, size: 19),
      ),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          color: textColor ?? AppColors.textPrimary,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: textColor?.withValues(alpha: 0.5) ?? AppColors.textSecondary,
        size: 20,
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      minLeadingWidth: 36,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BUYER ADDRESS PAGE
// ─────────────────────────────────────────────────────────────────────────────
class BuyerAddressPage extends StatefulWidget {
  const BuyerAddressPage({super.key});

  @override
  State<BuyerAddressPage> createState() => _BuyerAddressPageState();
}

class _BuyerAddressPageState extends State<BuyerAddressPage> {
  final List<Map<String, String>> _addresses = [
    {
      'label': 'Rumah',
      'name': 'Ara',
      'phone': '+62 812-3456-7890',
      'address': 'Jl. Merdeka No. 12, Menteng, Jakarta Pusat 10320',
    },
    {
      'label': 'Kantor',
      'name': 'Ara (Kantor)',
      'phone': '+62 812-3456-7890',
      'address': 'Gedung Sudirman, Jl. Jend. Sudirman Kav. 52-53, Jakarta 12190',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: const Text(
          'Alamat Pengiriman',
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Fitur tambah alamat segera hadir!')),
          );
        },
        backgroundColor: AppColors.primaryGreenDark,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Tambah Alamat',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _addresses.length,
        itemBuilder: (_, i) {
          final addr = _addresses[i];
          final isFirst = i == 0;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: isFirst
                  ? Border.all(
                      color: AppColors.primaryGreen.withValues(alpha: 0.5),
                      width: 1.5)
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isFirst
                            ? AppColors.lightGreenBg
                            : AppColors.backgroundGrey,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        addr['label']!,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isFirst
                              ? AppColors.primaryGreen
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                    if (isFirst) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color:
                              AppColors.primaryGreen.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Utama',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                      ),
                    ],
                    const Spacer(),
                    GestureDetector(
                      onTap: () {},
                      child: const Text(
                        'Ubah',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.primaryGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  addr['name']!,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(addr['phone']!,
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.textSecondary)),
                const SizedBox(height: 4),
                Text(
                  addr['address']!,
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.textPrimary, height: 1.4),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BUYER PAYMENT METHOD PAGE
// ─────────────────────────────────────────────────────────────────────────────
class BuyerPaymentMethodPage extends StatelessWidget {
  const BuyerPaymentMethodPage({super.key});

  static const _methods = [
    _PayMethodData(
      icon: Icons.qr_code_2_rounded,
      label: 'QRIS',
      detail: 'Scan QR dari semua e-wallet & bank',
      color: Color(0xFF2196F3),
    ),
    _PayMethodData(
      icon: Icons.account_balance_outlined,
      label: 'BCA Virtual Account',
      detail: '••• 4521',
      color: Color(0xFF0D47A1),
    ),
    _PayMethodData(
      icon: Icons.credit_card_outlined,
      label: 'Kartu Kredit / Debit',
      detail: 'Visa ••• 8890',
      color: Color(0xFF6A1B9A),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: const Text(
          'Metode Pembayaran',
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ..._methods.map((m) => _PayMethodCard(data: m)),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Fitur tambah metode segera hadir!')),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppColors.primaryGreen.withValues(alpha: 0.4),
                    style: BorderStyle.solid,
                    width: 1.5),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_circle_outline,
                      color: AppColors.primaryGreen, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Tambah Metode Pembayaran',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PayMethodData {
  final IconData icon;
  final String label;
  final String detail;
  final Color color;
  const _PayMethodData(
      {required this.icon,
      required this.label,
      required this.detail,
      required this.color});
}

class _PayMethodCard extends StatelessWidget {
  final _PayMethodData data;
  const _PayMethodCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: data.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(data.icon, color: data.color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data.label,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                Text(data.detail,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BUYER NOTIFICATIONS PAGE
// ─────────────────────────────────────────────────────────────────────────────
class BuyerNotificationsPage extends StatefulWidget {
  const BuyerNotificationsPage({super.key});

  @override
  State<BuyerNotificationsPage> createState() => _BuyerNotificationsPageState();
}

class _BuyerNotificationsPageState extends State<BuyerNotificationsPage> {
  final List<_NotifData> _notifs = [
    _NotifData(
      icon: Icons.local_shipping_outlined,
      color: AppColors.primaryGreen,
      title: 'Pesanan Dikirim',
      body: 'Pesanan #CC-2024-001 sedang dalam perjalanan ke alamat Anda.',
      time: '10 mnt lalu',
      isRead: false,
    ),
    _NotifData(
      icon: Icons.check_circle_outline,
      color: Colors.teal,
      title: 'Pembayaran Berhasil',
      body: 'Pembayaran Rp 240.000 untuk pesanan #CC-2024-001 telah dikonfirmasi.',
      time: '2 jam lalu',
      isRead: false,
    ),
    _NotifData(
      icon: Icons.local_offer_outlined,
      color: AppColors.accentOrange,
      title: 'Promo Akhir Pekan',
      body: 'Dapatkan diskon 15% untuk pembelian sayuran organik. Berlaku s.d. Minggu!',
      time: '1 hari lalu',
      isRead: true,
    ),
    _NotifData(
      icon: Icons.star_outline,
      color: Colors.amber.shade600,
      title: 'Beri Ulasan',
      body: 'Bagaimana pesanan Tomat Segar Anda? Bantu petani dengan ulasan Anda.',
      time: '3 hari lalu',
      isRead: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: const Text(
          'Notifikasi',
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () =>
                setState(() { for (final n in _notifs) { n.isRead = true; } }),
            child: const Text(
              'Tandai Dibaca',
              style: TextStyle(
                  color: AppColors.primaryGreen, fontSize: 13),
            ),
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _notifs.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, i) {
          final n = _notifs[i];
          return GestureDetector(
            onTap: () => setState(() => n.isRead = true),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: n.isRead ? AppColors.white : AppColors.lightGreenBg,
                borderRadius: BorderRadius.circular(12),
                border: n.isRead
                    ? null
                    : Border.all(
                        color: AppColors.primaryGreen.withValues(alpha: 0.25)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: n.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(n.icon, color: n.color, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                n.title,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: n.isRead
                                      ? FontWeight.w500
                                      : FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            Text(
                              n.time,
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          n.body,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!n.isRead) ...[
                    const SizedBox(width: 8),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryGreen,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _NotifData {
  final IconData icon;
  final Color color;
  final String title;
  final String body;
  final String time;
  bool isRead;
  _NotifData({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
    required this.time,
    required this.isRead,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// BUYER HELP PAGE
// ─────────────────────────────────────────────────────────────────────────────
class BuyerHelpPage extends StatefulWidget {
  const BuyerHelpPage({super.key});

  @override
  State<BuyerHelpPage> createState() => _BuyerHelpPageState();
}

class _BuyerHelpPageState extends State<BuyerHelpPage> {
  int? _expandedIndex;

  static const _faqs = [
    _FaqItem(
      q: 'Bagaimana cara melakukan pemesanan?',
      a: 'Pilih produk yang Anda inginkan di halaman Toko, masukkan ke keranjang, '
          'lalu lanjutkan ke halaman Checkout. Pilih alamat dan metode pembayaran, '
          'kemudian konfirmasi pesanan Anda.',
    ),
    _FaqItem(
      q: 'Berapa lama pengiriman produk?',
      a: 'Pengiriman biasanya memakan waktu 1–3 hari kerja tergantung lokasi Anda. '
          'Anda dapat memantau status pesanan secara real-time di menu "Pesanan Saya".',
    ),
    _FaqItem(
      q: 'Apakah bisa membatalkan pesanan?',
      a: 'Pesanan dapat dibatalkan selama masih dalam status "Menunggu Konfirmasi". '
          'Setelah pesanan dikonfirmasi oleh penjual, pembatalan tidak dapat dilakukan.',
    ),
    _FaqItem(
      q: 'Bagaimana jika produk yang diterima tidak sesuai?',
      a: 'Jika ada ketidaksesuaian produk, Anda dapat mengajukan komplain melalui fitur '
          '"Bantuan" dalam 24 jam setelah produk diterima. Tim kami akan membantu penyelesaian.',
    ),
    _FaqItem(
      q: 'Metode pembayaran apa saja yang tersedia?',
      a: 'Kami mendukung QRIS, Transfer Bank (BCA, Mandiri, BNI, BRI), '
          'Kartu Kredit/Debit Visa & Mastercard, serta dompet digital (GoPay, OVO).',
    ),
    _FaqItem(
      q: 'Bagaimana cara menjadi Distributor atau Petani?',
      a: 'Buka tab "Peran Saya" di halaman Profile, lalu tap "Ajukan Peran" pada '
          'peran yang Anda inginkan. Tim kami akan memverifikasi pengajuan dalam 1–3 hari kerja.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: const Text(
          'Bantuan & FAQ',
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // CS contact card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2A5C2A), Color(0xFF4A7C3F)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(Icons.headset_mic_outlined,
                    color: Colors.white, size: 36),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hubungi Customer Service',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Senin – Jumat, 08.00 – 17.00 WIB',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primaryGreenDark,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Chat',
                      style: TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 13)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          const Text(
            'PERTANYAAN UMUM',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 10),

          ...List.generate(_faqs.length, (i) {
            final isExpanded = _expandedIndex == i;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: isExpanded
                    ? Border.all(
                        color: AppColors.primaryGreen.withValues(alpha: 0.3))
                    : null,
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => setState(
                    () => _expandedIndex = isExpanded ? null : i),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _faqs[i].q,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isExpanded
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: isExpanded
                                    ? AppColors.primaryGreen
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          AnimatedRotation(
                            turns: isExpanded ? 0.5 : 0,
                            duration: const Duration(milliseconds: 200),
                            child: Icon(
                              Icons.keyboard_arrow_down,
                              color: isExpanded
                                  ? AppColors.primaryGreen
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      if (isExpanded) ...[
                        const SizedBox(height: 10),
                        const Divider(height: 1, color: AppColors.borderColor),
                        const SizedBox(height: 10),
                        Text(
                          _faqs[i].a,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _FaqItem {
  final String q;
  final String a;
  const _FaqItem({required this.q, required this.a});
}

// ─────────────────────────────────────────────────────────────────────────────
// BUYER ABOUT PAGE
// ─────────────────────────────────────────────────────────────────────────────
class BuyerAboutPage extends StatelessWidget {
  const BuyerAboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: const Text('Tentang CropChain',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Logo card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E4620), Color(0xFF4A7C3F)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              children: [
                Icon(Icons.eco_rounded, color: Colors.white, size: 56),
                SizedBox(height: 12),
                Text(
                  'CropChain',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Fresh from farm to your table',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                SizedBox(height: 8),
                Text(
                  'v1.0.0',
                  style: TextStyle(color: Colors.white38, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _aboutItem('Versi Aplikasi', '1.0.0 (Build 2026.09)'),
          _aboutItem('Pengembang', 'Tim CropChain Indonesia'),
          _aboutItem('Email', 'support@cropchain.id'),
          _aboutItem('Website', 'www.cropchain.id'),
        ],
      ),
    );
  }

  Widget _aboutItem(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 14, color: AppColors.textSecondary)),
          Text(value,
              style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}