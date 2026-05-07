import 'package:algoquest/domain/entities/level_syllabus.dart';

class SessionManager {
  final LevelSyllabus syllabus;
  final int currentChallengeIndex;

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

  int get totalChallenges => syllabus.challenges.length;

  bool get hasChallenges => totalChallenges > 0;

  bool get hasCurrentChallenge => currentChallengeIndex < totalChallenges;

  String? get currentChallengeId {
    if (!hasCurrentChallenge) return null;
    return syllabus.challenges[currentChallengeIndex];
  }

  bool get hasNextChallenge => currentChallengeIndex < totalChallenges - 1;

  bool get isOnLastChallenge =>
      hasCurrentChallenge && currentChallengeIndex == totalChallenges - 1;

  bool get isLevelCompleted => currentChallengeIndex >= totalChallenges;

  SessionManager moveNext() {
    if (isLevelCompleted) return this;

    return SessionManager(
      syllabus: syllabus,
      currentChallengeIndex: currentChallengeIndex + 1,
    );
  }

  SessionManager reset() {
    return SessionManager(syllabus: syllabus, currentChallengeIndex: 0);
  }
}
