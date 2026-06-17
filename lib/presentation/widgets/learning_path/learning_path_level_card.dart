import 'package:algoquest/presentation/theme/app_assets.dart';
import 'package:flutter/material.dart';

enum LearningPathLevelCardStatus { available, completed, locked }

class LearningPathLevelCard extends StatelessWidget {
  final int number;
  final String title;
  final String subtitle;
  final int xp;
  final LearningPathLevelCardStatus status;
  final String imageAssetPath;
  final VoidCallback? onPressed;

  const LearningPathLevelCard({
    super.key,
    required this.number,
    required this.title,
    required this.subtitle,
    required this.xp,
    required this.status,
    required this.imageAssetPath,
    required this.onPressed,
  });

  bool get _locked => status == LearningPathLevelCardStatus.locked;

  bool get _completed => status == LearningPathLevelCardStatus.completed;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 360;

        return Padding(
          padding: const EdgeInsets.only(left: 34, right: 8, bottom: 18),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Opacity(
                opacity: _locked ? 0.68 : 1,
                child: Container(
                  constraints: const BoxConstraints(minHeight: 132),
                  padding: EdgeInsets.fromLTRB(
                    isCompact ? 18 : 22,
                    16,
                    isCompact ? 14 : 18,
                    16,
                  ),
                  decoration: BoxDecoration(
                    color: _locked
                        ? const Color(0xFFE5E5EC)
                        : Colors.white.withValues(alpha: 0.97),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: _locked
                          ? const Color(0xFFB8BAC6)
                          : const Color(0xFF6B3DEB),
                      width: 1.8,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.14),
                        blurRadius: 18,
                        offset: const Offset(0, 9),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      _LevelArtwork(
                        imageAssetPath: imageAssetPath,
                        locked: _locked,
                        size: isCompact ? 70 : 84,
                      ),
                      SizedBox(width: isCompact ? 12 : 16),
                      Expanded(
                        child: _LevelTextContent(
                          title: title,
                          subtitle: subtitle,
                          xp: xp,
                          locked: _locked,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _LevelActionButton(
                        locked: _locked,
                        completed: _completed,
                        compact: isCompact,
                        onPressed: onPressed,
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: -24,
                top: 42,
                child: _LevelNumberBadge(
                  number: number,
                  locked: _locked,
                  completed: _completed,
                ),
              ),
              if (_completed)
                const Positioned(right: -8, top: -8, child: _CompletedBadge()),
            ],
          ),
        );
      },
    );
  }
}

class _LevelArtwork extends StatelessWidget {
  final String imageAssetPath;
  final bool locked;
  final double size;

  const _LevelArtwork({
    required this.imageAssetPath,
    required this.locked,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final image = Transform.scale(
      scale: 1.5,
      child: Image.asset(imageAssetPath, fit: BoxFit.contain),
    );

    return SizedBox(
      width: size,
      height: size,
      child: locked
          ? ColorFiltered(
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
              child: image,
            )
          : image,
    );
  }
}

class _LevelTextContent extends StatelessWidget {
  final String title;
  final String subtitle;
  final int xp;
  final bool locked;

  const _LevelTextContent({
    required this.title,
    required this.subtitle,
    required this.xp,
    required this.locked,
  });

  @override
  Widget build(BuildContext context) {
    final titleColor = locked
        ? const Color(0xFF5F6270)
        : const Color(0xFF101235);

    final bodyColor = locked
        ? const Color(0xFF727483)
        : const Color(0xFF292B4A);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: titleColor,
            fontSize: 16,
            fontWeight: FontWeight.w900,
            height: 1.08,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          subtitle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: bodyColor,
            fontSize: 13,
            fontWeight: FontWeight.w500,
            height: 1.24,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Transform.translate(
              offset: Offset(0, 2),
              child: Transform.scale(
                scale: 3,
                child: Image.asset(AppAssets.star, width: 18, height: 18),
              ),
            ),

            const SizedBox(width: 5),
            Text(
              'XP $xp',
              style: TextStyle(
                color: titleColor,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _LevelActionButton extends StatelessWidget {
  final bool locked;
  final bool completed;
  final bool compact;
  final VoidCallback? onPressed;

  const _LevelActionButton({
    required this.locked,
    required this.completed,
    required this.compact,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final text = locked
        ? 'Locked'
        : completed
        ? 'Replay'
        : "Let's go!";

    final color = locked
        ? const Color(0xFF777A86)
        : completed
        ? const Color(0xFF32A852)
        : const Color(0xFF6B3DEB);

    return FilledButton(
      onPressed: locked ? null : onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: color,
        disabledBackgroundColor: const Color(0xFF777A86),
        foregroundColor: Colors.white,
        disabledForegroundColor: Colors.white,
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 9 : 12,
          vertical: 10,
        ),
        minimumSize: Size(compact ? 78 : 96, 40),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
      ),
      child: locked
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Transform.scale(
                  scale: 1.45,
                  child: SizedBox(
                    width: compact ? 14 : 16,
                    height: compact ? 14 : 16,
                    child: Transform.scale(
                      scale: 2,
                      child: ColorFiltered(
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
                        child: Image.asset(
                          AppAssets.padlock,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: compact ? 11 : 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            )
          : Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: compact ? 11 : 13,
                fontWeight: FontWeight.w900,
              ),
            ),
    );
  }
}

class _LevelNumberBadge extends StatelessWidget {
  final int number;
  final bool locked;
  final bool completed;

  const _LevelNumberBadge({
    required this.number,
    required this.locked,
    required this.completed,
  });

  @override
  Widget build(BuildContext context) {
    final color = locked
        ? const Color(0xFF9A9CA8)
        : completed
        ? const Color(0xFF2EAD4F)
        : const Color(0xFF6B3DEB);

    return Container(
      width: 46,
      height: 46,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.20),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Text(
        '$number',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _CompletedBadge extends StatelessWidget {
  const _CompletedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: const Color(0xFF36B44A),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Icon(Icons.check_rounded, color: Colors.white, size: 23),
    );
  }
}
