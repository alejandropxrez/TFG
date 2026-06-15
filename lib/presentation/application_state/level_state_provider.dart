import 'package:algoquest/presentation/application_state/app_providers.dart';
import 'package:algoquest/data/core/composition/use_cases.dart';
import 'package:algoquest/domain/entities/identify_target_action.dart';
import 'package:algoquest/domain/entities/quiz_action.dart';
import 'package:algoquest/domain/entities/user_progress.dart';
import 'package:algoquest/domain/enums/session_status.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:algoquest/domain/entities/game_action.dart';

import 'level_state.dart';
import 'session_manager.dart';

final levelStateProvider = NotifierProvider<LevelStateNotifier, LevelState>(
  LevelStateNotifier.new,
);

class LevelStateNotifier extends Notifier<LevelState> {
  late final UseCases _useCases;

  @override
  LevelState build() {
    _useCases = ref.watch(useCasesProvider);
    return const LevelState.initial();
  }

  Future<void> loadLevel(String levelId) async {
    state = state.copyWith(
      status: LevelFlowStatus.loading,
      clearError: true,
      clearChallenge: true,
    );

    try {
      final syllabus = await _useCases.getLevelSyllabus(levelId);

      final sessionManager = SessionManager(syllabus: syllabus);

      state = state.copyWith(
        syllabus: syllabus,
        sessionManager: sessionManager,
        status: LevelFlowStatus.idle,
        theoryIntroSeen: false,
        clearError: true,
        clearChallenge: true,
      );
    } catch (error) {
      state = state.copyWith(
        status: LevelFlowStatus.failed,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> startCurrentChallenge({
    required String userId,
    required String sessionId,
  }) async {
    final manager = state.sessionManager;
    final challengeId = manager?.currentChallengeId;

    if (manager == null || challengeId == null) {
      state = state.copyWith(
        status: LevelFlowStatus.failed,
        errorMessage: 'No current challenge available.',
      );
      return;
    }

    await _startChallenge(
      userId: userId,
      challengeId: challengeId,
      sessionId: sessionId,
    );
  }

  Future<void> startChallenge({
    required String userId,
    required String challengeId,
    required String sessionId,
  }) async {
    await _startChallenge(
      userId: userId,
      challengeId: challengeId,
      sessionId: sessionId,
    );
  }

  Future<void> _startChallenge({
    required String userId,
    required String challengeId,
    required String sessionId,
  }) async {
    state = state.copyWith(
      status: LevelFlowStatus.loading,
      clearError: true,
      clearChallenge: true,
    );

    try {
      final spec = await _useCases.loadChallengeSpec(challengeId);

      final session = await _useCases.startChallengeSession(
        userId: userId,
        challengeId: challengeId,
        sessionId: sessionId,
      );

      state = state.copyWith(
        currentChallengeSpec: spec,
        currentSession: session,
        status: LevelFlowStatus.playing,
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(
        status: LevelFlowStatus.failed,
        errorMessage: error.toString(),
      );
    }
  }

  void executeAction(GameAction action) {
    final session = state.currentSession;
    if (session == null) return;

    final updatedSession = _useCases.executeMove(
      session: session,
      action: action,
    );

    state = state.copyWith(
      currentSession: updatedSession,
      status: LevelFlowStatus.playing,
      clearError: true,
    );
  }

  bool checkSolution() {
    final session = state.currentSession;
    if (session == null) return false;

    final checkedSession = _useCases.checkChallenge(session);
    final solved = checkedSession.status == SessionStatus.completed;

    if (solved) {
      state = state.copyWith(
        currentSession: checkedSession,
        status: LevelFlowStatus.challengeSolved,
        clearError: true,
      );

      return true;
    }

    final updatedSession = _useCases.consumeAttempt(checkedSession);
    final failed = updatedSession.status == SessionStatus.failed;

    state = state.copyWith(
      currentSession: updatedSession,
      status: failed
          ? LevelFlowStatus.challengeFailed
          : LevelFlowStatus.playing,
      errorMessage: failed ? 'No attempts remaining.' : null,
      clearError: !failed,
    );

    return false;
  }

  Future<void> completeCurrentChallenge({
    required String userId,
    required String nextSessionId,
  }) async {
    final manager = state.sessionManager;
    final session = state.currentSession;
    final syllabus = state.syllabus;

    if (manager == null || session == null || syllabus == null) return;

    final alreadySolved =
        session.status == SessionStatus.completed ||
        state.status == LevelFlowStatus.challengeSolved;

    if (!alreadySolved) {
      final checkedSession = _useCases.checkChallenge(session);
      final solved = checkedSession.status == SessionStatus.completed;

      if (!solved) {
        state = state.copyWith(
          currentSession: checkedSession,
          status: LevelFlowStatus.playing,
          clearError: true,
        );
        return;
      }

      state = state.copyWith(
        currentSession: checkedSession,
        status: LevelFlowStatus.challengeSolved,
        clearError: true,
      );
    }

    final nextManager = manager.completeCurrentChallenge();

    if (nextManager.isLevelCompleted) {
      try {
        final currentProgress = await _useCases.loadUserProgress(userId);

        final baseProgress =
            currentProgress ??
            UserProgress(
              userId: userId,
              level: 1,
              experiencePoints: 0,
              livesRemaining: 5,
              unlockedLevels: {syllabus.id},
              currentLevelId: syllabus.id,
            );

        final nextLevelId = await _useCases.getNextLevelId(syllabus.id);

        final updatedProgress = _useCases.manageProgress.completeLevel(
          current: baseProgress,
          completedLevelId: syllabus.id,
          xpReward: syllabus.rewards.xp,
          nextLevelId: nextLevelId,
          livesGained: syllabus.rewards.lives,
        );

        await _useCases.saveProgress(updatedProgress);

        state = state.copyWith(
          sessionManager: nextManager,
          status: LevelFlowStatus.completed,
          clearChallenge: true,
          clearError: true,
        );
      } catch (error) {
        state = state.copyWith(
          status: LevelFlowStatus.failed,
          errorMessage: error.toString(),
        );
      }

      return;
    }

    state = state.copyWith(
      sessionManager: nextManager,
      clearChallenge: true,
      clearError: true,
    );

    final nextChallengeId = nextManager.currentChallengeId;

    if (nextChallengeId == null) {
      state = state.copyWith(
        status: LevelFlowStatus.completed,
        clearChallenge: true,
      );
      return;
    }

    await _startChallenge(
      userId: userId,
      challengeId: nextChallengeId,
      sessionId: nextSessionId,
    );
  }

  void resetLevelFlow() {
    final manager = state.sessionManager;

    if (manager == null) {
      state = const LevelState.initial();
      return;
    }

    state = state.copyWith(
      sessionManager: manager.reset(),
      status: LevelFlowStatus.idle,
      clearChallenge: true,
      clearError: true,
    );
  }

  void undoLastAction() {
    final session = state.currentSession;
    if (session == null) return;

    final updatedSession = _useCases.undoMove(session);

    state = state.copyWith(
      currentSession: updatedSession,
      status: LevelFlowStatus.playing,
      clearError: true,
    );
  }

  void redoLastAction() {
    final session = state.currentSession;
    if (session == null) return;

    final updatedSession = _useCases.redoMove(session);

    state = state.copyWith(
      currentSession: updatedSession,
      status: LevelFlowStatus.playing,
      clearError: true,
    );
  }

  void submitQuizAnswer(Set<String> selectedOptionIds) {
    final session = state.currentSession;
    if (session == null) return;

    final updatedSession = _useCases.submitQuizAnswer(
      session: session,
      action: SubmitQuizAnswerAction(selectedOptionIds: selectedOptionIds),
    );

    state = state.copyWith(
      currentSession: updatedSession,
      status: LevelFlowStatus.playing,
      clearError: true,
    );
  }

  void submitIdentifyTarget(Set<String> selectedTargetIds) {
    final session = state.currentSession;
    if (session == null) return;

    final updatedSession = _useCases.submitIdentifyTarget(
      session: session,
      action: SubmitIdentifyTargetAction(selectedTargetIds: selectedTargetIds),
    );

    state = state.copyWith(
      currentSession: updatedSession,
      status: LevelFlowStatus.playing,
      clearError: true,
    );
  }

  void submitCategorization({
    required String itemId,
    required String categoryId,
  }) {
    final session = state.currentSession;
    if (session == null) return;

    final updatedSession = _useCases.submitCategorization(
      session: session,
      itemId: itemId,
      categoryId: categoryId,
    );

    state = state.copyWith(
      currentSession: updatedSession,
      status: LevelFlowStatus.playing,
      clearError: true,
    );
  }

  void markTheoryIntroSeen() {
    state = state.copyWith(theoryIntroSeen: true, clearError: true);
  }
}
