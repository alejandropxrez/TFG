import 'package:algoquest/application/level_state_provider.dart';
import 'package:algoquest/core/composition/app_composition.dart';
import 'package:algoquest/presentation/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
