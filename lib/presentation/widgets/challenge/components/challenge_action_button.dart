import 'package:flutter/material.dart';

class ChallengePrimaryActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color backgroundColor;
  final VoidCallback? onPressed;

  const ChallengePrimaryActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 6,
          shadowColor: backgroundColor.withValues(alpha: 0.35),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 10),
              Icon(icon, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}

class ChallengeOutlinedActionButton extends StatelessWidget {
  final String label;
  final String iconAssetPath;
  final Color color;
  final VoidCallback? onPressed;
  final double iconScale;
  final Offset iconOffset;

  const ChallengeOutlinedActionButton({
    super.key,
    required this.label,
    required this.iconAssetPath,
    required this.color,
    required this.onPressed,
    this.iconScale = 4,
    this.iconOffset = const Offset(0, 4),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 6),
              SizedBox(
                width: 20,
                height: 20,
                child: Transform.translate(
                  offset: iconOffset,
                  child: Transform.scale(
                    scale: iconScale,
                    child: Image.asset(iconAssetPath, fit: BoxFit.contain),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
