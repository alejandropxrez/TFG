import 'package:algoquest/presentation/router/app_router.dart';
import 'package:algoquest/presentation/widgets/level_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LearningPathScreen extends StatelessWidget {
  const LearningPathScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AlgoQuest')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Ruta de aprendizaje',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          LevelCard(
            title: 'Introducción a Heaps',
            subtitle: 'Reto inicial: reparar un Max-Heap',
            locked: false,
            onTap: () {
              context.go(AppRouter.gamePath('level_heap_intro'));
            },
          ),
          LevelCard(
            title: 'BST básico',
            subtitle: 'Próximamente',
            locked: true,
            onTap: null,
          ),
        ],
      ),
    );
  }
}
