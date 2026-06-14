import 'package:algoquest/domain/entities/challenge_runtime_state.dart';
import 'package:algoquest/domain/entities/challenge_session.dart';
import 'package:algoquest/domain/enums/session_status.dart';
import 'package:algoquest/domain/use_cases/check_categorization_use_case.dart';
import 'package:algoquest/domain/use_cases/check_identify_target_use_case.dart';
import 'package:algoquest/domain/use_cases/check_quiz_answer_use_case.dart';
import 'package:algoquest/domain/use_cases/check_solution_use_case.dart';

class CheckChallengeUseCase {
  final CheckSolutionUseCase _checkSolution;
  final CheckQuizAnswerUseCase _checkQuizAnswer;
  final CheckIdentifyTargetUseCase _checkIdentifyTarget;
  final CheckCategorizationUseCase _checkCategorization;

  const CheckChallengeUseCase({
    CheckSolutionUseCase checkSolution = const CheckSolutionUseCase(),
    CheckQuizAnswerUseCase checkQuizAnswer = const CheckQuizAnswerUseCase(),
    CheckIdentifyTargetUseCase checkIdentifyTarget =
        const CheckIdentifyTargetUseCase(),
    CheckCategorizationUseCase checkCategorization =
        const CheckCategorizationUseCase(),
  }) : _checkSolution = checkSolution,
       _checkQuizAnswer = checkQuizAnswer,
       _checkIdentifyTarget = checkIdentifyTarget,
       _checkCategorization = checkCategorization;

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

    if (runtimeState is IdentifyTargetRuntimeState) {
      return _checkIdentifyTarget(session);
    }

    if (runtimeState is CategorizeRuntimeState) {
      return _checkCategorization(session);
    }

    return session;
  }
}
