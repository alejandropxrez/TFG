import 'package:algoquest/domain/entities/challenge_runtime_state.dart';
import 'package:algoquest/domain/entities/challenge_session.dart';
import 'package:algoquest/domain/enums/session_status.dart';
import 'package:algoquest/domain/usecases/check_quiz_answer_use_case.dart';
import 'package:algoquest/domain/usecases/check_solution_use_case.dart';

class CheckChallengeUseCase {
  final CheckSolutionUseCase _checkSolution;
  final CheckQuizAnswerUseCase _checkQuizAnswer;

  const CheckChallengeUseCase({
    CheckSolutionUseCase checkSolution = const CheckSolutionUseCase(),
    CheckQuizAnswerUseCase checkQuizAnswer = const CheckQuizAnswerUseCase(),
  }) : _checkSolution = checkSolution,
       _checkQuizAnswer = checkQuizAnswer;

  ChallengeSession call(ChallengeSession session) {
    final runtimeState = session.runtimeState;

    if (runtimeState is StructureRuntimeState) {
      final solved = _checkSolution(session);

      return session.copyWith(
        status: solved ? SessionStatus.completed : SessionStatus.inProgress,
        updatedAt: DateTime.now(),
      );
    }

    if (runtimeState is QuizRuntimeState) {
      return _checkQuizAnswer(session);
    }

    return session;
  }
}
