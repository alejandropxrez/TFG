import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/composition/use_cases.dart';
import '../domain/entities/game_action.dart';
import 'level_state.dart';

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
    state = state.copyWith(status: LevelFlowStatus.loading, clearError: true);

    try {
      final syllabus = await _useCases.getLevelSyllabus(levelId);

      state = state.copyWith(
        syllabus: syllabus,
        currentChallengeIndex: 0,
        totalChallenges: syllabus.challenges.length,
        status: LevelFlowStatus.idle,
      );
    } catch (error) {
      state = state.copyWith(
        status: LevelFlowStatus.failed,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> startChallenge({
    required String userId,
    required String challengeId,
    required String sessionId,
    int challengeIndex = 0,
  }) async {
    state = state.copyWith(status: LevelFlowStatus.loading, clearError: true);

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
        currentChallengeIndex: challengeIndex,
        status: LevelFlowStatus.playing,
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
      status: solved ? LevelFlowStatus.solved : LevelFlowStatus.playing,
      clearError: true,
    );

    return solved;
  }
}
