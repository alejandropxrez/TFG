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
