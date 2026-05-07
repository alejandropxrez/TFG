import 'package:algoquest/presentation/screens/game_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'application/level_state_provider.dart';
import 'core/composition/app_composition.dart';

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
    return const MaterialApp(home: GameScreen());
  }
}
