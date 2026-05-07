import 'package:algoquest/presentation/screens/game_screen.dart';
import 'package:algoquest/presentation/screens/learning_path_screen.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  static const String learningPath = '/';
  static const String game = 'game';

  static String gamePath(String levelId) => '/levels/$levelId/game';

  static final GoRouter router = GoRouter(
    initialLocation: learningPath,
    routes: [
      GoRoute(
        path: learningPath,
        name: 'learningPath',
        builder: (context, state) => const LearningPathScreen(),
      ),
      GoRoute(
        path: '/levels/:levelId/game',
        name: game,
        builder: (context, state) {
          final levelId = state.pathParameters['levelId']!;
          return GameScreen(levelId: levelId);
        },
      ),
    ],
  );
}
