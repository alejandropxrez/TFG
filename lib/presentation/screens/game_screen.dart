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

    game = AlgoQuestGame()
      ..onSwapRequested = (firstNodeId, secondNodeId) {
        debugPrint('UI received swap request: $firstNodeId <-> $secondNodeId');

        ref
            .read(levelStateProvider.notifier)
            .executeAction(
              SwapNodesAction(
                firstNodeId: firstNodeId,
                secondNodeId: secondNodeId,
              ),
            );
      };
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
          _DebugGamePanel(
            status: state.status.name,
            challengeId: state.currentChallengeId,
            currentChallengeNumber: state.totalChallenges == 0
                ? 0
                : state.currentChallengeIndex + 1,
            totalChallenges: state.totalChallenges,
            errorMessage: state.errorMessage,
            canStartChallenge: state.currentChallengeId != null,
            canInteract: state.currentSession != null,
            onLoadLevel: () => notifier.loadLevel('level_heap_intro'),
            onStartChallenge: () => notifier.startCurrentChallenge(
              userId: 'user_1',
              sessionId: 'session_1',
            ),
            onSwapDebug: () => notifier.executeAction(
              const SwapNodesAction(firstNodeId: 'n1', secondNodeId: 'n2'),
            ),
            onCheckSolution: notifier.checkSolution,
            onCompleteChallenge: () => notifier.completeCurrentChallenge(
              userId: 'user_1',
              nextSessionId: 'session_${DateTime.now().millisecondsSinceEpoch}',
            ),
            onReset: notifier.resetLevelFlow,
          ),
        ],
      ),
    );
  }
}

class _DebugGamePanel extends StatelessWidget {
  final String status;
  final String? challengeId;
  final int currentChallengeNumber;
  final int totalChallenges;
  final String? errorMessage;

  final bool canStartChallenge;
  final bool canInteract;

  final Future<void> Function() onLoadLevel;
  final Future<void> Function() onStartChallenge;
  final VoidCallback onSwapDebug;
  final VoidCallback onCheckSolution;
  final Future<void> Function() onCompleteChallenge;
  final VoidCallback onReset;

  const _DebugGamePanel({
    required this.status,
    required this.challengeId,
    required this.currentChallengeNumber,
    required this.totalChallenges,
    required this.errorMessage,
    required this.canStartChallenge,
    required this.canInteract,
    required this.onLoadLevel,
    required this.onStartChallenge,
    required this.onSwapDebug,
    required this.onCheckSolution,
    required this.onCompleteChallenge,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Status: $status'
            ' | Challenge: ${challengeId ?? "-"}'
            ' | $currentChallengeNumber/$totalChallenges',
            textAlign: TextAlign.center,
          ),
          if (errorMessage != null) ...[
            const SizedBox(height: 6),
            Text(
              errorMessage!,
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
                onPressed: onLoadLevel,
                child: const Text('Load Level'),
              ),
              ElevatedButton(
                onPressed: canStartChallenge ? onStartChallenge : null,
                child: const Text('Start Challenge'),
              ),
              ElevatedButton(
                onPressed: canInteract ? onSwapDebug : null,
                child: const Text('Swap n1/n2'),
              ),
              ElevatedButton(
                onPressed: canInteract ? onCheckSolution : null,
                child: const Text('Check Solution'),
              ),
              ElevatedButton(
                onPressed: canInteract ? onCompleteChallenge : null,
                child: const Text('Complete Challenge'),
              ),
              ElevatedButton(onPressed: onReset, child: const Text('Reset')),
            ],
          ),
        ],
      ),
    );
  }
}
