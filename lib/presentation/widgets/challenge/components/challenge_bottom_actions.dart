import 'package:algoquest/presentation/theme/app_assets.dart';
import 'package:algoquest/presentation/widgets/challenge/components/challenge_action_button.dart';
import 'package:flutter/material.dart';

class ChallengeBottomActions extends StatelessWidget {
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
              child: ChallengeOutlinedActionButton(
                label: resetLabel,
                iconAssetPath: AppAssets.retry,
                color: const Color(0xFF6B3DEB),
                onPressed: onReset,
                iconScale: 3.4,
                iconOffset: const Offset(0, 3),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _HistoryActionButton(
                label: undoLabel,
                onPressed: onUndo,
                mirrorIcon: false,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _HistoryActionButton(
                label: redoLabel,
                onPressed: onRedo,
                mirrorIcon: true,
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

class _HistoryActionButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool mirrorIcon;

  const _HistoryActionButton({
    required this.label,
    required this.onPressed,
    required this.mirrorIcon,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final color = enabled ? const Color(0xFF6B3DEB) : const Color(0xFFB8AECF);

    return SizedBox(
      height: 52,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color, width: 1.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Transform.scale(
              scale: 3,
              child: Transform.scale(
                scaleX: mirrorIcon ? -1 : 1,
                child: Image.asset(
                  AppAssets.directionArrow,
                  width: 20,
                  height: 20,
                  color: color,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
