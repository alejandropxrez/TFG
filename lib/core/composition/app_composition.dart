import 'package:hive_ce/hive.dart';

import '../constants/hive_type_ids.dart';

import '../../data/datasources/local/asset_content_local_data_source.dart';
import '../../data/datasources/local/hive_user_local_data_source.dart';
import '../../data/models/user_progress_model.dart';
import '../../data/repositories/content_repository_impl.dart';
import '../../data/repositories/user_repository_impl.dart';

import '../../domain/repositories/content_repository.dart';
import '../../domain/repositories/user_repository.dart';

import '../../domain/usecases/get_level_syllabus_use_case.dart';
import '../../domain/usecases/load_challenge_spec_use_case.dart';
import '../../domain/usecases/start_challenge_session_use_case.dart';
import '../../domain/usecases/execute_move_use_case.dart';
import '../../domain/usecases/check_solution_use_case.dart';
import '../../domain/usecases/save_progress_use_case.dart';
import '../../domain/usecases/manage_progress_use_case.dart';

import '../../domain/strategies/validation_strategy.dart';

import 'hive_bootstrap.dart';
import 'use_cases.dart';

class _AlwaysFalseValidationStrategy implements ValidationStrategy {
  @override
  bool isSolved(session) => false;
}

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
    await HiveBootstrap.init();

    final userProgressBox = await Hive.openBox<UserProgressModel>(
      HiveBoxes.userProgress,
    );

    final userLocalDataSource = HiveUserLocalDataSource(userProgressBox);
    final userRepository = UserRepositoryImpl(userLocalDataSource);

    final contentLocalDataSource = AssetContentLocalDataSource();
    final contentRepository = ContentRepositoryImpl(contentLocalDataSource);

    final getLevelSyllabus = GetLevelSyllabusUseCase(contentRepository);
    final loadChallengeSpec = LoadChallengeSpecUseCase(contentRepository);
    final startChallengeSession = StartChallengeSessionUseCase(
      contentRepository,
    );

    final executeMove = const ExecuteMoveUseCase();

    // NOTE: placeholder until a real ValidationStrategy resolver/factory is implemented.
    final checkSolution = CheckSolutionUseCase(
      _AlwaysFalseValidationStrategy(),
    );

    final saveProgress = SaveProgressUseCase(userRepository);
    final manageProgress = const ManageProgressUseCase();

    final useCases = UseCases(
      getLevelSyllabus: getLevelSyllabus,
      loadChallengeSpec: loadChallengeSpec,
      startChallengeSession: startChallengeSession,
      executeMove: executeMove,
      checkSolution: checkSolution,
      saveProgress: saveProgress,
      manageProgress: manageProgress,
    );

    return AppComposition._(
      userRepository: userRepository,
      contentRepository: contentRepository,
      useCases: useCases,
    );
  }
}
