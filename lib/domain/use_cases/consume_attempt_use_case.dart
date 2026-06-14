import 'package:algoquest/domain/entities/challenge_session.dart';
import 'package:algoquest/domain/enums/session_status.dart';

class ConsumeAttemptUseCase {
  const ConsumeAttemptUseCase();

  ChallengeSession call(ChallengeSession session) {
    final attemptsRemaining = session.attemptsRemaining;

    if (attemptsRemaining == null) {
      return session;
    }

    final nextAttempts = attemptsRemaining <= 0 ? 0 : attemptsRemaining - 1;

    return session.copyWith(
      attemptsRemaining: nextAttempts,
      status: nextAttempts <= 0
          ? SessionStatus.failed
          : SessionStatus.inProgress,
      updatedAt: DateTime.now(),
    );
  }
}
