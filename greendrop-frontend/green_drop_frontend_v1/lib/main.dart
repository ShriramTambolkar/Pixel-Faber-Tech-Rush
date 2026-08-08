import 'package:flutter/material.dart';
import 'screens/splash/splash_screen.dart';

void main() {
  // 1. Ensure Flutter Engine bindings are initialized before app launch
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Launch root application immediately for instant cold start
  runApp(const GreenDropApp());

  // 3. Defer non-critical SDK initializations to post-frame callback
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _initializeBackgroundServices();
  });
}

void _initializeBackgroundServices() {
  // Non-blocking background initializations (analytics, logging, caches)
  debugPrint('⚡ GreenDrop: Non-critical background services initialized post-frame.');
}

class GreenDropApp extends StatelessWidget {
  const GreenDropApp({super.key});

  // Cached Theme Data to avoid recalculation on every build frame
  static final ThemeData _appTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF1E5631),
      primary: const Color(0xFF1E5631),
      secondary: const Color(0xFF4C9A2A),
      surface: const Color(0xFFF8FAF7),
      brightness: Brightness.light,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Color(0xFFE1E9DF)),
      ),
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFD5E2D3))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFD5E2D3))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF1E5631), width: 1.5)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    navigationBarTheme: const NavigationBarThemeData(
      height: 70,
      indicatorColor: Color(0xFFD9EED7),
      labelTextStyle: WidgetStatePropertyAll(TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GreenDrop',
      debugShowCheckedModeBanner: false,
      theme: _appTheme,
      home: const SplashScreen(),
    );
  }
}
