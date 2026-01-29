import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import 'package:turtle/core/theme/app_theme.dart';
import 'package:turtle/features/home/presentation/pages/main_scaffold.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:turtle/features/settings/presentation/providers/settings_providers.dart';

import 'package:permission_handler/permission_handler.dart';

import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  // Request storage permissions on startup
  await _requestPermissions();

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const TurtleApp(),
    ),
  );
}

Future<void> _requestPermissions() async {
  if (Platform.isAndroid) {
    // For Android 13+ (API 33+), we need specific media permissions
    // but background_downloader handles much of this.
    // We request basic storage/media permissions to be safe and clear with the user.
    await [
      Permission.storage,
      Permission.videos,
      Permission.audio,
      Permission
          .manageExternalStorage, // Only if needed, but storage + media is usually enough
    ].request();
  }
}

class TurtleApp extends ConsumerWidget {
  const TurtleApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        // Create themes using dynamic colors if available, otherwise fallback to default seed
        final lightTheme = lightDynamic != null
            ? AppTheme.createTheme(lightDynamic)
            : AppTheme.lightTheme;

        final darkTheme = darkDynamic != null
            ? AppTheme.createTheme(darkDynamic)
            : AppTheme.darkTheme;

        return MaterialApp(
          title: 'Turtle',
          debugShowCheckedModeBanner: false,
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: themeMode,
          home: const MainScaffold(),
        );
      },
    );
  }
}
