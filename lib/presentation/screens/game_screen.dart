import 'package:algoquest/domain/entities/challenge_runtime_state.dart';
import 'package:algoquest/domain/entities/challenge_spec.dart';
import 'package:algoquest/domain/entities/game_action.dart';
import 'package:algoquest/domain/entities/structure_state.dart';
import 'package:algoquest/presentation/application_state/app_providers.dart';
import 'package:algoquest/presentation/application_state/level_state.dart';
import 'package:algoquest/presentation/application_state/level_state_provider.dart';
import 'package:algoquest/presentation/game/algoquest_game.dart';
import 'package:algoquest/presentation/router/app_router.dart';
import 'package:algoquest/presentation/theme/app_assets.dart';
import 'package:algoquest/presentation/widgets/challenge/challenge_body_factory.dart';
import 'package:algoquest/presentation/widgets/challenge/components/challenge_result_dialog.dart';
import 'package:algoquest/presentation/widgets/challenge/components/challenge_screen_layout.dart';
import 'package:algoquest/presentation/widgets/level_intro/level_intro_view.dart';
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
          _goBack(context);
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

    final spec = state.currentChallengeSpec;
    final session = state.currentSession;

    if (spec == null || session == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF7F8FC),
        body: SafeArea(child: GameWidget(game: game)),
      );
    }

    final theoryMessage = _resolveTheoryMessage(state: state, spec: spec);

    return ChallengeScreenLayout(
      currentChallengeNumber: state.currentChallengeNumber,
      totalChallenges: state.totalChallenges,
      heartsRemaining: session.attemptsRemaining,
      maxHearts: spec.maxAttempts,
      movesRemaining: _movesRemaining(state),
      instruction: spec.instruction,
      questionImageAssetPath: AppAssets.wizard,
      tipTitle: theoryMessage == null ? null : 'Tip:',
      tipMessage: theoryMessage,
      tipImageAssetPath: AppAssets.happyRaccoon,
      onBack: () {
        _goBack(context);
      },
      onReset: session.hasAttemptsRemaining
          ? notifier.restartCurrentChallenge
          : null,
      onUndo: session.canUndo ? notifier.undoLastAction : null,
      onRedo: session.canRedo ? notifier.redoLastAction : null,
      onCheckAnswer: session.hasAttemptsRemaining
          ? () {
              _showFeedbackDialog(
                context: context,
                notifier: notifier,
                state: state,
              );
            }
          : null,
      challengeBody: ChallengeBodyFactory.build(
        spec: spec,
        runtimeState: session.runtimeState,
        game: game,
        notifier: notifier,
      ),
    );
  }

  int? _movesRemaining(LevelState state) {
    final spec = state.currentChallengeSpec;
    final runtimeState = state.currentSession?.runtimeState;

    if (spec == null || runtimeState is! StructureRuntimeState) {
      return null;
    }

    MaxMovesConstraint? maxMovesConstraint;

    for (final constraint in spec.constraints) {
      if (constraint is MaxMovesConstraint) {
        maxMovesConstraint = constraint;
        break;
      }
    }

    if (maxMovesConstraint == null) {
      return null;
    }

    return (maxMovesConstraint.maxMoves - runtimeState.movesUsed).clamp(
      0,
      maxMovesConstraint.maxMoves,
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

    switch ((spec.content, session.runtimeState)) {
      case (
        final StructureChallengeContent structureContent,
        StructureRuntimeState(:final structure),
      ):
        _syncStructureScene(
          previous: previous,
          spec: spec,
          structureContent: structureContent,
          structure: structure,
        );

      default:
        game.clearScene();
    }
  }

  void _syncStructureScene({
    required LevelState? previous,
    required ChallengeSpec spec,
    required StructureChallengeContent structureContent,
    required StructureState structure,
  }) {
    final previousSpecId = previous?.currentChallengeSpec?.id;
    final previousRuntimeState = previous?.currentSession?.runtimeState;

    final previousStructure = previousRuntimeState is StructureRuntimeState
        ? previousRuntimeState.structure
        : null;

    final shouldUpdateScene =
        previousSpecId != spec.id || previousStructure != structure;

    if (!shouldUpdateScene) return;

    game.updateScene(structureContent: structureContent, state: structure);
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

  void _showFeedbackDialog({
    required BuildContext context,
    required LevelStateNotifier notifier,
    required LevelState state,
  }) {
    final spec = state.currentChallengeSpec;
    final session = state.currentSession;

    if (spec == null || session == null) return;
    if (!session.hasAttemptsRemaining) return;

    final solved = notifier.checkSolution();
    final nextState = ref.read(levelStateProvider);
    final nextSession = nextState.currentSession ?? session;

    final attemptsRemaining = nextSession.attemptsRemaining;
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
          canTryAgain: nextSession.canTryAgain,
          canRevealAnswer: nextSession.canRevealAnswer,
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
            notifier.restartCurrentChallenge();
          },
          onShowAnswer: () {
            Navigator.of(context).pop();
            notifier.revealCurrentChallengeAnswer();
          },
        );
      },
    );
  }

  void _goBack(BuildContext context) {
    final router = GoRouter.of(context);

    if (router.canPop()) {
      router.pop();
      return;
    }

    router.goNamed(AppRouter.learningPathName);
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

  String _newSessionId() {
    return 'session_${DateTime.now().millisecondsSinceEpoch}';
  }
}
