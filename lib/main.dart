import 'package:algoquest/presentation/application_state/app_providers.dart';
import 'package:algoquest/data/core/composition/app_composition.dart';
import 'package:algoquest/presentation/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await windowManager.ensureInitialized();
  const windowOptions = WindowOptions(
    size: Size(575, 960),
    minimumSize: Size(575, 960),
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  final appComposition = await AppComposition.build();

  runApp(
    ProviderScope(
      overrides: [useCasesProvider.overrideWithValue(appComposition.useCases)],
      child: const AlgoQuestApp(),
    ),
  );
}

class AlgoQuestApp extends StatelessWidget {
  const AlgoQuestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'AlgoQuest',
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
    );
  }
}
