import '../entities/level_syllabus.dart';
import '../repositories/content_repository.dart';

class GetLevelSyllabusUseCase {
  final ContentRepository _contentRepository;

  GetLevelSyllabusUseCase(this._contentRepository);

  Future<LevelSyllabus> call(String levelId) {
    return _contentRepository.getLevelSyllabus(levelId);
  }
}
