import 'package:flutter_test/flutter_test.dart';

import 'package:algoquest/application/session_manager.dart';
import 'package:algoquest/domain/entities/level_syllabus.dart';

void main() {
  LevelSyllabus buildSyllabus({
    List<String> challenges = const [
      'challenge_1',
      'challenge_2',
      'challenge_3',
    ],
  }) {
    return LevelSyllabus(
      id: 'level_1',
      title: 'Heap Basics',
      topic: LevelTopic.heaps,
      challenges: challenges,
      rewards: const LevelRewards(xp: 100, stars: 3),
    );
  }

  group('SessionManager', () {
    test('starts at the first challenge', () {
      final manager = SessionManager(syllabus: buildSyllabus());

      expect(manager.currentChallengeIndex, 0);
      expect(manager.currentChallengeId, 'challenge_1');
      expect(manager.totalChallenges, 3);
      expect(manager.hasChallenges, isTrue);
      expect(manager.hasCurrentChallenge, isTrue);
      expect(manager.hasNextChallenge, isTrue);
      expect(manager.isOnLastChallenge, isFalse);
      expect(manager.isLevelCompleted, isFalse);
    });

    test('moves to the next challenge', () {
      final manager = SessionManager(syllabus: buildSyllabus());

      final next = manager.moveNext();

      expect(next.currentChallengeIndex, 1);
      expect(next.currentChallengeId, 'challenge_2');
      expect(next.hasNextChallenge, isTrue);
      expect(next.isOnLastChallenge, isFalse);
      expect(next.isLevelCompleted, isFalse);
    });

    test('does not mutate the previous manager when moving next', () {
      final manager = SessionManager(syllabus: buildSyllabus());

      final next = manager.moveNext();

      expect(manager.currentChallengeIndex, 0);
      expect(manager.currentChallengeId, 'challenge_1');

      expect(next.currentChallengeIndex, 1);
      expect(next.currentChallengeId, 'challenge_2');
    });

    test('detects the last challenge without completing the level', () {
      final manager = SessionManager(
        syllabus: buildSyllabus(),
        currentChallengeIndex: 2,
      );

      expect(manager.currentChallengeId, 'challenge_3');
      expect(manager.hasNextChallenge, isFalse);
      expect(manager.isOnLastChallenge, isTrue);
      expect(manager.isLevelCompleted, isFalse);
    });

    test('moveNext from last challenge completes the level', () {
      final manager = SessionManager(
        syllabus: buildSyllabus(),
        currentChallengeIndex: 2,
      );

      final completed = manager.moveNext();

      expect(completed.currentChallengeIndex, 3);
      expect(completed.currentChallengeId, isNull);
      expect(completed.hasCurrentChallenge, isFalse);
      expect(completed.hasNextChallenge, isFalse);
      expect(completed.isLevelCompleted, isTrue);
    });

    test('does not move beyond completed state', () {
      final manager = SessionManager(
        syllabus: buildSyllabus(),
        currentChallengeIndex: 3,
      );

      final next = manager.moveNext();

      expect(identical(next, manager), isTrue);
      expect(next.currentChallengeIndex, 3);
      expect(next.currentChallengeId, isNull);
      expect(next.isLevelCompleted, isTrue);
    });

    test('handles a single-challenge level', () {
      final manager = SessionManager(
        syllabus: buildSyllabus(challenges: const ['challenge_1']),
      );

      expect(manager.currentChallengeIndex, 0);
      expect(manager.currentChallengeId, 'challenge_1');
      expect(manager.totalChallenges, 1);
      expect(manager.hasNextChallenge, isFalse);
      expect(manager.isOnLastChallenge, isTrue);
      expect(manager.isLevelCompleted, isFalse);

      final completed = manager.moveNext();

      expect(completed.currentChallengeIndex, 1);
      expect(completed.currentChallengeId, isNull);
      expect(completed.isLevelCompleted, isTrue);
    });

    test('handles an empty level safely', () {
      final manager = SessionManager(
        syllabus: buildSyllabus(challenges: const []),
      );

      expect(manager.hasChallenges, isFalse);
      expect(manager.totalChallenges, 0);
      expect(manager.hasCurrentChallenge, isFalse);
      expect(manager.currentChallengeId, isNull);
      expect(manager.hasNextChallenge, isFalse);
      expect(manager.isOnLastChallenge, isFalse);
      expect(manager.isLevelCompleted, isTrue);
    });

    test('reset returns manager to the first challenge', () {
      final manager = SessionManager(
        syllabus: buildSyllabus(),
        currentChallengeIndex: 3,
      );

      final reset = manager.reset();

      expect(reset.currentChallengeIndex, 0);
      expect(reset.currentChallengeId, 'challenge_1');
      expect(reset.hasNextChallenge, isTrue);
      expect(reset.isLevelCompleted, isFalse);
    });
  });
}
