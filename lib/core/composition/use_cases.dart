import 'package:algoquest/domain/usecases/check_solution_use_case.dart';
import 'package:algoquest/domain/usecases/consume_attempt_use_case.dart';
import 'package:algoquest/domain/usecases/execute_move_use_case.dart';
import 'package:algoquest/domain/usecases/get_level_syllabus_use_case.dart';
import 'package:algoquest/domain/usecases/load_challenge_spec_use_case.dart';
import 'package:algoquest/domain/usecases/load_user_progress_use_case.dart';
import 'package:algoquest/domain/usecases/manage_progress_use_case.dart';
import 'package:algoquest/domain/usecases/redo_move_use_case.dart';
import 'package:algoquest/domain/usecases/save_progress_use_case.dart';
import 'package:algoquest/domain/usecases/start_challenge_session_use_case.dart';
import 'package:algoquest/domain/usecases/undo_move_use_case.dart';

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
  });
}
