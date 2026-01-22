import "../entities/user_progress.dart";

abstract class IUserRepository {
  /// Fetches the user progress for a given user ID.
  Future<UserProgress> fetchUserProgress(String userId);

  /// Updates the user progress in the data source.
  Future<void> updateUserProgress(UserProgress userProgress);
}
