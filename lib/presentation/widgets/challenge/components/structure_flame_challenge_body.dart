import 'package:algoquest/presentation/game/algoquest_game.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class StructureFlameChallengeBody extends StatelessWidget {
  final AlgoQuestGame game;

  const StructureFlameChallengeBody({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 360,
      width: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: GameWidget(game: game),
      ),
    );
  }
}
