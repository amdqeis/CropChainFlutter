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
  final VoidCallback? onSignIn;
  final VoidCallback? onCreateAccount;

  const SplashPage({super.key, this.onSignIn, this.onCreateAccount});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryGreenDark,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Layer 1: Farm photo background ──────────────────────
          Image.asset(
            'assets/images/login_bg.jpg',
            fit: BoxFit.cover,
          ),

          // ── Layer 2: Gradient scrim (transparent → deep green-black) ──
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x00000000), // fully transparent at top
                  Color(0x55000000), // subtle mid-shadow
                  Color(0xCC001A00), // deep green-black at bottom
                ],
                stops: [0.0, 0.45, 1.0],
              ),
            ),
          ),

          // ── Layer 3: Content ─────────────────────────────────────
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: Column(
                children: [
                  // Logo + tagline centred in the upper portion
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset(
                            _kLogoSvg,
                            height: 130,
                            colorFilter: const ColorFilter.mode(
                              Colors.white,
                              BlendMode.srcIn,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'Fresh from farm to your table',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.75),
                              letterSpacing: 0.4,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Buttons sliding up from bottom
                  SlideTransition(
                    position: _slideAnim,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(32, 0, 32, 52),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Sign In — solid green button
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: () {
                                if (widget.onSignIn != null) {
                                  widget.onSignIn!();
                                } else {
                                  Navigator.pushNamed(context, '/login');
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4A7C3F),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: const Text(
                                'Sign in',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Create account — outlined ghost button
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: OutlinedButton(
                              onPressed: () {
                                if (widget.onCreateAccount != null) {
                                  widget.onCreateAccount!();
                                } else {
                                  Navigator.pushNamed(context, '/register');
                                }
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: const BorderSide(
                                    color: Colors.white70, width: 1.5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                backgroundColor:
                                    Colors.white.withValues(alpha: 0.12),
                              ),
                              child: const Text(
                                'Create an account',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Fine print
                          Text(
                            'By continuing you agree to our Terms & Privacy Policy',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white.withValues(alpha: 0.45),
                            ),
                          ),
                        ],
                      ),
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
