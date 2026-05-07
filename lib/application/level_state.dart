import '../domain/entities/challenge_session.dart';
import '../domain/entities/challenge_spec.dart';
import '../domain/entities/level_syllabus.dart';

enum LevelFlowStatus { idle, loading, playing, solved, failed }

class LevelState {
  final LevelSyllabus? syllabus;
  final ChallengeSpec? currentChallengeSpec;
  final ChallengeSession? currentSession;

  final int currentChallengeIndex;
  final int totalChallenges;

  final LevelFlowStatus status;
  final String? errorMessage;

  const LevelState({
    required this.syllabus,
    required this.currentChallengeSpec,
    required this.currentSession,
    required this.currentChallengeIndex,
    required this.totalChallenges,
    required this.status,
    required this.errorMessage,
  });

  const LevelState.initial()
    : syllabus = null,
      currentChallengeSpec = null,
      currentSession = null,
      currentChallengeIndex = 0,
      totalChallenges = 0,
      status = LevelFlowStatus.idle,
      errorMessage = null;

  bool get hasActiveSession => currentSession != null;

  bool get isLoading => status == LevelFlowStatus.loading;

  LevelState copyWith({
    LevelSyllabus? syllabus,
    ChallengeSpec? currentChallengeSpec,
    ChallengeSession? currentSession,
    int? currentChallengeIndex,
    int? totalChallenges,
    LevelFlowStatus? status,
    String? errorMessage,
    bool clearError = false,
  }) {
    return LevelState(
      syllabus: syllabus ?? this.syllabus,
      currentChallengeSpec: currentChallengeSpec ?? this.currentChallengeSpec,
      currentSession: currentSession ?? this.currentSession,
      currentChallengeIndex:
          currentChallengeIndex ?? this.currentChallengeIndex,
      totalChallenges: totalChallenges ?? this.totalChallenges,
      status: status ?? this.status,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
