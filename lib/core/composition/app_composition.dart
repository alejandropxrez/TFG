import 'package:algoquest/core/constants/hive_type_ids.dart';
import 'package:hive_ce/hive.dart';

import '../../data/datasources/local/hive_user_local_data_source.dart';
import '../../data/models/user_progress_model.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../domain/repositories/user_repository.dart';

import 'hive_bootstrap.dart';

class AppComposition {
  final UserRepository userRepository;

  // Avoid the constructor being called outside this class.
  AppComposition._({required this.userRepository});

  static Future<AppComposition> build() async {
    await HiveBootstrap.init();

    // Open boxes
    final userProgressBox = await Hive.openBox<UserProgressModel>(
      HiveBoxes.userProgress,
    );

    // Wire dependencies
    final userLocalDataSource = HiveUserLocalDataSource(userProgressBox);
    final userRepository = UserRepositoryImpl(userLocalDataSource);

    return AppComposition._(userRepository: userRepository);
  }
}
