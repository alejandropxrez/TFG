import 'package:algoquest/data/models/user_progress_model.dart';

abstract class UserLocalDataSource {
  Future<UserProgressModel?> fetchUserProgress(String userId);
  Future<void> updateUserProgress(UserProgressModel userProgress);
}
