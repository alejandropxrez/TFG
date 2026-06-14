import 'package:algoquest/domain/entities/challenge_session.dart';
import 'package:algoquest/domain/entities/challenge_spec.dart';
import 'package:algoquest/domain/enums/session_status.dart';

class ConsumeAttemptUseCase {
  const ConsumeAttemptUseCase();

  ChallengeSession call(ChallengeSession session) {
    final attemptsRemaining = session.attemptsRemaining;

    if (attemptsRemaining == null) {
      return session.copyWith(
        status: SessionStatus.inProgress,
        updatedAt: DateTime.now(),
      );
    }

    final livesConsumed = session.spec.livesConsumedOnFail;

    if (livesConsumed <= 0) {
      return session.copyWith(
        status: SessionStatus.inProgress,
        updatedAt: DateTime.now(),
      );
    }

    final nextAttempts = attemptsRemaining - livesConsumed;
    final safeAttempts = nextAttempts < 0 ? 0 : nextAttempts;

    return session.copyWith(
      attemptsRemaining: safeAttempts,
      status: safeAttempts == 0
          ? SessionStatus.failed
          : SessionStatus.inProgress,
      updatedAt: DateTime.now(),
    );
  }
}
