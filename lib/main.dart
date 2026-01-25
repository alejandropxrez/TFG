import 'package:algoquest/core/composition/app_composition.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  await AppComposition.build();

  runApp(GameWidget(game: FlameGame()));
}
