import 'dart:convert';

import 'package:algoquest/application/app_providers.dart';
import 'package:algoquest/core/composition/use_cases.dart';
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

    if (solved) {
      state = state.copyWith(
        currentSession: session.copyWith(
          status: SessionStatus.completed,
          updatedAt: DateTime.now(),
        ),
        status: LevelFlowStatus.challengeSolved,
        clearError: true,
      );

      return true;
    }

    final updatedSession = _useCases.consumeAttempt(session);

    state = state.copyWith(
      currentSession: updatedSession,
      status: updatedSession.status == SessionStatus.failed
          ? LevelFlowStatus.challengeFailed
          : LevelFlowStatus.playing,
      errorMessage: updatedSession.status == SessionStatus.failed
          ? 'No attempts remaining.'
          : null,
      clearError: updatedSession.status != SessionStatus.failed,
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

    final solved = _useCases.checkSolution(session);

    if (!solved) {
      state = state.copyWith(status: LevelFlowStatus.playing, clearError: true);
      return;
    }

    final nextManager = manager.moveNext();

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

        final nextLevelId = await _findNextLevelId(syllabus.id);

        final newlyUnlockedLevels = <String>{
          if (nextLevelId != null) nextLevelId,
        };

        final updatedProgress = _useCases.manageProgress.applyRewards(
          current: baseProgress,
          xpGained: syllabus.rewards.xp,
          newlyUnlockedLevels: newlyUnlockedLevels,
          newCurrentLevelId: nextLevelId ?? syllabus.id,
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

  Future<String?> _findNextLevelId(String currentLevelId) async {
    final loadSyllabusJson = ref.read(syllabusJsonLoaderProvider);
    final jsonString = await loadSyllabusJson();

    final decoded = json.decode(jsonString) as Map<String, dynamic>;
    final phasesJson = decoded['phases'] as List<dynamic>;

    final levelIds = <String>[];

    for (final phaseJson in phasesJson) {
      final phaseMap = phaseJson as Map<String, dynamic>;
      final levelsJson = phaseMap['levels'] as List<dynamic>;

      for (final levelJson in levelsJson) {
        final levelMap = levelJson as Map<String, dynamic>;
        levelIds.add(levelMap['id'] as String);
      }
    }

    final currentIndex = levelIds.indexOf(currentLevelId);

    if (currentIndex == -1) {
      throw StateError(
        'Current level "$currentLevelId" was not found in syllabus.json.',
      );
    }

    final nextIndex = currentIndex + 1;

    if (nextIndex >= levelIds.length) {
      return null;
    }

    return levelIds[nextIndex];
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
}
