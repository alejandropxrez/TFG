import 'package:algoquest/domain/entities/user_progress.dart';

abstract class UserRepository {
  /// Loads the persisted user progress for the given user ID.
  Future<UserProgress?> fetchUserProgress(String userId);

  /// Persists the given user progress model.
  Future<void> updateUserProgress(UserProgress userProgress);
}
