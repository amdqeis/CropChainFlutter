import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/theme/app_theme.dart';

const String _kLogoSvg = 'assets/images/cropchain_logo.svg';

// ─────────────────────────────────────────────────────────────────────────────
/// SPLASH LOADING PAGE  (Screenshot 2 — white bg + coloured logo)
///
/// Animation flow:
///   0ms    → logo fades-in + scales up with easeOutBack (slight overshoot)
///   ~1400ms → brief hold
///   1600ms → full screen fades out, then navigate
// ─────────────────────────────────────────────────────────────────────────────
class SplashLoadingPage extends StatefulWidget {
  const SplashLoadingPage({super.key});

  @override
  State<SplashLoadingPage> createState() => _SplashLoadingPageState();
}

class _SplashLoadingPageState extends State<SplashLoadingPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  // Logo fade-in: 0 – 50 %
  late final Animation<double> _fadeIn;
  // Logo scale: 0 – 55 % (easeOutBack gives a natural bounce)
  late final Animation<double> _scale;
  // Full-screen fade-out: 78 – 100 %
  late final Animation<double> _fadeOut;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.50, curve: Curves.easeOut),
      ),
    );

    _scale = Tween<double>(begin: 0.80, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.55, curve: Curves.easeOutBack),
      ),
    );

    _fadeOut = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.78, 1.0, curve: Curves.easeIn),
      ),
    );

    _ctrl.forward().then((_) {
      if (mounted) Navigator.pushReplacementNamed(context, '/splash');
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) => Opacity(
          opacity: _fadeOut.value,
          child: Center(
            child: Opacity(
              opacity: _fadeIn.value,
              child: Transform.scale(
                scale: _scale.value,
                child: SvgPicture.asset(_kLogoSvg, height: 110),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
/// SPLASH / WELCOME PAGE  (Screenshot 1 — farm bg + logo + CTA buttons)
///
/// Staggered animation — single 1 400 ms controller, four Interval layers:
///   0 – 40 %  → background gradient scrim fades in
///   10 – 62 % → logo fades + floats up (small offset)
///   28 – 72 % → tagline fades in
///   48 – 100% → buttons slide up from bottom + fade in
// ─────────────────────────────────────────────────────────────────────────────
class SplashPage extends StatefulWidget {
  final VoidCallback? onSignIn;
  final VoidCallback? onCreateAccount;

  const SplashPage({super.key, this.onSignIn, this.onCreateAccount});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  late final Animation<double> _bgFade;
  late final Animation<double> _logoFade;
  late final Animation<Offset> _logoSlide;
  late final Animation<double> _taglineFade;
  late final Animation<double> _btnFade;
  late final Animation<Offset> _btnSlide;

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _bgFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.40, curve: Curves.easeOut),
      ),
    );

    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.10, 0.62, curve: Curves.easeOut),
      ),
    );

    _logoSlide = Tween<Offset>(
      begin: const Offset(0, 0.10),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.10, 0.65, curve: Curves.easeOutCubic),
      ),
    );

    _taglineFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.28, 0.72, curve: Curves.easeOut),
      ),
    );

    _btnFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.52, 0.90, curve: Curves.easeOut),
      ),
    );

    _btnSlide = Tween<Offset>(
      begin: const Offset(0, 0.28),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.48, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryGreenDark,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Layer 1: Farm photo background ──────────────────────────────
          Image.asset('assets/images/login_bg.jpg', fit: BoxFit.cover),

          // ── Layer 2: Gradient scrim — fades in first ─────────────────────
          AnimatedBuilder(
            animation: _bgFade,
            builder: (_, __) => Opacity(
              opacity: _bgFade.value,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0x00000000),
                      Color(0x55000000),
                      Color(0xCC001A00),
                    ],
                    stops: [0.0, 0.45, 1.0],
                  ),
                ),
              ),
            ),
          ),

          // ── Layer 3: Content ─────────────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                // Logo + tagline
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Logo: fade + float up
                        AnimatedBuilder(
                          animation: _ctrl,
                          builder: (_, child) => SlideTransition(
                            position: _logoSlide,
                            child: Opacity(
                              opacity: _logoFade.value,
                              child: child,
                            ),
                          ),
                          child: SvgPicture.asset(
                            _kLogoSvg,
                            height: 130,
                            colorFilter: const ColorFilter.mode(
                              Colors.white,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Tagline: fades in after logo
                        AnimatedBuilder(
                          animation: _taglineFade,
                          builder: (_, __) => Opacity(
                            opacity: _taglineFade.value,
                            child: Text(
                              'Fresh from farm to your table',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withValues(alpha: 0.75),
                                letterSpacing: 0.4,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Buttons: slide up from bottom
                AnimatedBuilder(
                  animation: _ctrl,
                  builder: (_, child) => SlideTransition(
                    position: _btnSlide,
                    child: Opacity(opacity: _btnFade.value, child: child),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(32, 0, 32, 52),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
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
        ],
      ),
    );
  }
}
