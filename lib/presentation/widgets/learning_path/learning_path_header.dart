import 'package:algoquest/presentation/theme/app_assets.dart';
import 'package:flutter/material.dart';

class LearningPathHeader extends StatelessWidget {
  final String title;
  final int xp;

  const LearningPathHeader({super.key, required this.title, required this.xp});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 78,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        children: [
          Image.asset(AppAssets.fileIcon, width: 50, height: 50),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 27,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(width: 10),
          _XpPill(xp: xp),
        ],
      ),
    );
  }
}

class _XpPill extends StatelessWidget {
  final int xp;

  const _XpPill({required this.xp});

  @override
  Widget build(BuildContext context) {
    final formattedXp = _formatNumber(xp);

    return Container(
      height: 48,
      padding: const EdgeInsets.only(left: 10, right: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF3D267F).withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Transform.scale(
            scale: 2.2,
            child: SizedBox(
              width: 32,
              height: 32,
              child: Image.asset(AppAssets.star),
            ),
          ),
          const SizedBox(width: 7),
          Transform.translate(
            offset: const Offset(0, -2),
            child: Text(
              '$formattedXp XP',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int value) {
    final text = value.toString();
    final buffer = StringBuffer();

    for (var i = 0; i < text.length; i++) {
      final remaining = text.length - i;

      buffer.write(text[i]);

      if (remaining > 1 && remaining % 3 == 1) {
        buffer.write(',');
      }
    }

    return buffer.toString();
  }
}
