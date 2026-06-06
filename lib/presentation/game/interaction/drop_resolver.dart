import 'package:flame/components.dart';

class DropResolver {
  const DropResolver();

  String? resolveSlot({
    required Vector2 dropPosition,
    required Map<String, Vector2> slotPositions,
    double radius = 36.0,
  }) {
    String? bestSlotId;
    double? bestDistance;

    for (final entry in slotPositions.entries) {
      final distance = dropPosition.distanceTo(entry.value);

      if (distance > radius) continue;

      if (bestDistance == null || distance < bestDistance) {
        bestSlotId = entry.key;
        bestDistance = distance;
      }
    }

    return bestSlotId;
  }
}
