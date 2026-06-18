import 'package:algoquest/presentation/theme/app_assets.dart';
import 'package:algoquest/presentation/widgets/challenge/challenge_action_button.dart';
import 'package:flutter/material.dart';

class ChallengeBottomActions extends StatelessWidget {
  final VoidCallback? onReset;
  final VoidCallback? onCheck;
  final String resetLabel;
  final String checkLabel;

  const ChallengeBottomActions({
    super.key,
    required this.onReset,
    required this.onCheck,
    this.resetLabel = 'Reiniciar',
    this.checkLabel = 'Comprobar Respuesta',
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ChallengeOutlinedActionButton(
            label: resetLabel,
            iconAssetPath: AppAssets.retry,
            color: const Color(0xFF6B3DEB),
            onPressed: onReset,
            iconScale: 3.4,
            iconOffset: const Offset(0, 3),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: ChallengePrimaryActionButton(
            label: checkLabel,
            icon: Icons.check_circle_outline_rounded,
            backgroundColor: const Color(0xFF34AD4D),
            onPressed: onCheck,
          ),
        ),
      ],
    );
  }
}
