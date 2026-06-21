import 'package:algoquest/data/core/composition/app_composition.dart';
import 'package:algoquest/presentation/application_state/app_providers.dart';
import 'package:algoquest/presentation/router/app_router.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';

/// Application entry point.
///
/// Startup is divided into three steps:
/// 1. Initialize Flutter bindings.
/// 2. Apply platform-specific configuration.
/// 3. Build the dependency composition root and launch the application.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _configurePlatform();

  final appComposition = await AppComposition.build();

  runApp(
    ProviderScope(
      overrides: [
        // Use cases are created in the composition root and injected into
        // Riverpod so that the presentation layer depends only on abstractions.
        useCasesProvider.overrideWithValue(appComposition.useCases),
      ],
      child: const AlgoQuestApp(),
    ),
  );
}

/// Applies startup settings that depend on the target platform.
///
/// Android and desktop require different initialization logic:
/// - Android uses portrait orientation and immersive mode.
/// - Desktop uses a constrained and centered application window.
///
/// Web currently requires no additional platform configuration.
Future<void> _configurePlatform() async {
  if (_isAndroid) {
    await _configureAndroid();
  } else if (_isDesktop) {
    await _configureDesktopWindow();
  }
}

/// Configures the Android user interface.
///
/// The application is designed for portrait use and enables immersive sticky
/// mode so that system bars remain hidden during normal interaction while
/// still being temporarily accessible through system gestures.
Future<void> _configureAndroid() async {
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
}

/// Configures the native desktop window.
///
/// Window constraints are applied only on Windows, Linux, and macOS. They are
/// intentionally not initialized on Android or Web.
Future<void> _configureDesktopWindow() async {
  await windowManager.ensureInitialized();

  const windowOptions = WindowOptions(
    size: Size(575, 960),
    minimumSize: Size(575, 960),
    center: true,
  );

  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });
}

/// Whether the current target is Android.
///
/// The web check prevents platform-specific native initialization from being
/// executed when the application is compiled for a browser.
bool get _isAndroid {
  return !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
}

/// Whether the current target is a supported desktop platform.
bool get _isDesktop {
  if (kIsWeb) {
    return false;
  }

  return switch (defaultTargetPlatform) {
    TargetPlatform.windows ||
    TargetPlatform.linux ||
    TargetPlatform.macOS => true,
    _ => false,
  };
}

/// Root widget of the application.
///
/// Navigation is managed by GoRouter through [AppRouter], while dependency
/// injection is provided by the [ProviderScope] created in [main].
class AlgoQuestApp extends StatelessWidget {
  const AlgoQuestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'AlgoQuest',
      debugShowCheckedModeBanner: false,
      routerConfig: AppRouter.router,
    );
  }
}
