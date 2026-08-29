import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/theme/app_theme.dart';

const String _kLogoSvg = 'assets/images/cropchain_logo.svg';

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
        child: Center(
          // Logo SVG asli Figma (includes icon + "CROPCHAIN" text)
          child: SvgPicture.asset(_kLogoSvg, height: 110),
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
                    child: SvgPicture.asset(
                      _kLogoSvg,
                      height: 120,
                      // Warnakan putih semua path agar kontras di atas background gelap
                      colorFilter: const ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
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
