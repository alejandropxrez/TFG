import '../../domain/usecases/get_level_syllabus_use_case.dart';
import '../../domain/usecases/load_challenge_spec_use_case.dart';
import '../../domain/usecases/start_challenge_session_use_case.dart';
import '../../domain/usecases/execute_move_use_case.dart';
import '../../domain/usecases/check_solution_use_case.dart';
import '../../domain/usecases/save_progress_use_case.dart';
import '../../domain/usecases/manage_progress_use_case.dart';

class UseCases {
  final GetLevelSyllabusUseCase getLevelSyllabus;
  final LoadChallengeSpecUseCase loadChallengeSpec;
  final StartChallengeSessionUseCase startChallengeSession;

  final ExecuteMoveUseCase executeMove;
  final CheckSolutionUseCase checkSolution;

  final SaveProgressUseCase saveProgress;
  final ManageProgressUseCase manageProgress;

  const UseCases({
    required this.getLevelSyllabus,
    required this.loadChallengeSpec,
    required this.startChallengeSession,
    required this.executeMove,
    required this.checkSolution,
    required this.saveProgress,
    required this.manageProgress,
  });
}
