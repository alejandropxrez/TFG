import 'package:algoquest/presentation/screens/game_screen.dart';
import 'package:algoquest/presentation/screens/learning_path_screen.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  static const String learningPathName = 'learningPath';
  static const String levelName = 'level';

  static final GoRouter router = GoRouter(
    initialLocation: '/map',
    routes: [
      GoRoute(
        path: '/map',
        name: learningPathName,
        builder: (context, state) => const LearningPathScreen(),
      ),
      GoRoute(
        path: '/level/:levelId',
        name: levelName,
        builder: (context, state) {
          final levelId = state.pathParameters['levelId'];

          if (levelId == null || levelId.isEmpty) {
            throw StateError('Missing levelId in route.');
          }

          return GameScreen(levelId: levelId);
        },
      ),
    ],
  );
}
