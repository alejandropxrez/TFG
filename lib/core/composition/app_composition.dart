import 'package:hive_ce/hive.dart';

import 'package:algoquest/core/constants/hive_type_ids.dart';

import 'package:algoquest/data/datasources/local/asset_content_local_data_source.dart';
import 'package:algoquest/data/datasources/local/hive_user_local_data_source.dart';

import 'package:algoquest/data/models/user_progress_model.dart';

import 'package:algoquest/data/repositories/content_repository_impl.dart';
import 'package:algoquest/data/repositories/user_repository_impl.dart';
import 'package:algoquest/domain/repositories/content_repository.dart';
import 'package:algoquest/domain/repositories/user_repository.dart';

import 'package:algoquest/domain/strategies/validation_strategy_factory.dart';

import 'package:algoquest/domain/usecases/check_solution_use_case.dart';
import 'package:algoquest/domain/usecases/execute_move_use_case.dart';
import 'package:algoquest/domain/usecases/get_level_syllabus_use_case.dart';
import 'package:algoquest/domain/usecases/load_challenge_spec_use_case.dart';
import 'package:algoquest/domain/usecases/manage_progress_use_case.dart';
import 'package:algoquest/domain/usecases/save_progress_use_case.dart';
import 'package:algoquest/domain/usecases/start_challenge_session_use_case.dart';

import 'hive_bootstrap.dart';
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

    final validationStrategyFactory = const ValidationStrategyFactory();

    final checkSolution = CheckSolutionUseCase(validationStrategyFactory);
    final executeMove = const ExecuteMoveUseCase();

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
