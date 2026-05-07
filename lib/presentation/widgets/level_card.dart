import 'package:flutter/material.dart';

class LevelCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool locked;
  final VoidCallback? onTap;

  const LevelCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.locked,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        enabled: !locked,
        leading: Icon(locked ? Icons.lock : Icons.play_circle_fill),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: locked ? null : onTap,
      ),
    );
  }
}
