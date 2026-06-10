import 'package:algoquest/domain/entities/level_syllabus.dart';
import 'package:flutter/material.dart';

class LevelIntroView extends StatelessWidget {
  final LevelSyllabus syllabus;
  final VoidCallback onStartPractice;

  const LevelIntroView({
    super.key,
    required this.syllabus,
    required this.onStartPractice,
  });

  @override
  Widget build(BuildContext context) {
    final theory = syllabus.theory;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(syllabus.title, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        if (theory != null) ...[
          Text(theory.title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Text(theory.content, style: Theme.of(context).textTheme.bodyLarge),
          if (theory.keyPoints.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text('Ideas clave', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            for (final point in theory.keyPoints)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• '),
                    Expanded(child: Text(point)),
                  ],
                ),
              ),
          ],
        ] else ...[
          Text(
            'Repasa el concepto principal antes de empezar la práctica.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
        const SizedBox(height: 24),
        FilledButton(
          onPressed: onStartPractice,
          child: const Text('Empezar práctica'),
        ),
      ],
    );
  }
}
