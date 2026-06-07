import 'package:flutter/material.dart';

class DebugGameControls extends StatelessWidget {
  final String status;
  final String? challengeId;
  final int currentChallengeNumber;
  final int totalChallenges;
  final int movesUsed;
  final String? errorMessage;

  final bool canStartChallenge;
  final bool canInteract;
  final bool canUndo;

  final Future<void> Function() onLoadLevel;
  final Future<void> Function() onStartChallenge;
  final VoidCallback onSwapDebug;
  final VoidCallback onUndo;
  final bool canRedo;
  final VoidCallback onRedo;
  final VoidCallback onCheckSolution;
  final Future<void> Function() onCompleteChallenge;
  final VoidCallback onReset;
  final int? attemptsRemaining;

  const DebugGameControls({
    super.key,
    required this.status,
    required this.challengeId,
    required this.currentChallengeNumber,
    required this.totalChallenges,
    required this.movesUsed,
    required this.errorMessage,
    required this.canStartChallenge,
    required this.canInteract,
    required this.canUndo,
    required this.canRedo,
    required this.onLoadLevel,
    required this.onStartChallenge,
    required this.onSwapDebug,
    required this.onUndo,
    required this.onRedo,
    required this.onCheckSolution,
    required this.onCompleteChallenge,
    required this.onReset,
    required this.attemptsRemaining,
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
            ' | $currentChallengeNumber/$totalChallenges'
            ' | Moves: $movesUsed'
            ' | Attempts: ${attemptsRemaining?.toString() ?? "-"}',
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
                onPressed: canUndo ? onUndo : null,
                child: const Text('Undo'),
              ),
              ElevatedButton(
                onPressed: canRedo ? onRedo : null,
                child: const Text('Redo'),
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
