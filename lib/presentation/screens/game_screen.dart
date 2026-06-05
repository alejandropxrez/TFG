import 'package:algoquest/application/app_providers.dart';
import 'package:algoquest/application/level_state.dart';
import 'package:algoquest/application/level_state_provider.dart';
import 'package:algoquest/domain/entities/game_action.dart';
import 'package:algoquest/presentation/game/algoquest_game.dart';
import 'package:algoquest/presentation/widgets/debug_game_controls.dart';
import 'package:algoquest/presentation/widgets/feedback_dialog.dart';
import 'package:algoquest/presentation/widgets/game_hud.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GameScreen extends ConsumerStatefulWidget {
  final String levelId;

  const GameScreen({super.key, required this.levelId});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  late final AlgoQuestGame game;

  @override
  void initState() {
    super.initState();

    game = AlgoQuestGame()
      ..onActionRequested = (GameAction action) {
        ref.read(levelStateProvider.notifier).executeAction(action);
      };
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<LevelState>(levelStateProvider, (previous, next) {
      final spec = next.currentChallengeSpec;
      final session = next.currentSession;

      if (spec == null || session == null) {
        game.clearScene();
        return;
      }

      final previousSpecId = previous?.currentChallengeSpec?.id;
      final nextSpecId = spec.id;

      final previousState = previous?.currentSession?.currentState;
      final nextState = session.currentState;

      final shouldUpdateScene =
          previousSpecId != nextSpecId || previousState != nextState;

      if (!shouldUpdateScene) return;

      game.updateScene(spec: spec, state: nextState);
    });

    final state = ref.watch(levelStateProvider);
    final notifier = ref.read(levelStateProvider.notifier);
    final userId = ref.watch(currentUserIdProvider);

    final currentChallengeNumber = state.totalChallenges == 0
        ? 0
        : state.currentChallengeIndex + 1;

    return Scaffold(
      appBar: AppBar(title: const Text('AlgoQuest')),
      body: Column(
        children: [
          GameHud(
            status: state.status.name,
            challengeId: state.currentChallengeId,
            currentChallengeNumber: currentChallengeNumber,
            totalChallenges: state.totalChallenges,
            movesUsed: state.currentSession?.movesUsed ?? 0,
            instruction: state.currentChallengeSpec?.instruction,
            onCheckSolution: state.currentSession == null
                ? null
                : () => _showFeedbackDialog(
                    context: context,
                    notifier: notifier,
                    state: state,
                  ),
          ),
          Expanded(child: GameWidget(game: game)),
          DebugGameControls(
            status: state.status.name,
            challengeId: state.currentChallengeId,
            currentChallengeNumber: currentChallengeNumber,
            totalChallenges: state.totalChallenges,
            movesUsed: state.currentSession?.movesUsed ?? 0,
            errorMessage: state.errorMessage,
            canStartChallenge: state.currentChallengeId != null,
            canInteract: state.currentSession != null,
            onLoadLevel: () => notifier.loadLevel(widget.levelId),
            onStartChallenge: () => notifier.startCurrentChallenge(
              userId: userId,
              sessionId: 'session_1',
            ),
            onSwapDebug: () => notifier.executeAction(
              const SwapNodesAction(firstNodeId: 'n1', secondNodeId: 'n2'),
            ),
            onCheckSolution: () => _showFeedbackDialog(
              context: context,
              notifier: notifier,
              state: state,
            ),
            onCompleteChallenge: () => notifier.completeCurrentChallenge(
              userId: userId,
              nextSessionId: 'session_${DateTime.now().millisecondsSinceEpoch}',
            ),
            onReset: notifier.resetLevelFlow,
          ),
        ],
      ),
    );
  }

  void _showFeedbackDialog({
    required BuildContext context,
    required LevelStateNotifier notifier,
    required LevelState state,
  }) {
    final solved = notifier.checkSolution();

    showDialog<void>(
      context: context,
      builder: (_) => FeedbackDialog(
        solved: solved,
        theoryRef: state.currentChallengeSpec?.theoryRef,
        onContinue: solved
            ? () {
                final userId = ref.read(currentUserIdProvider);

                notifier.completeCurrentChallenge(
                  userId: userId,
                  nextSessionId:
                      'session_${DateTime.now().millisecondsSinceEpoch}',
                );
              }
            : null,
      ),
    );
  }
}
