import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/level_state_provider.dart';
import '../../domain/entities/game_action.dart';
import '../game/algoquest_game.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  late final AlgoQuestGame game;

  @override
  void initState() {
    super.initState();
    game = AlgoQuestGame();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(levelStateProvider);
    final notifier = ref.read(levelStateProvider.notifier);

    final spec = state.currentChallengeSpec;
    final session = state.currentSession;

    if (spec != null && session != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        game.updateScene(spec: spec, state: session.currentState);
      });
    }

    return Scaffold(
      appBar: AppBar(title: const Text('AlgoQuest')),
      body: Column(
        children: [
          Expanded(child: GameWidget(game: game)),

          // DEBUG PANEL
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Theme.of(context).colorScheme.surface,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Status: ${state.status.name}'
                  ' | Challenge: ${state.currentChallengeId ?? "-"}'
                  ' | ${state.totalChallenges == 0 ? 0 : state.currentChallengeIndex + 1}/${state.totalChallenges}',
                  textAlign: TextAlign.center,
                ),

                if (state.errorMessage != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    state.errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ],

                const SizedBox(height: 8),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        await notifier.loadLevel('level_heap_intro');
                      },
                      child: const Text('Load Level'),
                    ),

                    ElevatedButton(
                      onPressed: state.currentChallengeId == null
                          ? null
                          : () async {
                              await notifier.startCurrentChallenge(
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
                          : () async {
                              await notifier.completeCurrentChallenge(
                                userId: 'user_1',
                                nextSessionId:
                                    'session_${DateTime.now().millisecondsSinceEpoch}',
                              );
                            },
                      child: const Text('Complete Challenge'),
                    ),

                    ElevatedButton(
                      onPressed: () {
                        notifier.resetLevelFlow();
                      },
                      child: const Text('Reset'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
