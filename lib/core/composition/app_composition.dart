import 'package:algoquest/core/constants/hive_type_ids.dart';
import 'package:algoquest/data/datasources/local/asset_content_local_data_source.dart';
import 'package:algoquest/data/repositories/content_repository_impl.dart';
import 'package:algoquest/domain/repositories/content_repository.dart';
import 'package:hive_ce/hive.dart';

import '../../data/datasources/local/hive_user_local_data_source.dart';
import '../../data/models/user_progress_model.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../domain/repositories/user_repository.dart';

import '../../domain/usecases/get_level_syllabus_use_case.dart';
import '../../domain/usecases/load_challenge_spec_use_case.dart';
import '../../domain/usecases/start_challenge_session_use_case.dart';

import 'hive_bootstrap.dart';

class AppComposition {
  final UserRepository userRepository;
  final ContentRepository contentRepository;

  final GetLevelSyllabusUseCase getLevelSyllabusUseCase;
  final LoadChallengeSpecUseCase loadChallengeSpecUseCase;
  final StartChallengeSessionUseCase startChallengeSessionUseCase;

  AppComposition._({
    required this.userRepository,
    required this.contentRepository,
    required this.getLevelSyllabusUseCase,
    required this.loadChallengeSpecUseCase,
    required this.startChallengeSessionUseCase,
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

    final getLevelSyllabusUseCase = GetLevelSyllabusUseCase(contentRepository);
    final loadChallengeSpecUseCase = LoadChallengeSpecUseCase(
      contentRepository,
    );
    final startChallengeSessionUseCase = StartChallengeSessionUseCase(
      contentRepository,
    );

    return AppComposition._(
      userRepository: userRepository,
      contentRepository: contentRepository,
      getLevelSyllabusUseCase: getLevelSyllabusUseCase,
      loadChallengeSpecUseCase: loadChallengeSpecUseCase,
      startChallengeSessionUseCase: startChallengeSessionUseCase,
    );
  }
}
