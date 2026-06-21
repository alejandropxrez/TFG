import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';

import 'package:algoquest/data/datasources/local/drift/app_database.dart';
import 'package:algoquest/data/datasources/local/drift_user_local_data_source.dart';
import 'package:algoquest/data/repositories/user_repository_impl.dart';

import 'package:algoquest/domain/entities/user_progress.dart';

void main() {
  late AppDatabase database;
  late DriftUserLocalDataSource dataSource;
  late UserRepositoryImpl repository;

  setUp(() {
    database = AppDatabase.test(NativeDatabase.memory());
    dataSource = DriftUserLocalDataSource(database);
    repository = UserRepositoryImpl(dataSource);
  });

  tearDown(() async {
    await database.close();
  });

  test('returns null when user does not exist', () async {
    final result = await repository.fetchUserProgress('missing');

    expect(result, isNull);
  });

  test('persists and retrieves user progress', () async {
    final progress = UserProgress(
      userId: 'user_1',
      level: 2,
      experiencePoints: 500,
      livesRemaining: 3,
      unlockedLevels: {'level_1', 'level_2'},
      completedLevels: {'level_1'},
      currentLevelId: 'level_2',
    );

    await repository.updateUserProgress(progress);

    final loaded = await repository.fetchUserProgress('user_1');

    expect(loaded, isNotNull);
    expect(loaded!.userId, 'user_1');
    expect(loaded.level, 2);
    expect(loaded.experiencePoints, 500);
    expect(loaded.livesRemaining, 3);
    expect(loaded.unlockedLevels, containsAll({'level_1', 'level_2'}));
    expect(loaded.completedLevels, {'level_1'});
    expect(loaded.currentLevelId, 'level_2');
  });

  test('updates existing user progress', () async {
    final initial = UserProgress(
      userId: 'user_1',
      level: 1,
      experiencePoints: 100,
      livesRemaining: 5,
      unlockedLevels: {'level_1'},
      currentLevelId: 'level_1',
    );

    await repository.updateUserProgress(initial);

    final updated = UserProgress(
      userId: 'user_1',
      level: 3,
      experiencePoints: 900,
      livesRemaining: 4,
      unlockedLevels: {'level_1', 'level_2', 'level_3'},
      currentLevelId: 'level_3',
    );

    await repository.updateUserProgress(updated);

    final loaded = await repository.fetchUserProgress('user_1');

    expect(loaded!.level, 3);
    expect(loaded.experiencePoints, 900);
    expect(loaded.livesRemaining, 4);
    expect(
      loaded.unlockedLevels,
      containsAll({'level_1', 'level_2', 'level_3'}),
    );
    expect(loaded.currentLevelId, 'level_3');
  });
}
