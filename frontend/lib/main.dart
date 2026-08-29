import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'features/auth/pages/splash_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const CropChainApp());
}

class CropChainApp extends StatelessWidget {
  const CropChainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CropChain',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      navigatorKey: AppRouter.navigatorKey,
      onGenerateRoute: AppRouter.generateRoute,
      home: const SplashLoadingPage(),
    );
  }
}
