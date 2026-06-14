import 'package:algoquest/domain/entities/level_syllabus.dart';

import 'package:algoquest/domain/repositories/content_repository.dart';

class GetLevelSyllabusUseCase {
  final ContentRepository _contentRepository;

  GetLevelSyllabusUseCase(this._contentRepository);

  Future<LevelSyllabus> call(String levelId) {
    return _contentRepository.getLevelSyllabus(levelId);
  }
}
