import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'library/library_screen.dart';
import 'settings/settings_providers.dart';

/// Fallback accent (deep purple) until a dominant color is extracted from album
/// art in a later deliverable.
const Color kFallbackAccent = Color(0xFF7F77DD);

/// AMOLED-safe true black.
const Color kTrueBlack = Color(0xFF000000);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: kTrueBlack,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Configure the platform audio session for music (audio focus, ducking,
  // pause-on-headphone-unplug). Background/lock-screen controls arrive with the
  // audio_service integration (deliverable 11).
  final session = await AudioSession.instance;
  await session.configure(const AudioSessionConfiguration.music());

  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const SonataApp(),
    ),
  );
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
      theme: ThemeData(
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
      ),
      home: const LibraryScreen(),
    );
  }
}
