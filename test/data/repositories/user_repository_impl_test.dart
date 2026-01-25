import 'package:flutter_test/flutter_test.dart';

import 'package:algoquest/domain/entities/user_progress.dart';
import 'package:algoquest/data/repositories/user_repository_impl.dart';

import 'package:algoquest/data/datasources/local/in_memory_user_repository.dart';

void main() {
  group('UserRepositoryImpl', () {
    test('returns null when user progress does not exist', () async {
      final dataSource = InMemoryUserRepository();
      final repo = UserRepositoryImpl(dataSource);

      final result = await repo.fetchUserProgress('missing_user');

      expect(result, isNull);
    });

    test('persists and loads user progress', () async {
      final dataSource = InMemoryUserRepository();
      final repo = UserRepositoryImpl(dataSource);

      final progress = UserProgress(
        userId: 'user_1',
        level: 3,
        experiencePoints: 1200,
        livesRemaining: 5,
        unlockedLevels: {'level_1', 'level_2', 'level_3'},
        currentLevelId: 'level_3',
      );

      await repo.updateUserProgress(progress);

      final loaded = await repo.fetchUserProgress('user_1');

      expect(loaded, isNotNull);
      expect(loaded!.userId, equals('user_1'));
      expect(loaded.level, equals(3));
      expect(loaded.experiencePoints, equals(1200));
      expect(loaded.livesRemaining, equals(5));
      expect(
        loaded.unlockedLevels,
        containsAll({'level_1', 'level_2', 'level_3'}),
      );
      expect(loaded.currentLevelId, equals('level_3'));
    });
  });
}
