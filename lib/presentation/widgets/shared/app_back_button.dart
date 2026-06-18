import 'package:flutter/material.dart';

class AppBackButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Color foregroundColor;
  final Color backgroundColor;
  final double size;
  final double iconSize;
  final double borderRadius;

  const AppBackButton({
    super.key,
    required this.onPressed,
    this.foregroundColor = Colors.white,
    this.backgroundColor = const Color(0x24FFFFFF),
    this.size = 42,
    this.iconSize = 21,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          padding: EdgeInsets.zero,
          minimumSize: Size(size, size),
          fixedSize: Size(size, size),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
        child: Icon(
          Icons.arrow_back_rounded,
          color: foregroundColor,
          size: iconSize,
        ),
      ),
    );
  }
}
