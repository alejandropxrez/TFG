import 'package:algoquest/data/core/composition/app_composition.dart';
import 'package:algoquest/presentation/application_state/app_providers.dart';
import 'package:algoquest/presentation/router/app_router.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _configurePlatform();

  final appComposition = await AppComposition.build();

  runApp(
    ProviderScope(
      overrides: [
        useCasesProvider.overrideWithValue(appComposition.useCases),
      ],
      child: const AlgoQuestApp(),
    ),
  );
}

Future<void> _configurePlatform() async {
  if (_isAndroid) {
    await _configureAndroid();
  }

  if (_isDesktop) {
    await _configureDesktopWindow();
  }
}

Future<void> _configureAndroid() async {
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  await SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.immersiveSticky,
  );
}

Future<void> _configureDesktopWindow() async {
  await windowManager.ensureInitialized();

  const windowOptions = WindowOptions(
    size: Size(575, 960),
    minimumSize: Size(575, 960),
    center: true,
  );

  await windowManager.waitUntilReadyToShow(
    windowOptions,
        () async {
      await windowManager.show();
      await windowManager.focus();
    },
  );
}

bool get _isAndroid {
  return !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
}

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