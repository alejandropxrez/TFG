import 'package:algoquest/data/datasources/local/asset_content_local_data_source.dart';
import 'package:algoquest/data/datasources/local/drift/app_database.dart';
import 'package:algoquest/data/datasources/local/drift_user_local_data_source.dart';

import 'package:algoquest/data/repositories/content_repository_impl.dart';
import 'package:algoquest/data/repositories/user_repository_impl.dart';

import 'package:algoquest/domain/repositories/content_repository.dart';
import 'package:algoquest/domain/repositories/user_repository.dart';
import 'package:algoquest/domain/use_cases/check_challenge_use_case.dart';

import 'package:algoquest/domain/use_cases/check_solution_use_case.dart';
import 'package:algoquest/domain/use_cases/complete_level_use_case.dart';
import 'package:algoquest/domain/use_cases/consume_attempt_use_case.dart';
import 'package:algoquest/domain/use_cases/execute_move_use_case.dart';
import 'package:algoquest/domain/use_cases/get_level_syllabus_use_case.dart';
import 'package:algoquest/domain/use_cases/get_next_level_id_use_case.dart';
import 'package:algoquest/domain/use_cases/load_challenge_spec_use_case.dart';
import 'package:algoquest/domain/use_cases/load_learning_path_use_case.dart';
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

import 'use_cases.dart';

/// Application composition root.
///
/// This class is responsible for constructing the concrete data sources,
/// repositories, and use cases used by the application.
///
/// Dependencies are created in a single place so that the presentation layer
/// does not need to know how infrastructure components are instantiated.
class AppComposition {
  /// Repository responsible for loading and saving user progress.
  final UserRepository userRepository;

  /// Repository responsible for loading levels, challenges, and syllabus data.
  final ContentRepository contentRepository;

  /// Aggregated collection of application use cases exposed to Riverpod.
  final UseCases useCases;

  AppComposition._({
    required this.userRepository,
    required this.contentRepository,
    required this.useCases,
  });

  /// Builds the complete dependency graph of the application.
  ///
  /// The construction order follows the dependency direction:
  ///
  /// 1. Local data sources.
  /// 2. Repository implementations.
  /// 3. Domain use cases.
  /// 4. The [UseCases] container consumed by the presentation layer.
  ///
  /// Returns a fully initialized [AppComposition] ready to be injected at
  /// application startup.
  static Future<AppComposition> build() async {
    // Local persistence used for user progress.
    final database = AppDatabase();

    final userLocalDataSource = DriftUserLocalDataSource(database);
    final userRepository = UserRepositoryImpl(userLocalDataSource);

    // Static educational content loaded from bundled application assets.
    final contentLocalDataSource = AssetContentLocalDataSource();
    final contentRepository = ContentRepositoryImpl(contentLocalDataSource);

    // IMPORTANT!
    // Use cases expose their primary operation through a method named `call`.
    //
    // This convention provides a consistent invocation style while allowing each
    // use case to define the input parameters and return type that best fit its
    // responsibility, without requiring a common interface.

    // Content and challenge loading.
    final getLevelSyllabus = GetLevelSyllabusUseCase(contentRepository);
    final loadChallengeSpec = LoadChallengeSpecUseCase(contentRepository);
    final startChallengeSession = StartChallengeSessionUseCase(
      contentRepository,
    );

    // User progress and learning path management.
    final loadUserProgress = LoadUserProgressUseCase(userRepository);
    final loadLearningPath = LoadLearningPathUseCase(
      contentRepository: contentRepository,
      userRepository: userRepository,
    );
    final saveProgress = SaveProgressUseCase(userRepository);
    final manageProgress = const ManageProgressUseCase();
    final getNextLevelId = GetNextLevelIdUseCase(contentRepository);

    // Stateless challenge operations.
    final checkSolution = const CheckSolutionUseCase();
    final executeMove = const ExecuteMoveUseCase();
    final undoMove = const UndoMoveUseCase();
    final redoMove = const RedoMoveUseCase();
    final consumeAttempt = const ConsumeAttemptUseCase();
    final checkChallenge = const CheckChallengeUseCase();
    final submitQuizAnswer = const SubmitQuizAnswerUseCase();
    final submitIdentifyTarget = const SubmitIdentifyTargetUseCase();
    final submitCategorization = const SubmitCategorizationUseCase();

    // Challenge session lifecycle operations.
    final revealChallengeAnswer = RevealChallengeAnswerUseCase();
    final restartChallengeSession = RestartChallengeSessionUseCase();

    // Completing a level coordinates several existing use cases instead of
    // accessing repositories directly.
    final completeLevelProgress = CompleteLevelProgressUseCase(
      loadUserProgress: loadUserProgress.call,
      saveProgress: saveProgress.call,
      getNextLevelId: getNextLevelId.call,
      manageProgress: manageProgress,
    );

    // The presentation layer receives a single dependency container rather
    // than depending on individual constructors.
    final useCases = UseCases(
      getLevelSyllabus: getLevelSyllabus,
      loadChallengeSpec: loadChallengeSpec,
      startChallengeSession: startChallengeSession,
      executeMove: executeMove,
      checkSolution: checkSolution,
      loadUserProgress: loadUserProgress,
      loadLearningPath: loadLearningPath,
      saveProgress: saveProgress,
      manageProgress: manageProgress,
      undoMove: undoMove,
      redoMove: redoMove,
      consumeAttempt: consumeAttempt,
      checkChallenge: checkChallenge,
      submitQuizAnswer: submitQuizAnswer,
      submitIdentifyTarget: submitIdentifyTarget,
      submitCategorization: submitCategorization,
      getNextLevelId: getNextLevelId,
      revealChallengeAnswer: revealChallengeAnswer,
      restartChallengeSession: restartChallengeSession,
      completeLevelProgress: completeLevelProgress,
    );

    return AppComposition._(
      userRepository: userRepository,
      contentRepository: contentRepository,
      useCases: useCases,
    );
  }
}
