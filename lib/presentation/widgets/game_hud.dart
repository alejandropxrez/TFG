import 'package:flutter/material.dart';

class GameHud extends StatelessWidget {
  final String status;
  final String? challengeId;
  final int currentChallengeNumber;
  final int totalChallenges;
  final int movesUsed;
  final String? instruction;
  final VoidCallback? onCheckSolution;

  const GameHud({
    super.key,
    required this.status,
    required this.challengeId,
    required this.currentChallengeNumber,
    required this.totalChallenges,
    required this.movesUsed,
    required this.instruction,
    this.onCheckSolution,
  });

  @override
  Widget build(BuildContext context) {
    final progressText = totalChallenges == 0
        ? 'Reto -/-'
        : 'Reto $currentChallengeNumber/$totalChallenges';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  progressText,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              Text(
                'Movs: $movesUsed',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          if (instruction != null) ...[
            const SizedBox(height: 6),
            Text(
              instruction!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Estado: $status',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              ElevatedButton(
                onPressed: onCheckSolution,
                child: const Text('Comprobar'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
