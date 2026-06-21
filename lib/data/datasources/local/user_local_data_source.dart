import 'package:algoquest/data/models/user_progress_model.dart';

/// Local data source contract for user progress persistence.
///
/// Implementations are responsible for reading and writing
/// [UserProgressModel] instances using a local storage mechanism, such as
/// Drift.
abstract class UserLocalDataSource {
  /// Loads the persisted progress for [userId].
  ///
  /// Returns `null` when no progress has been stored for the user yet.
  Future<UserProgressModel?> fetchUserProgress(String userId);

  /// Persists the complete user progress state.
  ///
  /// Existing data for the same user is expected to be replaced or updated
  /// according to the implementation's storage strategy.
  Future<void> updateUserProgress(UserProgressModel userProgress);
}
