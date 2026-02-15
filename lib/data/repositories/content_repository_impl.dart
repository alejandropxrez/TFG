import '../../domain/entities/level_syllabus.dart';
import '../../domain/entities/challenge_spec.dart';
import '../../domain/repositories/content_repository.dart';

import '../datasources/local/content_local_data_source.dart';
import '../mappers/level_syllabus_mapper.dart';
import '../mappers/challenge_mapper.dart';

class ContentRepositoryImpl implements ContentRepository {
  final ContentLocalDataSource _localDataSource;

  ContentRepositoryImpl(this._localDataSource);

  @override
  Future<LevelSyllabus> getLevelSyllabus(String levelId) async {
    final model = await _localDataSource.getLevelSyllabus(levelId);
    return LevelSyllabusMapper.toDomain(model);
  }

  @override
  Future<ChallengeSpec> getChallenge(String challengeId) async {
    final model = await _localDataSource.getChallenge(challengeId);
    return ChallengeMapper.toDomain(model);
  }
}
