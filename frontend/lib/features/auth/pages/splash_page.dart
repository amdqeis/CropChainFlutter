import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';

/// ─────────────────────────────────────────────
/// SPLASH PAGE (Loading + Logo only)
/// Referensi: Screenshot 2 - white bg + colored logo + CROPCHAIN text
/// ─────────────────────────────────────────────
class SplashLoadingPage extends StatefulWidget {
  const SplashLoadingPage({super.key});

  @override
  State<SplashLoadingPage> createState() => _SplashLoadingPageState();
}

class _SplashLoadingPageState extends State<SplashLoadingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();

    // Navigate to splash after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/splash');
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: const Center(
          child: _CropChainLogoColored(),
        ),
      ),
    );
  }
}

/// ─────────────────────────────────────────────
/// SPLASH / WELCOME PAGE
/// Referensi: Screenshot 1 - farm background + CROPCHAIN logo + Sign in + Create account
/// ─────────────────────────────────────────────
class SplashPage extends StatefulWidget {
  // Keep backward compat - these may be null if using Navigator
  final VoidCallback? onSignIn;
  final VoidCallback? onCreateAccount;

  const SplashPage({super.key, this.onSignIn, this.onCreateAccount});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryGreenDark,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background gradient (warm golden farm field at top, forest green at bottom)
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFD4B483), // warm golden/amber — wheat field top
                  Color(0xFF8BA470), // sage green mid
                  Color(0xFF4A7C3F), // primary green
                  Color(0xFF2D5A20), // deep forest green bottom
                ],
                stops: [0.0, 0.3, 0.65, 1.0],
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.15),
            ),
          ),
          // Content
          SafeArea(
            child: Column(
              children: [
                // Logo in center
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 80,
                          height: 80,
                          child: CustomPaint(painter: _WhiteLogoPainter()),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'CROPCHAIN',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Buttons
                Padding(
                  padding: const EdgeInsets.fromLTRB(40, 0, 40, 60),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton(
                          onPressed: () {
                            if (widget.onSignIn != null) {
                              widget.onSignIn!();
                            } else {
                              Navigator.pushNamed(context, '/login');
                            }
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(
                                color: Colors.white70, width: 1.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            backgroundColor: Colors.white.withValues(alpha: 0.2),
                          ),
                          child: const Text(
                            'Sign in',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          if (widget.onCreateAccount != null) {
                            widget.onCreateAccount!();
                          } else {
                            Navigator.pushNamed(context, '/register');
                          }
                        },
                        child: const Text(
                          'Create an account',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
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

// ─── Logo Widgets ────────────────────────────

class _CropChainLogoColored extends StatelessWidget {
  const _CropChainLogoColored();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 80,
          height: 80,
          child: CustomPaint(
            painter: _ColoredLogoPainter(),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'CROPCHAIN',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _WhiteLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    _drawLogo(canvas, size, Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ColoredLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Draw primary leaves in dark green
    _drawLogo(canvas, size, const Color(0xFF3D6834),
        secondaryColor: const Color(0xFF4A9B8E)); // teal for bottom leaves
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

void _drawLogo(Canvas canvas, Size size, Color color,
    {Color? secondaryColor}) {
  final paint = Paint()
    ..color = color
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.5
    ..strokeCap = StrokeCap.round;

  final w = size.width;
  final h = size.height;
  final cx = w / 2;
  final cy = h / 2;

  canvas.drawCircle(Offset(cx, cy + h * 0.05), h * 0.18, paint);

  final topLeafPath = Path()
    ..moveTo(cx, cy - h * 0.1)
    ..quadraticBezierTo(cx - w * 0.1, cy - h * 0.35, cx, cy - h * 0.45)
    ..quadraticBezierTo(cx + w * 0.1, cy - h * 0.35, cx, cy - h * 0.1);
  canvas.drawPath(topLeafPath, paint);

  final leftLeafPath = Path()
    ..moveTo(cx - w * 0.08, cy)
    ..quadraticBezierTo(cx - w * 0.35, cy - h * 0.12, cx - w * 0.42, cy)
    ..quadraticBezierTo(cx - w * 0.35, cy + h * 0.12, cx - w * 0.08, cy);
  canvas.drawPath(leftLeafPath, paint);

  final rightLeafPath = Path()
    ..moveTo(cx + w * 0.08, cy)
    ..quadraticBezierTo(cx + w * 0.35, cy - h * 0.12, cx + w * 0.42, cy)
    ..quadraticBezierTo(cx + w * 0.35, cy + h * 0.12, cx + w * 0.08, cy);
  canvas.drawPath(rightLeafPath, paint);

  if (secondaryColor != null) {
    paint.color = secondaryColor;
  }

  final blLeafPath = Path()
    ..moveTo(cx - w * 0.05, cy + h * 0.15)
    ..quadraticBezierTo(
        cx - w * 0.28, cy + h * 0.28, cx - w * 0.22, cy + h * 0.45)
    ..quadraticBezierTo(
        cx - w * 0.08, cy + h * 0.28, cx - w * 0.05, cy + h * 0.15);
  canvas.drawPath(blLeafPath, paint);

  final brLeafPath = Path()
    ..moveTo(cx + w * 0.05, cy + h * 0.15)
    ..quadraticBezierTo(
        cx + w * 0.28, cy + h * 0.28, cx + w * 0.22, cy + h * 0.45)
    ..quadraticBezierTo(
        cx + w * 0.08, cy + h * 0.28, cx + w * 0.05, cy + h * 0.15);
  canvas.drawPath(brLeafPath, paint);
}

/// Reusable CropChain logo (for backward compat with register_page)
class CropChainLogo extends StatelessWidget {
  final bool dark;
  final double iconSize;
  final double fontSize;

  const CropChainLogo({
    super.key,
    this.dark = false,
    this.iconSize = 48,
    this.fontSize = 18,
  });

  @override
  Widget build(BuildContext context) {
    final color = dark ? Colors.white : AppColors.primaryGreen;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: iconSize,
          height: iconSize,
          child: CustomPaint(
            painter: _DarkLogoPainter(color: color),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'CROPCHAIN',
          style: TextStyle(
            color: color,
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }
}

class _DarkLogoPainter extends CustomPainter {
  final Color color;
  const _DarkLogoPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    _drawLogo(canvas, size, color);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
