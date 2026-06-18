import 'package:algoquest/domain/entities/challenge_session.dart';
import 'package:algoquest/domain/enums/session_status.dart';

class RestartChallengeSessionUseCase {
  ChallengeSession call(ChallengeSession session) {
    if (!session.hasAttemptsRemaining) {
      return session;
    }

    final restartedSession = ChallengeSession.start(
      sessionId: session.sessionId,
      userId: session.userId,
      spec: session.spec,
    );

    return restartedSession.copyWith(
      attemptsRemaining: session.attemptsRemaining,
      status: SessionStatus.inProgress,
    );
  }
}
