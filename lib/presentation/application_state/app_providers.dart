import 'package:algoquest/data/core/composition/use_cases.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final useCasesProvider = Provider<UseCases>((ref) {
  throw UnimplementedError(
    'UseCases must be provided from AppComposition using ProviderScope overrides.',
  );
});

final currentUserIdProvider = Provider<String>((ref) {
  // Temporary until authentication/profile selection exists.
  return 'local_user';
});

final learningPathDependenciesProvider = Provider<LearningPathDependencies>(
  (ref) => LearningPathDependencies.fromUseCases(ref.watch(useCasesProvider)),
);

final levelDependenciesProvider = Provider<LevelDependencies>(
  (ref) => LevelDependencies.fromUseCases(ref.watch(useCasesProvider)),
);
