import 'package:algoquest/domain/entities/user_progress.dart';
import 'package:algoquest/domain/repositories/user_repository.dart';
import 'package:algoquest/data/datasources/local/user_local_data_source.dart';
import 'package:algoquest/data/mappers/user_progress_mapper.dart';

class UserRepositoryImpl implements UserRepository {
  final UserLocalDataSource localDataSource;

  UserRepositoryImpl(this.localDataSource);

  @override
  Future<UserProgress?> fetchUserProgress(String userId) async {
    final model = await localDataSource.fetchUserProgress(userId);
    if (model == null) return null;

    return UserProgressMapper.toDomain(model);
  }

  @override
  Future<void> updateUserProgress(UserProgress userProgress) async {
    final model = UserProgressMapper.toModel(userProgress);
    await localDataSource.updateUserProgress(model);
  }
}
