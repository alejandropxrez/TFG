import '../domain/entities/challenge_session.dart';
import '../domain/entities/challenge_spec.dart';
import '../domain/entities/level_syllabus.dart';
import 'session_manager.dart';

enum LevelFlowStatus {
  idle,
  loading,
  playing,
  challengeSolved,
  completed,
  failed,
}

class LevelState {
  final LevelSyllabus? syllabus;
  final SessionManager? sessionManager;

  final ChallengeSpec? currentChallengeSpec;
  final ChallengeSession? currentSession;

  final LevelFlowStatus status;
  final String? errorMessage;

  const LevelState({
    required this.syllabus,
    required this.sessionManager,
    required this.currentChallengeSpec,
    required this.currentSession,
    required this.status,
    required this.errorMessage,
  });

  const LevelState.initial()
    : syllabus = null,
      sessionManager = null,
      currentChallengeSpec = null,
      currentSession = null,
      status = LevelFlowStatus.idle,
      errorMessage = null;

  bool get hasActiveSession => currentSession != null;

  bool get isLoading => status == LevelFlowStatus.loading;

  int get currentChallengeIndex => sessionManager?.currentChallengeIndex ?? 0;

  int get totalChallenges => sessionManager?.totalChallenges ?? 0;

  String? get currentChallengeId => sessionManager?.currentChallengeId;

  bool get isOnLastChallenge => sessionManager?.isOnLastChallenge ?? false;

  bool get isLevelCompleted => sessionManager?.isLevelCompleted ?? false;

  LevelState copyWith({
    LevelSyllabus? syllabus,
    SessionManager? sessionManager,
    ChallengeSpec? currentChallengeSpec,
    ChallengeSession? currentSession,
    LevelFlowStatus? status,
    String? errorMessage,
    bool clearError = false,
    bool clearChallenge = false,
  }) {
    return LevelState(
      syllabus: syllabus ?? this.syllabus,
      sessionManager: sessionManager ?? this.sessionManager,
      currentChallengeSpec: clearChallenge
          ? null
          : currentChallengeSpec ?? this.currentChallengeSpec,
      currentSession: clearChallenge
          ? null
          : currentSession ?? this.currentSession,
      status: status ?? this.status,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
