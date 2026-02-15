import '../entities/challenge_session.dart';
import '../strategies/validation_strategy.dart';

class CheckSolutionUseCase {
  final ValidationStrategy _validator;

  CheckSolutionUseCase(this._validator);

  bool call(ChallengeSession session) {
    return _validator.isSolved(session);
  }
}
