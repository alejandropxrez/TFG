import 'package:algoquest/application/app_providers.dart';
import 'package:algoquest/application/level_state.dart';
import 'package:algoquest/application/level_state_provider.dart';
import 'package:algoquest/domain/entities/challenge_runtime_state.dart';
import 'package:algoquest/domain/entities/challenge_spec.dart';
import 'package:algoquest/domain/entities/game_action.dart';
import 'package:algoquest/presentation/game/algoquest_game.dart';
import 'package:algoquest/presentation/widgets/debug_game_controls.dart';
import 'package:algoquest/presentation/widgets/feedback_dialog.dart';
import 'package:algoquest/presentation/widgets/game_hud.dart';
import 'package:algoquest/presentation/widgets/quiz_challenge_view.dart';
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

      final runtimeState = session.runtimeState;

      if (runtimeState is! StructureRuntimeState) {
        game.clearScene();
        return;
      }

      final previousSpecId = previous?.currentChallengeSpec?.id;
      final nextSpecId = spec.id;

      final previousRuntimeState = previous?.currentSession?.runtimeState;
      final previousStructure = previousRuntimeState is StructureRuntimeState
          ? previousRuntimeState.structure
          : null;

      final nextStructure = runtimeState.structure;

      final shouldUpdateScene =
          previousSpecId != nextSpecId || previousStructure != nextStructure;

      if (!shouldUpdateScene) return;

      game.updateScene(spec: spec, state: nextStructure);
    });

    final state = ref.watch(levelStateProvider);
    final notifier = ref.read(levelStateProvider.notifier);
    final userId = ref.watch(currentUserIdProvider);

    final currentChallengeNumber = state.currentChallengeNumber;

    return Scaffold(
      appBar: AppBar(title: const Text('AlgoQuest')),
      body: Column(
        children: [
          GameHud(
            status: state.status.name,
            challengeId: state.currentChallengeId,
            currentChallengeNumber: currentChallengeNumber,
            totalChallenges: state.totalChallenges,
            movesUsed: _movesUsed(state),
            attemptsRemaining: state.currentSession?.attemptsRemaining,
            instruction: state.currentChallengeSpec?.instruction,
            onCheckSolution: state.currentSession == null
                ? null
                : () => _showFeedbackDialog(
                    context: context,
                    notifier: notifier,
                    state: state,
                  ),
          ),
          Expanded(
            child: _buildChallengeBody(
              state: state,
              notifier: notifier,
              game: game,
            ),
          ),
          DebugGameControls(
            status: state.status.name,
            challengeId: state.currentChallengeId,
            currentChallengeNumber: currentChallengeNumber,
            totalChallenges: state.totalChallenges,
            movesUsed: _movesUsed(state),
            errorMessage: state.errorMessage,
            canStartChallenge: state.currentChallengeId != null,
            canInteract: state.currentSession != null,
            canUndo: _canUndo(state),
            canRedo: _canRedo(state),
            onLoadLevel: () => notifier.loadLevel(widget.levelId),
            onStartChallenge: () => notifier.startCurrentChallenge(
              userId: userId,
              sessionId: 'session_1',
            ),
            onSwapDebug: () => notifier.executeAction(
              const SwapNodesAction(firstNodeId: 'n1', secondNodeId: 'n2'),
            ),
            onUndo: notifier.undoLastAction,
            onRedo: notifier.redoLastAction,
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
            attemptsRemaining: state.currentSession?.attemptsRemaining,
          ),
        ],
      ),
    );
  }

  Widget _buildChallengeBody({
    required LevelState state,
    required LevelStateNotifier notifier,
    required AlgoQuestGame game,
  }) {
    final spec = state.currentChallengeSpec;
    final session = state.currentSession;

    if (spec == null || session == null) {
      return GameWidget(game: game);
    }

    final content = spec.content;
    final runtimeState = session.runtimeState;

    if (content is QuizChallengeContent && runtimeState is QuizRuntimeState) {
      return QuizChallengeView(
        quizSpec: content.quizSpec,
        selectedOptionIds: runtimeState.selectedOptionIds,
        onSelectOption: (optionId) {
          final currentSelected = runtimeState.selectedOptionIds;

          final nextSelected = content.quizSpec.allowMultiple
              ? currentSelected.contains(optionId)
                    ? ({...currentSelected}..remove(optionId))
                    : {...currentSelected, optionId}
              : {optionId};

          notifier.submitQuizAnswer(nextSelected);
        },
      );
    }

    return GameWidget(game: game);
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

  int _movesUsed(LevelState state) {
    final runtimeState = state.currentSession?.runtimeState;

    if (runtimeState is StructureRuntimeState) {
      return runtimeState.movesUsed;
    }

    return 0;
  }

  bool _canUndo(LevelState state) {
    final runtimeState = state.currentSession?.runtimeState;

    return runtimeState is StructureRuntimeState &&
        runtimeState.history.isNotEmpty;
  }

  bool _canRedo(LevelState state) {
    final runtimeState = state.currentSession?.runtimeState;

    return runtimeState is StructureRuntimeState &&
        runtimeState.redoStack.isNotEmpty;
  }
}
