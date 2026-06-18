import 'package:algoquest/presentation/theme/app_assets.dart';
import 'package:flutter/material.dart';

class ChallengeHeartsIndicator extends StatelessWidget {
  final int heartsLeft;
  final int maxHearts;
  final String? label;
  final Color labelColor;
  final double labelFontSize;
  final FontWeight labelFontWeight;
  final double heartSize;
  final double heartScale;
  final double spacing;
  final double labelSpacing;
  final double emptyOpacity;

  const ChallengeHeartsIndicator({
    super.key,
    required this.heartsLeft,
    this.maxHearts = 3,
    this.label,
    this.labelColor = const Color(0xFF1E2442),
    this.labelFontSize = 13,
    this.labelFontWeight = FontWeight.w800,
    this.heartSize = 22,
    this.heartScale = 1,
    this.spacing = 8,
    this.labelSpacing = 8,
    this.emptyOpacity = 0.25,
  });

  @override
  Widget build(BuildContext context) {
    final safeMaxHearts = maxHearts <= 0 ? 1 : maxHearts;
    final safeHeartsLeft = heartsLeft.clamp(0, safeMaxHearts);

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: TextStyle(
              color: labelColor,
              fontSize: labelFontSize,
              fontWeight: labelFontWeight,
            ),
          ),
          SizedBox(width: labelSpacing),
        ],
        for (var i = 0; i < safeMaxHearts; i++) ...[
          Transform.scale(
            scale: heartScale,
            child: _ColorFilteredHeart(
              filled: i < safeHeartsLeft,
              size: heartSize,
              emptyOpacity: emptyOpacity,
            ),
          ),
          if (i != safeMaxHearts - 1) SizedBox(width: spacing),
        ],
      ],
    );
  }
}

class _ColorFilteredHeart extends StatelessWidget {
  final bool filled;
  final double size;
  final double emptyOpacity;

  const _ColorFilteredHeart({
    required this.filled,
    required this.size,
    required this.emptyOpacity,
  });

  @override
  Widget build(BuildContext context) {
    final heart = Image.asset(
      AppAssets.heart,
      width: size,
      height: size,
      fit: BoxFit.contain,
    );

    if (filled) return heart;

    return ColorFiltered(
      colorFilter: const ColorFilter.matrix(<double>[
        0.2126,
        0.7152,
        0.0722,
        0,
        0,
        0.2126,
        0.7152,
        0.0722,
        0,
        0,
        0.2126,
        0.7152,
        0.0722,
        0,
        0,
        0,
        0,
        0,
        1,
        0,
      ]),
      child: Opacity(opacity: emptyOpacity, child: heart),
    );
  }
}
