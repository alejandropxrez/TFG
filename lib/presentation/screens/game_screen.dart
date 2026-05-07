import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/level_state_provider.dart';
import '../../domain/entities/game_action.dart';

class GameScreen extends ConsumerWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(levelStateProvider);
    final notifier = ref.read(levelStateProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('AlgoQuest - Test Flow')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status: ${state.status.name}'),
            Text('Level: ${state.syllabus?.title ?? "-"}'),
            Text(
              'Challenge: ${state.currentChallengeId ?? "-"} '
              '(${state.currentChallengeIndex + 1}/${state.totalChallenges})',
            ),
            Text('Error: ${state.errorMessage ?? "-"}'),
            const SizedBox(height: 16),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: () {
                    notifier.loadLevel('level_heap_intro');
                  },
                  child: const Text('Load Level'),
                ),
                ElevatedButton(
                  onPressed: state.currentChallengeId == null
                      ? null
                      : () {
                          notifier.startCurrentChallenge(
                            userId: 'user_1',
                            sessionId: 'session_1',
                          );
                        },
                  child: const Text('Start Challenge'),
                ),
                ElevatedButton(
                  onPressed: state.currentSession == null
                      ? null
                      : () {
                          notifier.executeAction(
                            const SwapNodesAction(
                              firstNodeId: 'n1',
                              secondNodeId: 'n2',
                            ),
                          );
                        },
                  child: const Text('Swap n1/n2'),
                ),
                ElevatedButton(
                  onPressed: state.currentSession == null
                      ? null
                      : () {
                          notifier.checkSolution();
                        },
                  child: const Text('Check Solution'),
                ),
                ElevatedButton(
                  onPressed: state.currentSession == null
                      ? null
                      : () {
                          notifier.completeCurrentChallenge(
                            userId: 'user_1',
                            nextSessionId:
                                'session_${DateTime.now().millisecondsSinceEpoch}',
                          );
                        },
                  child: const Text('Complete Challenge'),
                ),
              ],
            ),

            const SizedBox(height: 24),
            const Text(
              'Current structure:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            Expanded(
              child: ListView(
                children: [
                  for (final entry
                      in state.currentSession?.currentState.nodes.entries ??
                          const [])
                    ListTile(
                      title: Text((entry as MapEntry).key),
                      subtitle: Text('value: ${entry.value.value}'),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
