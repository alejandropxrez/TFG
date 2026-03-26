import 'package:algoquest/domain/entities/challenge_session.dart';

class CheckSolutionUseCase {
  const CheckSolutionUseCase();

  bool call(ChallengeSession session) {
    return session.spec.engineConfig.validationStrategy.isSolved(session);
  }
}
