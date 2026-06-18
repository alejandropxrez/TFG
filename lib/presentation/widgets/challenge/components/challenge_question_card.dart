import 'package:algoquest/presentation/theme/app_assets.dart';
import 'package:flutter/material.dart';

class ChallengeQuestionCard extends StatelessWidget {
  final String title;
  final String instruction;
  final String imageAssetPath;
  final String leadingIconAssetPath;
  final double imageScale;
  final Offset imageOffset;

  const ChallengeQuestionCard({
    super.key,
    required this.title,
    required this.instruction,
    required this.imageAssetPath,
    this.leadingIconAssetPath = AppAssets.lightBulb,
    this.imageScale = 1.45,
    this.imageOffset = const Offset(4, -2),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 96,
      padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF0),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFE2A8), width: 1.3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _QuestionLabel(
                    title: title,
                    iconAssetPath: leadingIconAssetPath,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    instruction,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF101235),
                      fontSize: 14,
                      fontWeight: FontWeight(600),
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            width: 82,
            height: 82,
            child: Transform.translate(
              offset: imageOffset,
              child: Transform.scale(
                scale: imageScale,
                child: Image.asset(imageAssetPath, fit: BoxFit.contain),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestionLabel extends StatelessWidget {
  final String title;
  final String iconAssetPath;

  const _QuestionLabel({required this.title, required this.iconAssetPath});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 22,
          height: 22,
          child: Transform.scale(
            scale: 3.5,
            child: Image.asset(iconAssetPath, fit: BoxFit.contain),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF6B3DEB),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
