import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Bottom Navigation Bar untuk Pembeli (4 items: Home, Stok, Cart, Profile)
class BuyerBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BuyerBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _PillBottomNav(
      currentIndex: currentIndex,
      onTap: onTap,
      items: const [
        _NavItem(icon: Icons.home_outlined, activeIcon: Icons.home),
        _NavItem(icon: Icons.inventory_2_outlined, activeIcon: Icons.inventory_2),
        _NavItem(icon: Icons.shopping_cart_outlined, activeIcon: Icons.shopping_cart),
        _NavItem(icon: Icons.person_outline, activeIcon: Icons.person),
      ],
    );
  }
}

/// Bottom Navigation Bar untuk Distributor (3 items: Home, Pendapatan, Profile)
class DistributorBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const DistributorBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _PillBottomNav(
      currentIndex: currentIndex,
      onTap: onTap,
      items: const [
        _NavItem(icon: Icons.home_outlined, activeIcon: Icons.home),
        _NavItem(icon: Icons.monetization_on_outlined, activeIcon: Icons.monetization_on),
        _NavItem(icon: Icons.person_outline, activeIcon: Icons.person),
      ],
    );
  }
}

/// Bottom Navigation Bar untuk Petani (3 items: Home, Pendapatan, Profile)
class FarmerBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const FarmerBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _PillBottomNav(
      currentIndex: currentIndex,
      onTap: onTap,
      items: const [
        _NavItem(icon: Icons.home_outlined, activeIcon: Icons.home),
        _NavItem(icon: Icons.monetization_on_outlined, activeIcon: Icons.monetization_on),
        _NavItem(icon: Icons.person_outline, activeIcon: Icons.person),
      ],
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  const _NavItem({required this.icon, required this.activeIcon});
}

class _PillBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<_NavItem> items;

  const _PillBottomNav({
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.backgroundGrey,
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(40),
          border: Border.all(color: AppColors.primaryGreen, width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(items.length, (i) {
            final isActive = i == currentIndex;
            return GestureDetector(
              onTap: () => onTap(i),
              behavior: HitTestBehavior.opaque,
              child: SizedBox(
                width: 60,
                child: Icon(
                  isActive ? items[i].activeIcon : items[i].icon,
                  color: AppColors.primaryGreen,
                  size: 26,
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

/// CropChain AppBar logo row (top-left logo + notification bell)
class CropChainAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onNotificationTap;

  const CropChainAppBar({super.key, this.onNotificationTap});

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      leadingWidth: 180,
      leading: Padding(
        padding: const EdgeInsets.only(left: 20),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.lightGreenBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.eco,
                color: AppColors.primaryGreen,
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'CROPCHAIN',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryGreen,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
      actions: [
        GestureDetector(
          onTap: onNotificationTap,
          child: Container(
            margin: const EdgeInsets.only(right: 20),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primaryGreen, width: 1.5),
            ),
            child: const Icon(
              Icons.notifications_outlined,
              color: AppColors.primaryGreen,
              size: 22,
            ),
          ),
        ),
      ],
    );
  }
}
