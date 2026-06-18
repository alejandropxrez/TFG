import 'package:algoquest/domain/entities/challenge_session.dart';
import 'package:algoquest/domain/entities/challenge_spec.dart';
import 'package:algoquest/domain/entities/level_syllabus.dart';
import 'package:algoquest/domain/entities/session_manager.dart';

enum LevelFlowStatus {
  idle,
  loading,
  playing,
  challengeSolved,
  challengeFailed,
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

  final bool theoryIntroSeen;

  const LevelState({
    required this.syllabus,
    required this.sessionManager,
    required this.currentChallengeSpec,
    required this.currentSession,
    required this.theoryIntroSeen,
    required this.status,
    required this.errorMessage,
  });

  const LevelState.initial()
    : syllabus = null,
      sessionManager = null,
      currentChallengeSpec = null,
      currentSession = null,
      theoryIntroSeen = false,
      status = LevelFlowStatus.idle,
      errorMessage = null;

  bool get hasActiveSession => currentSession != null;

  bool get isLoading => status == LevelFlowStatus.loading;

  int get currentChallengeIndex => sessionManager?.currentChallengeIndex ?? 0;

  int get currentChallengeNumber => sessionManager?.currentChallengeNumber ?? 0;

  int get totalChallenges => sessionManager?.totalChallenges ?? 0;

  String? get currentChallengeId => sessionManager?.currentChallengeId;

  bool get isOnLastChallenge => sessionManager?.isOnLastChallenge ?? false;

  bool get isLevelCompleted => sessionManager?.isLevelCompleted ?? false;

  LevelState copyWith({
    LevelSyllabus? syllabus,
    SessionManager? sessionManager,
    ChallengeSpec? currentChallengeSpec,
    ChallengeSession? currentSession,
    bool? theoryIntroSeen,
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
      theoryIntroSeen: theoryIntroSeen ?? this.theoryIntroSeen,
      status: status ?? this.status,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
