import 'package:algoquest/domain/entities/level_syllabus.dart';

/// Tracks progression through the challenges of a level.
///
/// [currentChallengeIndex] is zero-based. A value equal to
/// [totalChallenges] represents a completed level with no active challenge.
///
/// Instances are immutable: advancing or resetting returns a new
/// [SessionManager].
class SessionManager {
  /// Definition of the level whose challenge sequence is being managed.
  final LevelSyllabus syllabus;

  /// Zero-based index of the current challenge.
  ///
  /// This value may be equal to [totalChallenges] when the level has already
  /// been completed.
  final int currentChallengeIndex;

  /// NOTE: These assertions protect internal invariants during development.
  ///
  /// [SessionManager] is expected to receive an already validated
  /// [LevelSyllabus], and [currentChallengeIndex] is normally controlled only by
  /// [completeCurrentChallenge] and [reset]. Therefore, these checks intentionally
  /// use assertions and are not required in release builds.
  ///
  /// If the challenge index is ever restored from persistence or received from
  /// another external source, these assertions should be replaced with runtime
  /// validation such as [ArgumentError] or [RangeError].
  SessionManager({required this.syllabus, this.currentChallengeIndex = 0})
    : assert(
        syllabus.challenges.isNotEmpty,
        'A level must contain at least one challenge',
      ),
      assert(
        currentChallengeIndex >= 0 &&
            currentChallengeIndex <= syllabus.challenges.length,
        'currentChallengeIndex must be between 0 and totalChallenges',
      );

  /// Total number of challenges in the level.
  int get totalChallenges => syllabus.challenges.length;

  /// Whether the level defines at least one challenge.
  ///
  /// This is always `true` for instances created with assertions enabled,
  /// because the constructor rejects empty challenge lists.
  bool get hasChallenges => totalChallenges > 0;

  /// Whether [currentChallengeIndex] points to an active challenge.
  bool get hasCurrentChallenge => currentChallengeIndex < totalChallenges;

  /// Identifier of the current challenge.
  ///
  /// Returns `null` after all challenges have been completed.
  String? get currentChallengeId {
    if (!hasCurrentChallenge) return null;
    return syllabus.challenges[currentChallengeIndex];
  }

  /// One-based challenge number used by the presentation layer.
  ///
  /// When the level is complete, the final challenge number is retained
  /// instead of returning a value beyond [totalChallenges].
  int get currentChallengeNumber {
    if (isLevelCompleted) return totalChallenges;
    return currentChallengeIndex + 1;
  }

  /// Whether another challenge remains after the current one.
  bool get hasNextChallenge => currentChallengeIndex < totalChallenges - 1;

  /// Whether the current challenge is the final challenge in the level.
  bool get isOnLastChallenge {
    return hasCurrentChallenge && currentChallengeIndex == totalChallenges - 1;
  }

  /// Whether every challenge in the level has been completed.
  bool get isLevelCompleted => currentChallengeIndex >= totalChallenges;

  /// Advances the progression to the next challenge.
  ///
  /// Completing the final challenge produces a manager whose index equals
  /// [totalChallenges], marking the level as completed.
  ///
  /// If the level is already completed, the current instance is returned.
  SessionManager completeCurrentChallenge() {
    if (isLevelCompleted) return this;

    return SessionManager(
      syllabus: syllabus,
      currentChallengeIndex: currentChallengeIndex + 1,
    );
  }

  /// Returns a new manager positioned at the first challenge.
  SessionManager reset() {
    return SessionManager(syllabus: syllabus, currentChallengeIndex: 0);
  }
}
