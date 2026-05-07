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

    return SafeArea(
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              blurRadius: 12,
              color: Colors.black.withValues(alpha: 0.15),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    progressText,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Text(
                  'Movs: $movesUsed',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (instruction != null)
              Text(
                instruction!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
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
      ),
    );
  }
}
