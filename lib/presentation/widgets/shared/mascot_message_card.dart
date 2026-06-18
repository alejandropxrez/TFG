import 'package:flutter/material.dart';

class MascotMessageCard extends StatelessWidget {
  final String imageAssetPath;
  final String title;
  final String message;
  final Color backgroundColor;
  final Color borderColor;
  final Color titleColor;
  final Color messageColor;
  final double imageBoxSize;
  final double imageScale;
  final Offset imageOffset;
  final EdgeInsetsGeometry padding;
  final double spacing;

  const MascotMessageCard({
    super.key,
    required this.imageAssetPath,
    required this.title,
    required this.message,
    this.backgroundColor = const Color(0xFFF0E7FF),
    this.borderColor = const Color(0xFFD9C4FF),
    this.titleColor = const Color(0xFF6B3DEB),
    this.messageColor = const Color(0xFF292B4A),
    this.imageBoxSize = 74,
    this.imageScale = 2.4,
    this.imageOffset = Offset.zero,
    this.padding = const EdgeInsets.fromLTRB(12, 10, 14, 10),
    this.spacing = 34,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Row(
        children: [
          SizedBox(
            width: imageBoxSize,
            height: imageBoxSize,
            child: Transform.translate(
              offset: imageOffset,
              child: Transform.scale(
                scale: imageScale,
                child: Image.asset(imageAssetPath, fit: BoxFit.contain),
              ),
            ),
          ),
          SizedBox(width: spacing),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: titleColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(
                    color: messageColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
