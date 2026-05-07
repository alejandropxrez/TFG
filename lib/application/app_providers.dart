import 'package:algoquest/core/composition/use_cases.dart';
import 'package:flutter/services.dart';
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

final syllabusJsonLoaderProvider = Provider<Future<String> Function()>((ref) {
  return () => rootBundle.loadString('assets/data/syllabus.json');
});
