import 'package:flutter/material.dart';
import '../../features/auth/pages/splash_page.dart';
import '../../features/auth/pages/login_page.dart';
import '../../features/auth/pages/register_page.dart';
import '../../features/buyer/pages/buyer_pages.dart';
import '../../features/distributor/pages/distributor_pages.dart';
import '../../features/farmer/pages/farmer_pages.dart';

/// CropChain Route Table
/// Uses Navigator 1.0 with named routes for simplicity across all pages.
class AppRouter {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // ─── Auth ───────────────────────────────────────
      case '/splash':
        return _fade(const SplashPage());
      case '/login':
        return _fade(LoginPage(
          onLoginSuccess: (role) => _navigateToHome(settings, role),
          onCreateAccount: () {},
        ));
      case '/register':
        return _slide(RegisterFormPage(
          onRegisterSuccess: () {},
          onBack: () {},
        ));
      case '/verification':
        return _slide(VerificationCodePage(
          email: 'user@example.com',
          onVerified: () {},
          onBack: () {},
        ));
      case '/role-select':
        return _slide(RegisterRolePage(
          onRoleSelected: (role) {},
        ));

      // ─── Buyer ──────────────────────────────────────
      case '/buyer/home':
        return _fade(const BuyerHomePage());
      case '/buyer/search':
        return _slide(const BuyerSearchPage());
      case '/buyer/shop':
        return _slide(const BuyerShopPage());
      case '/buyer/product-detail':
        return _slide(const BuyerProductDetailPage());
      case '/buyer/cart':
        return _slide(const BuyerCartPage());
      case '/buyer/checkout':
        return _slide(const BuyerCheckoutPage());
      case '/buyer/payment':
        return _slide(const BuyerPaymentPage());
      case '/buyer/payment-success':
        return _slide(const BuyerPaymentSuccessPage());
      case '/buyer/order-status':
        return _slide(const BuyerOrderStatusPage());
      case '/buyer/tracking':
        return _slide(const BuyerTrackingPage());
      case '/buyer/profile':
        return _fade(const BuyerProfilePage());
      // Buyer sub-pages
      case '/buyer/address':
        return _slide(const BuyerAddressPage());
      case '/buyer/payment-method':
        return _slide(const BuyerPaymentMethodPage());
      case '/buyer/notifications':
        return _slide(const BuyerNotificationsPage());
      case '/buyer/help':
        return _slide(const BuyerHelpPage());
      case '/buyer/about':
        return _slide(const BuyerAboutPage());

      // ─── Distributor ────────────────────────────────
      case '/distributor/home':
        return _fade(const DistributorHomePage());
      case '/distributor/farmer-offers':
        return _slide(const DistributorFarmerOffersPage());
      case '/distributor/farmer-offer-detail':
        return _slide(const DistributorFarmerOfferDetailPage());
      case '/distributor/stock':
        return _slide(const DistributorStockPage());
      case '/distributor/stock-detail':
        return _slide(const DistributorStockDetailPage());
      case '/distributor/create-product':
        return _slide(const DistributorCreateProductPage());
      case '/distributor/product-created':
        return _slide(const DistributorProductCreatedPage());
      case '/distributor/active-products':
        return _slide(const DistributorActiveProductsPage());
      case '/distributor/product-detail':
        return _slide(const DistributorProductDetailPage());
      case '/distributor/change-product-status':
        return _slide(const DistributorChangeProductStatusPage());
      case '/distributor/orders':
        return _slide(const DistributorOrdersPage());
      case '/distributor/order-detail':
        return _slide(const DistributorOrderDetailPage());
      case '/distributor/change-order-status':
        return _slide(const DistributorChangeOrderStatusPage());
      case '/distributor/order-shipped':
        return _slide(const DistributorOrderShippedPage());
      case '/distributor/income':
        return _slide(const DistributorIncomePage());
      case '/distributor/profile':
        return _fade(const DistributorProfilePage());

      // ─── Farmer ─────────────────────────────────────
      case '/farmer/home':
        return _fade(const FarmerHomePage());
      case '/farmer/create-offer':
        return _slide(const FarmerCreateOfferPage());
      case '/farmer/offer-sent':
        return _slide(const FarmerOfferSentPage());
      case '/farmer/active-offers':
        return _slide(const FarmerActiveOffersPage());
      case '/farmer/recent-offers':
        return _slide(const FarmerRecentOffersPage());
      case '/farmer/counter-offer':
        return _slide(const FarmerCounterOfferPage());
      case '/farmer/harvest':
        return _slide(const FarmerHarvestPage());
      case '/farmer/income':
        return _slide(const FarmerIncomePage());
      case '/farmer/profile':
        return _fade(const FarmerProfilePage());

      // ─── Fallback ────────────────────────────────────
      default:
        return _fade(const SplashPage());
    }
  }

  // Navigate to the correct home based on role
  static void _navigateToHome(RouteSettings settings, String role) {
    final route = switch (role) {
      'distributor' => '/distributor/home',
      'farmer' => '/farmer/home',
      _ => '/buyer/home',
    };
    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      route,
      (r) => false,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Transitions
  // ─────────────────────────────────────────────────────────────────────────

  /// Fade + subtle scale-up (0.96 → 1.0).
  /// Used for: home pages, profile — "arriving" feel.
  static PageRoute _fade(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,
      transitionDuration: const Duration(milliseconds: 280),
      reverseTransitionDuration: const Duration(milliseconds: 220),
      transitionsBuilder: (_, animation, __, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOut,
          reverseCurve: Curves.easeIn,
        );
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.96, end: 1.0).animate(curved),
            child: child,
          ),
        );
      },
    );
  }

  /// Horizontal micro-slide (5 %) + crossfade.
  /// Used for: sub-pages, detail views — feels like content "stepping in".
  static PageRoute _slide(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 250),
      transitionsBuilder: (_, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );

        // Outgoing page slides slightly to the left
        final secondaryCurved = CurvedAnimation(
          parent: secondaryAnimation,
          curve: Curves.easeOutCubic,
        );

        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.05, 0),
            end: Offset.zero,
          ).animate(curved),
          child: FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: Offset.zero,
                end: const Offset(-0.05, 0),
              ).animate(secondaryCurved),
              child: child,
            ),
          ),
        );
      },
    );
  }
}

