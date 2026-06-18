import 'package:flutter/material.dart';

class UnsupportedChallengeBody extends StatelessWidget {
  const UnsupportedChallengeBody({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Este tipo de reto todavía no tiene una vista implementada.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Color(0xFF101235),
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
