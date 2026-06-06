import 'package:algoquest/presentation/game/interaction/drop_resolver.dart';
import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('resolves slot when drop position is within radius', () {
    const resolver = DropResolver();

    final slotId = resolver.resolveSlot(
      dropPosition: Vector2(105, 100),
      slotPositions: {'s1': Vector2(100, 100)},
      radius: 10,
    );

    expect(slotId, 's1');
  });

  test('returns null when drop position is outside radius', () {
    const resolver = DropResolver();

    final slotId = resolver.resolveSlot(
      dropPosition: Vector2(150, 100),
      slotPositions: {'s1': Vector2(100, 100)},
      radius: 10,
    );

    expect(slotId, isNull);
  });

  test('returns nearest matching slot when multiple slots are in range', () {
    const resolver = DropResolver();

    final slotId = resolver.resolveSlot(
      dropPosition: Vector2(103, 100),
      slotPositions: {'s1': Vector2(100, 100), 's2': Vector2(108, 100)},
      radius: 10,
    );

    expect(slotId, 's1');
  });
}
