import 'package:algoquest/application/level_state_provider.dart';
import 'package:algoquest/core/composition/app_composition.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  final app = await AppComposition.build();

  runApp(
    ProviderScope(
      overrides: [useCasesProvider.overrideWithValue(app.useCases)],
      child: GameWidget(game: FlameGame()),
    ),
  );
}
