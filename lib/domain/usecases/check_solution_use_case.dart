import 'package:algoquest/domain/entities/challenge_runtime_state.dart';
import 'package:algoquest/domain/entities/challenge_session.dart';

class CheckSolutionUseCase {
  const CheckSolutionUseCase();

  bool call(ChallengeSession session) {
    final runtimeState = session.runtimeState;

    if (runtimeState is! StructureRuntimeState) {
      return false;
    }

    return session.spec.engineConfig.validationStrategy.isSolved(session);
  }
}
