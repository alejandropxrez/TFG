import 'package:algoquest/data/datasources/local/user_local_data_source.dart';
import 'package:algoquest/data/datasources/local/drift/app_database.dart';
import 'package:algoquest/data/mappers/user_progress_drift_mapper.dart';
import 'package:algoquest/data/models/user_progress_model.dart';

class DriftUserLocalDataSource implements UserLocalDataSource {
  final AppDatabase _database;

  DriftUserLocalDataSource(this._database);

  @override
  Future<UserProgressModel?> fetchUserProgress(String userId) async {
    final row = await (_database.select(
      _database.userProgressTable,
    )..where((tbl) => tbl.userId.equals(userId))).getSingleOrNull();

    if (row == null) return null;

    return UserProgressDriftMapper.toModel(row);
  }

  @override
  Future<void> updateUserProgress(UserProgressModel userProgress) async {
    final companion = UserProgressDriftMapper.toCompanion(userProgress);

    await _database
        .into(_database.userProgressTable)
        .insertOnConflictUpdate(companion);
  }
}
