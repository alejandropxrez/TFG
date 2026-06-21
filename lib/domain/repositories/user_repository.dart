import 'package:algoquest/domain/entities/user_progress.dart';

/// Repository contract for accessing and persisting user progress.
///
/// Implementations hide the underlying storage mechanism from the domain
/// layer, such as a local database or another persistence source.
abstract class UserRepository {
  /// Loads the persisted progress associated with [userId].
  ///
  /// Returns `null` when no progress has been stored for the user yet.
  Future<UserProgress?> fetchUserProgress(String userId);

  /// Persists the complete [userProgress] domain state.
  ///
  /// Existing progress for the same user is expected to be updated or replaced
  /// according to the implementation's persistence strategy.
  Future<void> updateUserProgress(UserProgress userProgress);
}
