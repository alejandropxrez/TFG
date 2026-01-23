import 'package:algoquest/data/datasources/local/in_memory_user_repository.dart';
import 'package:algoquest/data/repositories/user_repository_impl.dart';
import 'package:algoquest/domain/entities/user_progress.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:algoquest/data/models/user_progress_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  Hive.registerAdapter(UserProgressModelAdapter());

  final localDataSource = InMemoryUserRepository();

  final userRepository = UserRepositoryImpl(localDataSource);

  final userProgress = UserProgress(
    userId: 'user_1',
    level: 3,
    experiencePoints: 1200,
    livesRemaining: 5,
    unlockedLevels: {'level_1', 'level_2', 'level_3'},
    currentLevelId: 'level_3',
  );

  userRepository.updateUserProgress(userProgress);
  userRepository.fetchUserProgress('user_1').then((loadedProgress) {
    debugPrint('Loaded user progress:');
    debugPrint('UserId: ${loadedProgress?.userId}');
    debugPrint('Level: ${loadedProgress?.level}');
    debugPrint('XP: ${loadedProgress?.experiencePoints}');
    debugPrint('Unlocked levels: ${loadedProgress?.unlockedLevels}');
  });

  runApp(GameWidget(game: FlameGame()));
}
