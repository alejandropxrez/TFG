import 'package:algoquest/presentation/application_state/learning_path_provider.dart';
import 'package:algoquest/presentation/application_state/learning_path_state.dart';
import 'package:algoquest/presentation/router/app_router.dart';
import 'package:algoquest/presentation/widgets/level_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LearningPathScreen extends ConsumerStatefulWidget {
  const LearningPathScreen({super.key});

  @override
  ConsumerState<LearningPathScreen> createState() => _LearningPathScreenState();
}

class _LearningPathScreenState extends ConsumerState<LearningPathScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(learningPathProvider.notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(learningPathProvider);

    return Scaffold(
      appBar: AppBar(title: Text(state.title ?? 'AlgoQuest')),
      body: switch (state.status) {
        LearningPathStatus.idle || LearningPathStatus.loading => const Center(
          child: CircularProgressIndicator(),
        ),
        LearningPathStatus.failed => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              state.errorMessage ?? 'Error loading learning path',
              textAlign: TextAlign.center,
            ),
          ),
        ),
        LearningPathStatus.loaded => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Ruta de aprendizaje',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            for (final phase in state.phases) ...[
              Text(phase.title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              for (final level in phase.levels)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: LevelCard(
                    title: level.title,
                    subtitle: level.subtitle,
                    locked: level.locked,
                    onTap: level.locked
                        ? null
                        : () {
                            context.goNamed(
                              AppRouter.levelName,
                              pathParameters: {'levelId': level.id},
                            );
                          },
                  ),
                ),
              const SizedBox(height: 24),
            ],
          ],
        ),
      },
    );
  }
}
