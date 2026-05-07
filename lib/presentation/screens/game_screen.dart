import 'package:algoquest/presentation/widgets/game_hud.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:algoquest/application/level_state_provider.dart';
import 'package:algoquest/domain/entities/game_action.dart';
import 'package:algoquest/presentation/game/algoquest_game.dart';
import 'package:algoquest/presentation/widgets/debug_game_controls.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  late final AlgoQuestGame game;

  @override
  void initState() {
    super.initState();

    game = AlgoQuestGame()
      ..onSwapRequested = (firstNodeId, secondNodeId) {
        debugPrint('UI received swap request: $firstNodeId <-> $secondNodeId');
        ref
            .read(levelStateProvider.notifier)
            .executeAction(
              SwapNodesAction(
                firstNodeId: firstNodeId,
                secondNodeId: secondNodeId,
              ),
            );
      };
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(levelStateProvider);
    final notifier = ref.read(levelStateProvider.notifier);

    final spec = state.currentChallengeSpec;
    final session = state.currentSession;

    if (spec != null && session != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        game.updateScene(spec: spec, state: session.currentState);
      });
    }

    return Scaffold(
      appBar: AppBar(title: const Text('AlgoQuest')),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                GameWidget(game: game),
                GameHud(
                  status: state.status.name,
                  challengeId: state.currentChallengeId,
                  currentChallengeNumber: state.totalChallenges == 0
                      ? 0
                      : state.currentChallengeIndex + 1,
                  totalChallenges: state.totalChallenges,
                  movesUsed: state.currentSession?.movesUsed ?? 0,
                  instruction: state.currentChallengeSpec?.instruction,
                  onCheckSolution: state.currentSession == null
                      ? null
                      : () => notifier.checkSolution(),
                ),
              ],
            ),
          ),
          DebugGameControls(
            status: state.status.name,
            challengeId: state.currentChallengeId,
            currentChallengeNumber: state.totalChallenges == 0
                ? 0
                : state.currentChallengeIndex + 1,
            totalChallenges: state.totalChallenges,
            movesUsed: state.currentSession?.movesUsed ?? 0,
            errorMessage: state.errorMessage,
            canStartChallenge: state.currentChallengeId != null,
            canInteract: state.currentSession != null,
            onLoadLevel: () => notifier.loadLevel('level_heap_intro'),
            onStartChallenge: () => notifier.startCurrentChallenge(
              userId: 'user_1',
              sessionId: 'session_1',
            ),
            onSwapDebug: () => notifier.executeAction(
              const SwapNodesAction(firstNodeId: 'n1', secondNodeId: 'n2'),
            ),
            onCheckSolution: notifier.checkSolution,
            onCompleteChallenge: () => notifier.completeCurrentChallenge(
              userId: 'user_1',
              nextSessionId: 'session_${DateTime.now().millisecondsSinceEpoch}',
            ),
            onReset: notifier.resetLevelFlow,
          ),
        ],
      ),
    );
  }
}
