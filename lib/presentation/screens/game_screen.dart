import 'package:algoquest/domain/entities/challenge_runtime_state.dart';
import 'package:algoquest/domain/entities/challenge_spec.dart';
import 'package:algoquest/domain/entities/game_action.dart';
import 'package:algoquest/presentation/application_state/app_providers.dart';
import 'package:algoquest/presentation/application_state/level_state.dart';
import 'package:algoquest/presentation/application_state/level_state_provider.dart';
import 'package:algoquest/presentation/game/algoquest_game.dart';
import 'package:algoquest/presentation/game/strategies/interaction/identify_interaction_strategy.dart';
import 'package:algoquest/presentation/router/app_router.dart';
import 'package:algoquest/presentation/widgets/categorize_challenge_view.dart';
import 'package:algoquest/presentation/widgets/challenge_result_dialog.dart';
import 'package:algoquest/presentation/widgets/debug_game_controls.dart';
import 'package:algoquest/presentation/widgets/feedback_dialog.dart';
import 'package:algoquest/presentation/widgets/game_hud.dart';
import 'package:algoquest/presentation/widgets/level_intro/level_intro_view.dart';
import 'package:algoquest/presentation/widgets/quiz_challenge_view.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(levelStateProvider.notifier).loadLevel(widget.levelId);
    });
  }

  @override
  void didUpdateWidget(covariant GameScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.levelId != widget.levelId) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(levelStateProvider.notifier).loadLevel(widget.levelId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<LevelState>(levelStateProvider, (previous, next) {
      _syncGameScene(previous: previous, next: next);
      _startChallengeAutomaticallyIfNeeded(next);
    });

    final state = ref.watch(levelStateProvider);
    final notifier = ref.read(levelStateProvider.notifier);
    final userId = ref.watch(currentUserIdProvider);

    final syllabus = state.syllabus;
    final theory = syllabus?.theory;

    final shouldShowLevelIntro =
        syllabus != null &&
        theory != null &&
        !state.theoryIntroSeen &&
        state.currentSession == null &&
        state.currentChallengeSpec == null;

    if (shouldShowLevelIntro) {
      return LevelIntroView(
        syllabus: syllabus,
        onBack: () {
          context.goNamed(AppRouter.learningPathName);
        },
        onStartPractice: () {
          notifier.markTheoryIntroSeen();
          notifier.startCurrentChallenge(
            userId: userId,
            sessionId: _newSessionId(),
          );
        },
      );
    }

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
              sessionId: _newSessionId(),
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
              nextSessionId: _newSessionId(),
            ),
            onReset: notifier.resetLevelFlow,
            attemptsRemaining: state.currentSession?.attemptsRemaining,
          ),
        ],
      ),
    );
  }

  void _syncGameScene({
    required LevelState? previous,
    required LevelState next,
  }) {
    final spec = next.currentChallengeSpec;
    final session = next.currentSession;

    if (spec == null || session == null) {
      game.clearScene();
      return;
    }

    final content = spec.content;
    final runtimeState = session.runtimeState;

    final previousSpecId = previous?.currentChallengeSpec?.id;
    final nextSpecId = spec.id;
    final previousRuntimeState = previous?.currentSession?.runtimeState;

    switch ((content, runtimeState)) {
      case (
        final StructureChallengeContent structureContent,
        StructureRuntimeState(:final structure),
      ):
        final previousStructure = previousRuntimeState is StructureRuntimeState
            ? previousRuntimeState.structure
            : null;

        final shouldUpdateScene =
            previousSpecId != nextSpecId || previousStructure != structure;

        if (!shouldUpdateScene) return;

        game.updateScene(structureContent: structureContent, state: structure);

      case (
        IdentifyTargetChallengeContent(
          :final identifySpec,
          :final visualStructure,
        ),
        IdentifyTargetRuntimeState(
          :final visualState,
          :final selectedTargetIds,
        ),
      ):
        final previousVisualState =
            previousRuntimeState is IdentifyTargetRuntimeState
            ? previousRuntimeState.visualState
            : null;

        final previousSelectedTargetIds =
            previousRuntimeState is IdentifyTargetRuntimeState
            ? previousRuntimeState.selectedTargetIds
            : const <String>{};

        final shouldUpdateScene =
            previousSpecId != nextSpecId ||
            previousVisualState != visualState ||
            previousSelectedTargetIds != selectedTargetIds;

        if (!shouldUpdateScene) return;

        game.updateScene(
          structureContent: visualStructure,
          state: visualState,
          interactionStrategy: IdentifyInteractionStrategy(
            selectedTargetIds: selectedTargetIds,
            allowMultiple: identifySpec.allowMultiple,
            onSelectionChanged: (nextSelection) {
              ref
                  .read(levelStateProvider.notifier)
                  .submitIdentifyTarget(nextSelection);
            },
          ),
        );

      case (QuizChallengeContent(), QuizRuntimeState()):
        game.clearScene();

      default:
        game.clearScene();
    }
  }

  void _startChallengeAutomaticallyIfNeeded(LevelState state) {
    final syllabus = state.syllabus;
    final hasTheory = syllabus?.theory != null;

    final shouldAutoStartChallenge =
        syllabus != null &&
        !hasTheory &&
        state.currentChallengeId != null &&
        state.currentSession == null &&
        state.currentChallengeSpec == null;

    if (!shouldAutoStartChallenge) return;

    final userId = ref.read(currentUserIdProvider);

    ref
        .read(levelStateProvider.notifier)
        .startCurrentChallenge(userId: userId, sessionId: _newSessionId());
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

    if (content is CategorizeChallengeContent &&
        runtimeState is CategorizeRuntimeState) {
      return CategorizeChallengeView(
        categorizeSpec: content.categorizeSpec,
        selectedCategoryByItemId: runtimeState.selectedCategoryByItemId,
        onCategorySelected:
            ({required String itemId, required String categoryId}) {
              notifier.submitCategorization(
                itemId: itemId,
                categoryId: categoryId,
              );
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
    final spec = state.currentChallengeSpec;

    if (spec == null) return;

    final solved = notifier.checkSolution();

    final nextState = ref.read(levelStateProvider);

    final attemptsRemaining =
        nextState.currentSession?.attemptsRemaining ??
        state.currentSession?.attemptsRemaining;

    final theoryMessage = _resolveTheoryMessage(state: nextState, spec: spec);

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return ChallengeResultDialog.fromChallengeSpec(
          spec: spec,
          solved: solved,
          theoryMessage: theoryMessage,
          attemptsRemaining: attemptsRemaining,
          onContinue: () {
            Navigator.of(context).pop();

            final userId = ref.read(currentUserIdProvider);

            notifier.completeCurrentChallenge(
              userId: userId,
              nextSessionId: _newSessionId(),
            );
          },
          onTryAgain: () {
            Navigator.of(context).pop();
          },
          onShowAnswer: () {
            Navigator.of(context).pop();

            // TODO: mostrar solución cuando implementemos ese flujo.
          },
        );
      },
    );
  }

  String? _resolveTheoryMessage({
    required LevelState state,
    required ChallengeSpec spec,
  }) {
    final theoryRef = spec.theoryRef;

    if (theoryRef == null || theoryRef.isEmpty) {
      return null;
    }

    final theory = state.syllabus?.theory;
    if (theory == null) {
      return null;
    }

    if (theory.id != theoryRef) {
      return null;
    }

    return theory.content;
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

  String _newSessionId() {
    return 'session_${DateTime.now().millisecondsSinceEpoch}';
  }
}
