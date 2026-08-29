import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_theme.dart';

const String _kLogoAsset = 'assets/images/cropchain_logo.svg';

/// ─────────────────────────────────────────────
/// CropChain Logo Widget (used in splash & auth)
/// ─────────────────────────────────────────────
class CropChainLogo extends StatelessWidget {
  final bool dark;
  /// [iconSize] kini mengontrol tinggi SVG; lebar otomatis sesuai rasio 250:130
  final double iconSize;

  const CropChainLogo({
    super.key,
    this.dark = false,
    this.iconSize = 100,
    // fontSize tidak digunakan lagi — teks sudah di dalam SVG
    @Deprecated('teks sudah di dalam SVG') double fontSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    // SVG sudah mencakup icon + teks "CROPCHAIN"
    // dark=true → gunakan ColorFilter putih (untuk latar gelap)
    return SvgPicture.asset(
      _kLogoAsset,
      height: iconSize,
      colorFilter: dark
          ? const ColorFilter.mode(Colors.white, BlendMode.srcIn)
          : null,
      placeholderBuilder: (_) => SizedBox(
        height: iconSize,
        width: iconSize * (250 / 130),
        child: const CircularProgressIndicator(
          strokeWidth: 2,
          color: AppColors.primaryGreen,
        ),
      ),
    );
  }
}

class _CropChainIconPainter extends CustomPainter {
  final Color color;
  _CropChainIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.07
      ..strokeCap = StrokeCap.round;

    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.38;

    // Draw stylized leaf/plant icon
    // Center circle
    canvas.drawCircle(Offset(cx, cy + r * 0.1), r * 0.35, paint);

    // Left leaf arc
    final leftPath = Path()
      ..moveTo(cx - r * 0.3, cy - r * 0.2)
      ..cubicTo(cx - r, cy - r * 0.8, cx - r * 0.9, cy - r * 1.1,
          cx - r * 0.1, cy - r * 0.7);
    canvas.drawPath(leftPath, paint);

    // Center stem
    final stemPath = Path()
      ..moveTo(cx, cy - r * 0.7)
      ..lineTo(cx, cy - r * 1.2);
    canvas.drawPath(stemPath, paint);

    // Right leaf arc
    final rightPath = Path()
      ..moveTo(cx + r * 0.3, cy - r * 0.2)
      ..cubicTo(cx + r, cy - r * 0.8, cx + r * 0.9, cy - r * 1.1,
          cx + r * 0.1, cy - r * 0.7);
    canvas.drawPath(rightPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// ─────────────────────────────────────────────
/// Pill-shaped Bottom Navigation Bar (3-tab: Buyer has 4)
/// ─────────────────────────────────────────────
class CropChainBottomNav extends StatelessWidget {
  final int currentIndex;
  final List<BottomNavItem> items;
  final void Function(int) onTap;

  const CropChainBottomNav({
    super.key,
    required this.currentIndex,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(40),
            border: Border.all(color: AppColors.primaryGreen, width: 1.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (i) {
              final item = items[i];
              final isActive = i == currentIndex;
              return GestureDetector(
                onTap: () => onTap(i),
                child: Container(
                  color: Colors.transparent,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isActive
                            ? (item.activeIcon ?? item.icon)
                            : item.icon,
                        color: isActive
                            ? AppColors.primaryGreen
                            : AppColors.textSecondary,
                        size: 24,
                      ),
                      const SizedBox(height: 3),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: isActive ? 5 : 0,
                        height: isActive ? 5 : 0,
                        decoration: const BoxDecoration(
                          color: AppColors.primaryGreen,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class BottomNavItem {
  final IconData icon;
  final IconData? activeIcon;
  final String label;
  const BottomNavItem({required this.icon, this.activeIcon, required this.label});
}

/// ─────────────────────────────────────────────
/// Status Badge Widget
/// ─────────────────────────────────────────────
class StatusBadge extends StatelessWidget {
  final String label;
  final Color bgColor;
  final Color textColor;

  const StatusBadge({
    super.key,
    required this.label,
    this.bgColor = AppColors.accentOrange,
    this.textColor = Colors.white,
  });

  factory StatusBadge.fromStatus(String status) {
    Color bg;
    switch (status.toLowerCase()) {
      case 'aktif':
      case 'selesai':
      case 'diterima':
        bg = AppColors.primaryGreen;
        break;
      case 'nonaktif':
        bg = AppColors.statusNonaktif;
        break;
      default:
        bg = AppColors.accentOrange;
    }
    return StatusBadge(label: status, bgColor: bg);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// ─────────────────────────────────────────────
/// Product Image Placeholder
/// ─────────────────────────────────────────────
class ProductImagePlaceholder extends StatelessWidget {
  final double size;
  final double borderRadius;

  const ProductImagePlaceholder({
    super.key,
    this.size = 80,
    this.borderRadius = 10,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFE0E0E0),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

/// ─────────────────────────────────────────────
/// Notification Bell (AppBar action)
/// ─────────────────────────────────────────────
class NotificationBell extends StatelessWidget {
  const NotificationBell({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primaryGreen, width: 1.5),
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Icon(
          Icons.notifications_outlined,
          color: AppColors.primaryGreen,
          size: 20,
        ),
      ),
    );
  }
}

/// ─────────────────────────────────────────────
/// CropChain App Bar (with logo, greeting, notif)
/// ─────────────────────────────────────────────
class CropChainAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? greeting;
  final String title;
  final bool showNotification;

  const CropChainAppBar({
    super.key,
    this.greeting,
    required this.title,
    this.showNotification = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: SvgPicture.asset(
        _kLogoAsset,
        height: 32,
        // SVG rasio 250:130 → lebar otomatis ~61px pada height 32
      ),
      actions: showNotification ? const [NotificationBell()] : null,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// ─────────────────────────────────────────────
/// Search Bar Widget
/// ─────────────────────────────────────────────
class CropChainSearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final String hint;
  final VoidCallback? onTap;
  final bool readOnly;
  final ValueChanged<String>? onChanged;

  const CropChainSearchBar({
    super.key,
    this.controller,
    this.hint = 'Search....',
    this.onTap,
    this.readOnly = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}

/// ─────────────────────────────────────────────
/// Filter Chip Row (status filter)
/// ─────────────────────────────────────────────
class FilterChipRow extends StatelessWidget {
  final List<String> items;
  final String selected;
  final ValueChanged<String> onSelected;

  const FilterChipRow({
    super.key,
    required this.items,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: items.map((item) {
          final isSelected = item == selected;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onSelected(item),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryGreen : AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? AppColors.primaryGreen : AppColors.borderColor,
                  ),
                ),
                child: Text(
                  item,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// ─────────────────────────────────────────────
/// Success Page Widget (reusable success screen)
/// ─────────────────────────────────────────────
class SuccessPage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String buttonLabel;
  final VoidCallback onButtonPressed;
  final List<SuccessDetail>? details;

  const SuccessPage({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.onButtonPressed,
    this.details,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.lightGreenBg,
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Icon(icon, color: AppColors.primaryGreen, size: 40),
              ),
              const SizedBox(height: 24),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryGreen,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              if (details != null && details!.isNotEmpty) ...[
                const SizedBox(height: 24),
                ...details!.map((d) => _buildRow(d.label, d.value)),
              ],
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: onButtonPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreenDark,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(buttonLabel),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          Text(value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class SuccessDetail {
  final String label;
  final String value;
  const SuccessDetail(this.label, this.value);
}

/// ─────────────────────────────────────────────
/// Menu Grid Item (home dashboard menus)
/// ─────────────────────────────────────────────
class MenuGridItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const MenuGridItem({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.lightGreenBg2,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: AppColors.primaryGreen, size: 28),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}

/// ─────────────────────────────────────────────
/// Detail Row (label + value in a page)
/// ─────────────────────────────────────────────
class DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool bold;

  const DetailRow({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 13,
                fontWeight: bold ? FontWeight.bold : FontWeight.w500,
                color: valueColor ?? AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ─────────────────────────────────────────────
/// Cart FAB (floating cart button)
/// ─────────────────────────────────────────────
class CartFab extends StatelessWidget {
  final VoidCallback onTap;
  final int count;

  const CartFab({super.key, required this.onTap, this.count = 0});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.primaryGreen,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Stack(
          children: [
            const Center(
              child: Icon(Icons.shopping_cart_outlined,
                  color: Colors.white, size: 22),
            ),
            if (count > 0)
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: const BoxDecoration(
                    color: AppColors.accentOrange,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$count',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 9),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// ─────────────────────────────────────────────
/// Ubah Status Radio Page (reusable)
/// ─────────────────────────────────────────────
class UbahStatusPage extends StatefulWidget {
  final String title;
  final List<String> options;
  final String initialSelected;
  final bool showNote;
  final void Function(String status, String? catatan) onSave;

  const UbahStatusPage({
    super.key,
    required this.title,
    required this.options,
    required this.initialSelected,
    this.showNote = false,
    required this.onSave,
  });

  @override
  State<UbahStatusPage> createState() => _UbahStatusPageState();
}

class _UbahStatusPageState extends State<UbahStatusPage> {
  late String _selected;
  final _noteCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selected = widget.initialSelected;
  }

  @override
  void dispose() {
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
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryGreen,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pilih Status',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            ...widget.options.map((opt) {
              final isSelected = _selected == opt;
              return GestureDetector(
                onTap: () => setState(() => _selected = opt),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primaryGreen
                          : AppColors.borderColor,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        opt,
                        style: const TextStyle(
                            fontSize: 14, color: AppColors.textPrimary),
                      ),
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primaryGreen
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
                                    color: AppColors.primaryGreen,
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
            if (widget.showNote) ...[
              const SizedBox(height: 20),
              const Text(
                'Catatan (Opsional)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _noteCtrl,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Tuliskan catatan untuk petani...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.borderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: AppColors.primaryGreen, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.all(14),
                ),
              ),
            ],
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () =>
                    widget.onSave(_selected, _noteCtrl.text.isEmpty ? null : _noteCtrl.text),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreenDark,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Simpan'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
