import 'package:flutter_test/flutter_test.dart';

import 'package:algoquest/domain/entities/user_progress.dart';
import 'package:algoquest/domain/repositories/user_repository.dart';
import 'package:algoquest/domain/usecases/save_progress_use_case.dart';

class FakeUserRepository implements UserRepository {
  UserProgress? lastSaved;

  @override
  Future<UserProgress?> fetchUserProgress(String userId) async {
    throw UnimplementedError();
  }

  @override
  Future<void> updateUserProgress(UserProgress userProgress) async {
    lastSaved = userProgress;
  }
}

void main() {
  test('SaveProgressUseCase calls repository updateUserProgress', () async {
    final repo = FakeUserRepository();
    final useCase = SaveProgressUseCase(repo);

    final progress = UserProgress(
      userId: 'u',
      level: 1,
      experiencePoints: 10,
      livesRemaining: 3,
      unlockedLevels: {'level_1'},
      currentLevelId: 'level_1',
    );

    await useCase(progress);

    expect(repo.lastSaved, isNotNull);
    expect(repo.lastSaved!.userId, 'u');
    expect(repo.lastSaved!.level, 1);
  });
}
