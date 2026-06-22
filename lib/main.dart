import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Fallback accent used until a dominant color is extracted from album art
/// (deep purple, per the design spec).
const Color kFallbackAccent = Color(0xFF7F77DD);

/// AMOLED-safe true black background.
const Color kTrueBlack = Color(0xFF000000);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Edge-to-edge, dark system bars over true black.
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: kTrueBlack,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const ProviderScope(child: SonataApp()));
}

class SonataApp extends StatelessWidget {
  const SonataApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: kFallbackAccent,
      brightness: Brightness.dark,
    ).copyWith(surface: kTrueBlack);

    return MaterialApp(
      title: 'Sonata',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      theme: _buildTheme(scheme),
      darkTheme: _buildTheme(scheme),
      home: const ScaffoldReadyScreen(),
    );
  }

  ThemeData _buildTheme(ColorScheme scheme) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: kTrueBlack,
      canvasColor: kTrueBlack,
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: const AppBarTheme(
        backgroundColor: kTrueBlack,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
    );
  }
}

/// Temporary landing screen. Confirms the scaffold runs end-to-end on device;
/// replaced by the Library screen in deliverable 9.
class ScaffoldReadyScreen extends StatelessWidget {
  const ScaffoldReadyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.graphic_eq_rounded, size: 72, color: scheme.primary),
            const SizedBox(height: 24),
            Text(
              'Sonata',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Scaffold ready · deliverable 1 complete',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white60,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
