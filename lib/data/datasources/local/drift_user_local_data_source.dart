import 'package:algoquest/data/datasources/local/drift/app_database.dart';
import 'package:algoquest/data/datasources/local/user_local_data_source.dart';
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
    final existing =
        await (_database.select(_database.userProgressTable)
              ..where((tbl) => tbl.userId.equals(userProgress.userId)))
            .getSingleOrNull();

    final companion = UserProgressDriftMapper.toCompanion(userProgress);

    if (existing == null) {
      await _database.into(_database.userProgressTable).insert(companion);
    } else {
      await (_database.update(_database.userProgressTable)
            ..where((tbl) => tbl.userId.equals(userProgress.userId)))
          .write(companion);
    }
  }
}
