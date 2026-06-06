import 'package:algoquest/data/datasources/local/asset_content_local_data_source.dart';
import 'package:algoquest/data/datasources/local/drift/app_database.dart';
import 'package:algoquest/data/datasources/local/drift_user_local_data_source.dart';

import 'package:algoquest/data/repositories/content_repository_impl.dart';
import 'package:algoquest/data/repositories/user_repository_impl.dart';

import 'package:algoquest/domain/repositories/content_repository.dart';
import 'package:algoquest/domain/repositories/user_repository.dart';

import 'package:algoquest/domain/usecases/check_solution_use_case.dart';
import 'package:algoquest/domain/usecases/execute_move_use_case.dart';
import 'package:algoquest/domain/usecases/get_level_syllabus_use_case.dart';
import 'package:algoquest/domain/usecases/load_challenge_spec_use_case.dart';
import 'package:algoquest/domain/usecases/load_user_progress_use_case.dart';
import 'package:algoquest/domain/usecases/manage_progress_use_case.dart';
import 'package:algoquest/domain/usecases/redo_move_use_case.dart';
import 'package:algoquest/domain/usecases/save_progress_use_case.dart';
import 'package:algoquest/domain/usecases/start_challenge_session_use_case.dart';
import 'package:algoquest/domain/usecases/undo_move_use_case.dart';

import 'use_cases.dart';

class AppComposition {
  final UserRepository userRepository;
  final ContentRepository contentRepository;
  final UseCases useCases;

  AppComposition._({
    required this.userRepository,
    required this.contentRepository,
    required this.useCases,
  });

  static Future<AppComposition> build() async {
    final database = AppDatabase();

    final userLocalDataSource = DriftUserLocalDataSource(database);
    final userRepository = UserRepositoryImpl(userLocalDataSource);

    final contentLocalDataSource = AssetContentLocalDataSource();
    final contentRepository = ContentRepositoryImpl(contentLocalDataSource);

    final getLevelSyllabus = GetLevelSyllabusUseCase(contentRepository);
    final loadChallengeSpec = LoadChallengeSpecUseCase(contentRepository);
    final startChallengeSession = StartChallengeSessionUseCase(
      contentRepository,
    );

    final checkSolution = const CheckSolutionUseCase();
    final executeMove = const ExecuteMoveUseCase();

    final loadUserProgress = LoadUserProgressUseCase(userRepository);
    final saveProgress = SaveProgressUseCase(userRepository);
    final manageProgress = const ManageProgressUseCase();
    final undomove = const UndoMoveUseCase();
    final redoMove = const RedoMoveUseCase();

    final useCases = UseCases(
      getLevelSyllabus: getLevelSyllabus,
      loadChallengeSpec: loadChallengeSpec,
      startChallengeSession: startChallengeSession,
      executeMove: executeMove,
      checkSolution: checkSolution,
      loadUserProgress: loadUserProgress,
      saveProgress: saveProgress,
      manageProgress: manageProgress,
      undoMove: undomove,
      redoMove: redoMove,
    );

    return AppComposition._(
      userRepository: userRepository,
      contentRepository: contentRepository,
      useCases: useCases,
    );
  }
}
