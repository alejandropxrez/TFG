import 'package:flutter/material.dart';

class ChallengeSecondaryActionButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color color;
  final String? iconAssetPath;
  final IconData? icon;
  final bool mirrorAssetIcon;
  final double height;
  final double borderRadius;
  final double borderWidth;
  final double iconSize;
  final double assetIconScale;
  final Offset assetIconOffset;

  const ChallengeSecondaryActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    required this.color,
    this.iconAssetPath,
    this.icon,
    this.mirrorAssetIcon = false,
    this.height = 52,
    this.borderRadius = 14,
    this.borderWidth = 1.4,
    this.iconSize = 18,
    this.assetIconScale = 1,
    this.assetIconOffset = Offset.zero,
  }) : assert(
         iconAssetPath != null || icon != null,
         'Provide either iconAssetPath or icon.',
       );

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final effectiveColor = enabled ? color : const Color(0xFFB8AECF);

    return SizedBox(
      height: height,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: effectiveColor,
          disabledForegroundColor: effectiveColor,
          side: BorderSide(color: effectiveColor, width: borderWidth),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          backgroundColor: Colors.white,
          disabledBackgroundColor: Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _ActionIcon(
              iconAssetPath: iconAssetPath,
              icon: icon,
              color: effectiveColor,
              mirrorAssetIcon: mirrorAssetIcon,
              iconSize: iconSize,
              assetIconScale: assetIconScale,
              assetIconOffset: assetIconOffset,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionIcon extends StatelessWidget {
  final String? iconAssetPath;
  final IconData? icon;
  final Color color;
  final bool mirrorAssetIcon;
  final double iconSize;
  final double assetIconScale;
  final Offset assetIconOffset;

  const _ActionIcon({
    required this.iconAssetPath,
    required this.icon,
    required this.color,
    required this.mirrorAssetIcon,
    required this.iconSize,
    required this.assetIconScale,
    required this.assetIconOffset,
  });

  @override
  Widget build(BuildContext context) {
    if (icon != null) {
      return Icon(icon, size: iconSize, color: color);
    }

    Widget image = Image.asset(
      iconAssetPath!,
      width: iconSize,
      height: iconSize,
      color: color,
      fit: BoxFit.contain,
    );

    image = Transform.translate(
      offset: assetIconOffset,
      child: Transform.scale(scale: assetIconScale, child: image),
    );

    if (mirrorAssetIcon) {
      image = Transform.scale(scaleX: -1, child: image);
    }

    return image;
  }
}
