import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/composition/use_cases.dart';
import '../domain/entities/game_action.dart';
import 'level_state.dart';
import 'session_manager.dart';

final useCasesProvider = Provider<UseCases>((ref) {
  throw UnimplementedError(
    'UseCases must be provided from AppComposition using ProviderScope overrides.',
  );
});

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

    final solved = _useCases.checkSolution(session);

    state = state.copyWith(
      status: solved
          ? LevelFlowStatus.challengeSolved
          : LevelFlowStatus.playing,
      clearError: true,
    );

    return solved;
  }

  Future<void> completeCurrentChallenge({
    required String userId,
    required String nextSessionId,
  }) async {
    final manager = state.sessionManager;
    final session = state.currentSession;

    if (manager == null || session == null) return;

    final solved = _useCases.checkSolution(session);

    if (!solved) {
      state = state.copyWith(status: LevelFlowStatus.playing, clearError: true);
      return;
    }

    final nextManager = manager.moveNext();

    if (nextManager.isLevelCompleted) {
      state = state.copyWith(
        sessionManager: nextManager,
        status: LevelFlowStatus.completed,
        clearChallenge: true,
        clearError: true,
      );
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
}
