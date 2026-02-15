import '../entities/challenge_session.dart';
import '../repositories/content_repository.dart';

class StartChallengeSessionUseCase {
  final ContentRepository _contentRepository;

  StartChallengeSessionUseCase(this._contentRepository);

  Future<ChallengeSession> call({
    required String userId,
    required String challengeId,
    required String sessionId,
  }) async {
    final spec = await _contentRepository.getChallenge(challengeId);

    return ChallengeSession.start(
      sessionId: sessionId,
      userId: userId,
      spec: spec,
    );
  }
}
