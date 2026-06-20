import 'package:algoquest/presentation/theme/app_assets.dart';
import 'package:flutter/material.dart';

enum LearningPathBottomNavItem { map, progress, leaderboard, profile }

class LearningPathBottomNav extends StatelessWidget {
  final LearningPathBottomNavItem selectedItem;
  final ValueChanged<LearningPathBottomNavItem>? onItemSelected;

  const LearningPathBottomNav({
    super.key,
    this.selectedItem = LearningPathBottomNavItem.map,
    this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 92,
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.97),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _BottomNavButton(
              item: LearningPathBottomNavItem.map,
              selectedItem: selectedItem,
              iconAssetPath: AppAssets.map,
              label: 'Mapa',
              iconScale: 2.55,
              onPressed: onItemSelected,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _BottomNavButton(
              item: LearningPathBottomNavItem.progress,
              selectedItem: selectedItem,
              iconAssetPath: AppAssets.statistics,
              label: 'Progreso',
              iconScale: 2.45,
              onPressed: onItemSelected,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _BottomNavButton(
              item: LearningPathBottomNavItem.leaderboard,
              selectedItem: selectedItem,
              iconAssetPath: AppAssets.cup,
              label: 'Clasificatoria',
              iconScale: 2.45,
              onPressed: onItemSelected,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _BottomNavButton(
              item: LearningPathBottomNavItem.profile,
              selectedItem: selectedItem,
              iconAssetPath: AppAssets.profile,
              label: 'Perfil',
              iconScale: 2.45,
              onPressed: onItemSelected,
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomNavButton extends StatelessWidget {
  final LearningPathBottomNavItem item;
  final LearningPathBottomNavItem selectedItem;
  final String iconAssetPath;
  final String label;
  final double iconScale;
  final ValueChanged<LearningPathBottomNavItem>? onPressed;

  const _BottomNavButton({
    required this.item,
    required this.selectedItem,
    required this.iconAssetPath,
    required this.label,
    required this.iconScale,
    required this.onPressed,
  });

  bool get _isSelected => item == selectedItem;

  @override
  Widget build(BuildContext context) {
    final textColor = _isSelected
        ? const Color(0xFF6B3DEB)
        : const Color(0xFF8D91A3);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed == null ? null : () => onPressed!(item),
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 34,
                height: 34,
                child: Transform.scale(
                  scale: iconScale,
                  child: _isSelected
                      ? Image.asset(iconAssetPath, fit: BoxFit.contain)
                      : ColorFiltered(
                          colorFilter: const ColorFilter.mode(
                            Color(0xFF8D91A3),
                            BlendMode.srcIn,
                          ),
                          child: Image.asset(
                            iconAssetPath,
                            fit: BoxFit.contain,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 5),
              SizedBox(
                width: double.infinity,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    maxLines: 1,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 12,
                      fontWeight: _isSelected
                          ? FontWeight.w900
                          : FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
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
