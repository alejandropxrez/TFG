import 'package:algoquest/domain/use_cases/check_challenge_use_case.dart';
import 'package:algoquest/domain/use_cases/check_solution_use_case.dart';
import 'package:algoquest/domain/use_cases/complete_level_use_case.dart';
import 'package:algoquest/domain/use_cases/consume_attempt_use_case.dart';
import 'package:algoquest/domain/use_cases/execute_move_use_case.dart';
import 'package:algoquest/domain/use_cases/get_level_syllabus_use_case.dart';
import 'package:algoquest/domain/use_cases/get_next_level_id_use_case.dart';
import 'package:algoquest/domain/use_cases/load_challenge_spec_use_case.dart';
import 'package:algoquest/domain/use_cases/load_user_progress_use_case.dart';
import 'package:algoquest/domain/use_cases/manage_progress_use_case.dart';
import 'package:algoquest/domain/use_cases/redo_move_use_case.dart';
import 'package:algoquest/domain/use_cases/restart_challenge_session_use_case.dart';
import 'package:algoquest/domain/use_cases/reveal_challenge_answer_use_case.dart';
import 'package:algoquest/domain/use_cases/save_progress_use_case.dart';
import 'package:algoquest/domain/use_cases/start_challenge_session_use_case.dart';
import 'package:algoquest/domain/use_cases/submit_categorization_use_case.dart';
import 'package:algoquest/domain/use_cases/submit_identify_target_use_case.dart';
import 'package:algoquest/domain/use_cases/submit_quiz_answer_use_case.dart';
import 'package:algoquest/domain/use_cases/undo_move_use_case.dart';

class UseCases {
  final GetLevelSyllabusUseCase getLevelSyllabus;
  final LoadChallengeSpecUseCase loadChallengeSpec;
  final StartChallengeSessionUseCase startChallengeSession;

  final ExecuteMoveUseCase executeMove;
  final CheckSolutionUseCase checkSolution;

  final LoadUserProgressUseCase loadUserProgress;
  final SaveProgressUseCase saveProgress;
  final ManageProgressUseCase manageProgress;
  final UndoMoveUseCase undoMove;
  final RedoMoveUseCase redoMove;
  final ConsumeAttemptUseCase consumeAttempt;
  final CheckChallengeUseCase checkChallenge;
  final SubmitQuizAnswerUseCase submitQuizAnswer;
  final SubmitIdentifyTargetUseCase submitIdentifyTarget;
  final SubmitCategorizationUseCase submitCategorization;
  final GetNextLevelIdUseCase getNextLevelId;
  final RevealChallengeAnswerUseCase revealChallengeAnswer;
  final RestartChallengeSessionUseCase restartChallengeSession;
  final CompleteLevelProgressUseCase completeLevelProgress;

  const UseCases({
    required this.getLevelSyllabus,
    required this.loadChallengeSpec,
    required this.startChallengeSession,
    required this.executeMove,
    required this.checkSolution,
    required this.loadUserProgress,
    required this.saveProgress,
    required this.manageProgress,
    required this.undoMove,
    required this.redoMove,
    required this.consumeAttempt,
    required this.checkChallenge,
    required this.submitQuizAnswer,
    required this.submitIdentifyTarget,
    required this.submitCategorization,
    required this.getNextLevelId,
    required this.revealChallengeAnswer,
    required this.restartChallengeSession,
    required this.completeLevelProgress,
  });
}
