import 'package:algoquest/data/datasources/local/user_local_data_source.dart';
import 'package:algoquest/data/models/user_progress_model.dart';

class InMemoryUserRepository implements UserLocalDataSource {
  final Map<String, UserProgressModel> _storage = {};

  @override
  Future<UserProgressModel?> fetchUserProgress(String userId) async {
    return _storage[userId];
  }

  @override
  Future<void> updateUserProgress(UserProgressModel userProgress) async {
    _storage[userProgress.userId] = userProgress;
  }
}
