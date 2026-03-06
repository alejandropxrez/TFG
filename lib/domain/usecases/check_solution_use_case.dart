import '../entities/challenge_session.dart';
import '../strategies/validation_strategy_factory.dart';

class CheckSolutionUseCase {
  final ValidationStrategyFactory _factory;

  const CheckSolutionUseCase(this._factory);

  bool call(ChallengeSession session) {
    final validationType = session.spec.engineConfig.validationStrategy;

    final strategy = _factory.create(validationType);

    return strategy.isSolved(session);
  }
}
