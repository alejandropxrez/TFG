import 'package:algoquest/domain/entities/structure_state.dart';
import 'package:algoquest/domain/enums/structure_type.dart';
import 'package:algoquest/presentation/widgets/challenge/components/linked_list_slots_challenge_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LinkedListSlotsChallengeBody', () {
    testWidgets('renders slots ordered by index', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 420,
              child: LinkedListSlotsChallengeBody(
                structure: _structureWithUnorderedSlots(),
                onValueDropped: ({required slotId, required value}) {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('Tu lista'), findsOneWidget);
      expect(find.text('Inventario'), findsOneWidget);

      final firstSlot = tester.getTopLeft(
        find.byKey(const ValueKey('slot_s1')),
      );
      final secondSlot = tester.getTopLeft(
        find.byKey(const ValueKey('slot_s2')),
      );
      final thirdSlot = tester.getTopLeft(
        find.byKey(const ValueKey('slot_s3')),
      );

      expect(firstSlot.dx, lessThan(secondSlot.dx));
      expect(secondSlot.dx, lessThan(thirdSlot.dx));
    });

    testWidgets('renders inventory values', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 420,
              child: LinkedListSlotsChallengeBody(
                structure: _structureWithUnorderedSlots(),
                onValueDropped: ({required slotId, required value}) {},
              ),
            ),
          ),
        ),
      );

      expect(find.byKey(const ValueKey('inventory_8')), findsOneWidget);
      expect(find.byKey(const ValueKey('inventory_2')), findsOneWidget);
      expect(find.byKey(const ValueKey('inventory_6')), findsOneWidget);
      expect(find.byKey(const ValueKey('inventory_4')), findsOneWidget);
    });

    testWidgets('shows filled slot value from filledNodeId', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 420,
              child: LinkedListSlotsChallengeBody(
                structure: _structureWithFilledSlot(),
                onValueDropped: ({required slotId, required value}) {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('2'), findsWidgets);
      expect(find.byKey(const ValueKey('slot_s1')), findsOneWidget);
    });

    testWidgets('dragging inventory value to empty slot calls onValueDropped', (
      tester,
    ) async {
      String? droppedSlotId;
      int? droppedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 420,
              child: LinkedListSlotsChallengeBody(
                structure: _structureWithUnorderedSlots(),
                onValueDropped: ({required slotId, required value}) {
                  droppedSlotId = slotId;
                  droppedValue = value;
                },
              ),
            ),
          ),
        ),
      );

      await tester.drag(
        find.byKey(const ValueKey('inventory_2')),
        tester.getCenter(find.byKey(const ValueKey('slot_s1'))) -
            tester.getCenter(find.byKey(const ValueKey('inventory_2'))),
      );
      await tester.pumpAndSettle();

      expect(droppedSlotId, 's1');
      expect(droppedValue, 2);
    });

    testWidgets('does not accept drops on an already filled slot', (
      tester,
    ) async {
      String? droppedSlotId;
      int? droppedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 420,
              child: LinkedListSlotsChallengeBody(
                structure: _structureWithFilledSlot(),
                onValueDropped: ({required slotId, required value}) {
                  droppedSlotId = slotId;
                  droppedValue = value;
                },
              ),
            ),
          ),
        ),
      );

      await tester.drag(
        find.byKey(const ValueKey('inventory_4')),
        tester.getCenter(find.byKey(const ValueKey('slot_s1'))) -
            tester.getCenter(find.byKey(const ValueKey('inventory_4'))),
      );
      await tester.pumpAndSettle();

      expect(droppedSlotId, isNull);
      expect(droppedValue, isNull);
    });
  });
}

StructureState _structureWithUnorderedSlots() {
  return StructureState.fromNodesAndEdges(
    type: StructureType.linkedList,
    nodes: const [
      NodeState(id: 'n2', value: 2),
      NodeState(id: 'n4', value: 4),
      NodeState(id: 'n6', value: 6),
      NodeState(id: 'n8', value: 8),
    ],
    edges: const [],
    slots: const [
      SlotState(id: 's3', index: 2),
      SlotState(id: 's1', index: 0),
      SlotState(id: 's2', index: 1),
    ],
    inventory: const [8, 2, 6, 4],
  );
}

StructureState _structureWithFilledSlot() {
  return StructureState.fromNodesAndEdges(
    type: StructureType.linkedList,
    nodes: const [
      NodeState(id: 'n2', value: 2),
      NodeState(id: 'n4', value: 4),
    ],
    edges: const [],
    slots: const [
      SlotState(id: 's1', index: 0, filledNodeId: 'n2'),
      SlotState(id: 's2', index: 1),
    ],
    inventory: const [4],
  );
}
