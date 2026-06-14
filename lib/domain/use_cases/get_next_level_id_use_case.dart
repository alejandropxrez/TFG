import 'package:algoquest/domain/repositories/content_repository.dart';

class GetNextLevelIdUseCase {
  final ContentRepository _contentRepository;

  const GetNextLevelIdUseCase(this._contentRepository);

  Future<String?> call(String currentLevelId) {
    return _contentRepository.getNextLevelId(currentLevelId);
  }
}
