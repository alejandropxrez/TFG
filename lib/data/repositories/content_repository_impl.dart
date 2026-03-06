import 'package:algoquest/domain/entities/challenge_spec.dart';
import 'package:algoquest/domain/entities/level_syllabus.dart';
import 'package:algoquest/domain/repositories/content_repository.dart';

import 'package:algoquest/data/datasources/local/content_local_data_source.dart';
import 'package:algoquest/data/mappers/challenge_mapper.dart';
import 'package:algoquest/data/mappers/level_syllabus_mapper.dart';

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
