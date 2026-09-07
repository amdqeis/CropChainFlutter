import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

const String _kLogoSvg = 'assets/images/cropchain_logo.svg';
const String _kLayer1Svg = 'assets/images/Layer_1.svg';

// ─────────────────────────────────────────────────────────────────────────────
/// SPLASH LOADING PAGE  (Figma Frame 2 — white bg + coloured logo)
///
/// Pixel-accurate to Figma Frame 2 ("iPhone 16 & 17 Pro - 2"):
///   - Frame: 402 × 874
///   - Logo node "Layer_1": x=76, y=334, w=250, h=130
///   - Background: solid white (#FFFFFF)
///   - Logo centred horizontally, positioned at 38.2 % from top
///
/// Uses Layer_1.svg — the official CropChain logo + text SVG from Figma.
// ─────────────────────────────────────────────────────────────────────────────
class SplashLoadingPage extends StatefulWidget {
  const SplashLoadingPage({super.key});

  @override
  State<SplashLoadingPage> createState() => _SplashLoadingPageState();
}

class _SplashLoadingPageState extends State<SplashLoadingPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fadeIn;
  late final Animation<double> _scale;
  late final Animation<double> _fadeOut;

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

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

    _scale = Tween<double>(begin: 0.85, end: 1.0).animate(
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
    // Figma: logo at y=334 / 874 = 38.2% from top
    // Logo center = (334 + 130/2) / 874 = 45.6% from top
    // Alignment.y: -1 = top, 0 = center, 1 = bottom
    // offset = (0.456 - 0.5) × 2 = -0.088 ≈ -0.09
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) => Opacity(
          opacity: _fadeOut.value,
          child: Center(
            child: FractionalTranslation(
              translation: const Offset(0, -0.09),
              child: Opacity(
                opacity: _fadeIn.value,
                child: Transform.scale(
                  scale: _scale.value,
                  // Figma: logo is 250×130 in 402-wide frame (62% of width)
                  child: SvgPicture.asset(
                    _kLayer1Svg,
                    width: 250,
                    height: 130,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}


// ─────────────────────────────────────────────────────────────────────────────
/// SPLASH / WELCOME PAGE  (Figma Frame 1 — "iPhone 16 & 17 Pro - 1")
///
/// PIXEL-ACCURATE to Figma Frame 1:
///   - Frame: 402 × 874
///   - Background: farm photo full-bleed (1565×876, offset x=-808)
///   - Logo ("Layer_1"): x=78, y=270, w=249, h=130  → 30.9% from top
///   - "Sign in" button: y=413, w=314 (padded 44 from sides)
///     - glassmorphic: rgba(255,255,255,0.1), rounded-77, inset shadows
///     - text: "Sign in", Inter SemiBold 20px, white
///   - "Create an account": y=488, plain text, Inter SemiBold 20px, white
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

  late final Animation<double> _logoFade;
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
      duration: const Duration(milliseconds: 1200),
    );

    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.55, curve: Curves.easeOut),
      ),
    );

    _btnFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.40, 0.85, curve: Curves.easeOut),
      ),
    );

    _btnSlide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.40, 0.90, curve: Curves.easeOutCubic),
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
    final screenH = MediaQuery.of(context).size.height;
    final screenW = MediaQuery.of(context).size.width;

    // Figma positions (frame 402×874):
    //   Logo: y=270, h=130      → top fraction = 270/874 = 0.309
    //   Sign in btn: y=413+13=426 (inner rect top) → 0.487 but container y=413 → 0.473
    //   Create account: y=488   → top fraction = 488/874 = 0.558
    //   Logo: w=249             → w = screenW * 249/402
    //   Button: padded 44px from left/right in 402 frame

    final logoTop = screenH * (270 / 874);
    final logoW = screenW * (249 / 402);
    final logoH = screenH * (130 / 874);
    final btnTop = screenH * (413 / 874);
    final btnH = screenH * (49 / 874);
    final createTop = screenH * (488 / 874);
    final sidePadding = screenW * (44 / 402);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Layer 1: Farm photo background (full-bleed) ─────────────────
          // Figma: image 1565×876, offset x=-808 in 402-wide frame
          // Visible area starts at x=808 of original → right portion of image
          Image.asset(
            'assets/images/login_bg.jpg',
            fit: BoxFit.cover,
            alignment: const Alignment(0.3, 0.0),
          ),

          // ── Layer 2: Subtle dark overlay for text readability ───────────
          Container(color: Colors.black.withValues(alpha: 0.12)),

          // ── Layer 3: Logo (white SVG) — positioned at Figma y=270 ──────
          Positioned(
            top: logoTop,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _logoFade,
              builder: (_, child) => Opacity(
                opacity: _logoFade.value,
                child: child,
              ),
              child: Center(
                child: SvgPicture.asset(
                  _kLogoSvg,
                  width: logoW,
                  height: logoH,
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),

          // ── Layer 4: "Sign in" glassmorphic button at Figma y=413 ──────
          Positioned(
            top: btnTop,
            left: sidePadding,
            right: sidePadding,
            child: AnimatedBuilder(
              animation: _ctrl,
              builder: (_, child) => SlideTransition(
                position: _btnSlide,
                child: Opacity(opacity: _btnFade.value, child: child),
              ),
              child: GestureDetector(
                onTap: () {
                  if (widget.onSignIn != null) {
                    widget.onSignIn!();
                  } else {
                    Navigator.pushNamed(context, '/login');
                  }
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(77),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: Container(
                      height: btnH.clamp(44.0, 56.0),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(77),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.25),
                          width: 0.5,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'Sign in',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Layer 5: "Create an account" plain text at Figma y=488 ─────
          Positioned(
            top: createTop,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _ctrl,
              builder: (_, child) => SlideTransition(
                position: _btnSlide,
                child: Opacity(opacity: _btnFade.value, child: child),
              ),
              child: GestureDetector(
                onTap: () {
                  if (widget.onCreateAccount != null) {
                    widget.onCreateAccount!();
                  } else {
                    Navigator.pushNamed(context, '/register');
                  }
                },
                child: const Center(
                  child: Text(
                    'Create an account',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
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
