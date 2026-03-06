import 'package:hive_ce/hive.dart';

import 'package:algoquest/data/models/user_progress_model.dart';

import 'user_local_data_source.dart';

class HiveUserLocalDataSource implements UserLocalDataSource {
  final Box<UserProgressModel> box;

  HiveUserLocalDataSource(this.box);

  @override
  Future<UserProgressModel?> fetchUserProgress(String userId) async {
    return box.get(userId);
  }

  @override
  Future<void> updateUserProgress(UserProgressModel userProgress) async {
    await box.put(userProgress.userId, userProgress);
  }
}
