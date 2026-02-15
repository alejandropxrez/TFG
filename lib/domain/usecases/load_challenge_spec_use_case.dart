import '../entities/challenge_spec.dart';
import '../repositories/content_repository.dart';

class LoadChallengeSpecUseCase {
  final ContentRepository _contentRepository;

  LoadChallengeSpecUseCase(this._contentRepository);

  Future<ChallengeSpec> call(String challengeId) {
    return _contentRepository.getChallenge(challengeId);
  }
}
