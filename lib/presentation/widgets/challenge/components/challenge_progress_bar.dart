import 'package:algoquest/presentation/theme/app_assets.dart';
import 'package:flutter/material.dart';

class ChallengeProgressBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final double height;

  const ChallengeProgressBar({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.height = 28,
  });

  @override
  Widget build(BuildContext context) {
    final safeTotalSteps = totalSteps <= 0 ? 1 : totalSteps;
    final safeCurrentStep = currentStep.clamp(0, safeTotalSteps);

    return SizedBox(
      height: height,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final trackHeight = height * 0.4;
          final starSize = height * 0.78;

          final progress = safeTotalSteps <= 1
              ? 1.0
              : safeCurrentStep / safeTotalSteps;

          return Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.centerLeft,
            children: [
              Positioned(
                left: starSize / 2,
                right: starSize / 2,
                child: _ProgressTrack(height: trackHeight, progress: progress),
              ),
              for (var index = 0; index < safeTotalSteps; index++)
                _ProgressStar(
                  index: index,
                  totalSteps: safeTotalSteps,
                  currentStep: safeCurrentStep,
                  width: width,
                  size: starSize,
                ),
            ],
          );
        },
      ),
    );
  }
}

class _ProgressTrack extends StatelessWidget {
  final double height;
  final double progress;

  const _ProgressTrack({required this.height, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFEDEAF8),
        borderRadius: BorderRadius.circular(999),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress.clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF6B3DEB),
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ),
    );
  }
}

class _ProgressStar extends StatelessWidget {
  final int index;
  final int totalSteps;
  final int currentStep;
  final double width;
  final double size;

  const _ProgressStar({
    required this.index,
    required this.totalSteps,
    required this.currentStep,
    required this.width,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final position = totalSteps <= 1 ? 0.0 : index / (totalSteps - 1);
    final left = (width - size) * position;

    final isActive = index < currentStep;

    return Positioned(
      left: left,
      child: SizedBox(
        width: size,
        height: size,
        child: Transform.scale(
          scale: isActive ? 1.12 : 1.0,
          child: _ProgressStarImage(active: isActive),
        ),
      ),
    );
  }
}

class _ProgressStarImage extends StatelessWidget {
  final bool active;

  const _ProgressStarImage({required this.active});

  @override
  Widget build(BuildContext context) {
    final star = Transform.scale(
      scale: 3,
      child: Image.asset(AppAssets.star, fit: BoxFit.contain),
    );

    if (active) return star;

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
      child: Opacity(opacity: 0.34, child: star),
    );
  }
}
