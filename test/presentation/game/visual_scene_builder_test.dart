import 'package:algoquest/domain/entities/challenge_spec.dart';
import 'package:algoquest/domain/entities/game_action.dart';
import 'package:algoquest/domain/entities/structure_state.dart';
import 'package:algoquest/domain/enums/structure_type.dart';
import 'package:algoquest/domain/strategies/validation_strategy.dart';
import 'package:algoquest/presentation/game/components/inventory_item_component.dart';
import 'package:algoquest/presentation/game/components/node_component.dart';
import 'package:algoquest/presentation/game/components/slot_component.dart';
import 'package:algoquest/presentation/game/strategies/interaction/set_value_interaction_strategy.dart';
import 'package:algoquest/presentation/game/visual_scene_builder.dart';
import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';

class AlwaysTrueValidationStrategy implements ValidationStrategy {
  @override
  bool isSolved(dynamic session) => true;
}

void main() {
  ChallengeSpec buildSpec() {
    return ChallengeSpec(
      id: 'set_value_test',
      title: 'Set Value',
      instruction: 'Fill the slot',
      theoryRef: null,
      constraints: const [],
      content: StructureChallengeContent(
        engineConfig: ChallengeEngineConfig(
          structureType: StructureType.heap,
          validationStrategy: AlwaysTrueValidationStrategy(),
          layoutStrategy: LayoutStrategyType.linear,
          interactionMode: InteractionModeType.setValue,
          connectionType: ConnectionType.none,
        ),
        initialState: const ChallengeInitialStateSpec(
          nodes: [ChallengeNodeSpec(id: 'n1', value: 10)],
          edges: [],
          slots: [ChallengeSlotSpec(id: 's1', index: 0)],
          inventory: [42],
        ),
      ),
    );
  }

  StructureState buildState() {
    return StructureState.fromNodesAndEdges(
      type: StructureType.heap,
      nodes: const [NodeState(id: 'n1', value: 10)],
      edges: const [],
      slots: const [SlotState(id: 's1', index: 0)],
      inventory: const [42],
    );
  }

  test('renders slot and inventory item components', () {
    final builder = const VisualSceneBuilder();
    final strategy = SetValueInteractionStrategy();

    final scene = builder.build(
      spec: buildSpec(),
      state: buildState(),
      canvasSize: Vector2(400, 300),
      interactionStrategy: strategy,
      onActionRequested: (GameAction action) {},
      onInteractionChanged: () {},
    );

    expect(scene.components.whereType<SlotComponent>().length, 1);

    expect(scene.components.whereType<InventoryItemComponent>().length, 1);
  });

  test('does not render filled slots', () {
    final builder = const VisualSceneBuilder();
    final strategy = SetValueInteractionStrategy();

    final state = StructureState.fromNodesAndEdges(
      type: StructureType.heap,
      nodes: const [NodeState(id: 'n1', value: 10)],
      edges: const [],
      slots: const [SlotState(id: 's1', index: 0, filledNodeId: 'n1')],
      inventory: const [42],
    );

    final scene = builder.build(
      spec: buildSpec(),
      state: state,
      canvasSize: Vector2(400, 300),
      interactionStrategy: strategy,
      onActionRequested: (GameAction action) {},
      onInteractionChanged: () {},
    );

    expect(scene.components.whereType<SlotComponent>(), isEmpty);
    expect(scene.components.whereType<InventoryItemComponent>().length, 1);
  });

  test(
    'renders filled slot as node component without rendering slot component',
    () {
      final builder = const VisualSceneBuilder();
      final strategy = SetValueInteractionStrategy();

      final state = StructureState.fromNodesAndEdges(
        type: StructureType.heap,
        nodes: const [NodeState(id: 'node_from_s1', value: 10)],
        edges: const [],
        slots: const [
          SlotState(id: 's1', index: 0, filledNodeId: 'node_from_s1'),
        ],
        inventory: const [],
      );

      final scene = builder.build(
        spec: buildSpec(),
        state: state,
        canvasSize: Vector2(400, 300),
        interactionStrategy: strategy,
        onActionRequested: (GameAction action) {},
        onInteractionChanged: () {},
      );

      expect(scene.components.whereType<SlotComponent>(), isEmpty);
      expect(scene.components.whereType<NodeComponent>().length, 1);
    },
  );
}
