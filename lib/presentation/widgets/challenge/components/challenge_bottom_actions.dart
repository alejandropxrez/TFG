import 'package:algoquest/presentation/theme/app_assets.dart';
import 'package:algoquest/presentation/widgets/challenge/components/challenge_action_button.dart';
import 'package:algoquest/presentation/widgets/challenge/components/challenge_secondary_action_button.dart';
import 'package:flutter/material.dart';

class ChallengeBottomActions extends StatelessWidget {
  static const _resetColor = Color(0xFFE11D48);
  static const _undoColor = Color(0xFF6366F1);
  static const _redoColor = Color(0xFF14B8A6);

  final VoidCallback? onReset;
  final VoidCallback? onUndo;
  final VoidCallback? onRedo;
  final VoidCallback? onCheck;

  final String resetLabel;
  final String undoLabel;
  final String redoLabel;
  final String checkLabel;

  const ChallengeBottomActions({
    super.key,
    required this.onReset,
    required this.onUndo,
    required this.onRedo,
    required this.onCheck,
    this.resetLabel = 'Reiniciar',
    this.undoLabel = 'Deshacer',
    this.redoLabel = 'Rehacer',
    this.checkLabel = 'Comprobar Respuesta',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ChallengeSecondaryActionButton(
                label: resetLabel,
                iconAssetPath: AppAssets.retry,
                color: _resetColor,
                onPressed: onReset,
                assetIconScale: 3.4,
                assetIconOffset: const Offset(0, 3),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ChallengeSecondaryActionButton(
                label: undoLabel,
                iconAssetPath: AppAssets.directionArrow,
                color: _undoColor,
                onPressed: onUndo,
                iconSize: 18,
                assetIconScale: 2.5,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ChallengeSecondaryActionButton(
                label: redoLabel,
                iconAssetPath: AppAssets.directionArrow,
                mirrorAssetIcon: true,
                color: _redoColor,
                onPressed: onRedo,
                iconSize: 18,
                assetIconScale: 2.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
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
