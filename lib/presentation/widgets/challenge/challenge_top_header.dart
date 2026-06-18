import 'package:algoquest/presentation/theme/app_assets.dart';
import 'package:algoquest/presentation/widgets/challenge/challenge_hearts_indicator.dart';
import 'package:algoquest/presentation/widgets/shared/app_back_button.dart';
import 'package:flutter/material.dart';

class ChallengeTopHeader extends StatelessWidget {
  final int currentChallengeNumber;
  final int totalChallenges;
  final int? heartsRemaining;
  final int? maxHearts;
  final int? movesRemaining;
  final VoidCallback onBack;

  const ChallengeTopHeader({
    super.key,
    required this.currentChallengeNumber,
    required this.totalChallenges,
    required this.onBack,
    this.heartsRemaining,
    this.maxHearts,
    this.movesRemaining,
  });

  @override
  Widget build(BuildContext context) {
    final shouldShowHearts = heartsRemaining != null && maxHearts != null;

    return Container(
      height: 72,
      padding: const EdgeInsets.fromLTRB(12, 10, 14, 10),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6B3DEB), Color(0xFF4321A8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            AppBackButton(onPressed: onBack),
            const SizedBox(width: 10),
            Expanded(
              child: Center(
                child: Text(
                  'Desafío $currentChallengeNumber/$totalChallenges',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            if (shouldShowHearts)
              ChallengeHeartsIndicator(
                heartsLeft: heartsRemaining!,
                maxHearts: maxHearts!,
                heartSize: 18,
                heartScale: 3.5,
                spacing: 8,
                emptyOpacity: 0.32,
              ),
            if (movesRemaining != null) ...[
              const SizedBox(width: 12),
              _MovesIndicator(movesRemaining: movesRemaining!),
            ],
          ],
        ),
      ),
    );
  }
}

class _MovesIndicator extends StatelessWidget {
  final int movesRemaining;

  const _MovesIndicator({required this.movesRemaining});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: Image.asset(AppAssets.movesRemaining, fit: BoxFit.contain),
          ),
          const SizedBox(width: 5),
          Text(
            movesRemaining.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
