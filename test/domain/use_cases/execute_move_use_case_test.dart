import 'package:algoquest/domain/entities/structure_state.dart';
import 'package:algoquest/domain/strategies/max_heap_validation_strategy.dart';
import 'package:algoquest/domain/usecases/execute_move_use_case.dart';
import 'package:algoquest/domain/usecases/undo_move_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:algoquest/domain/entities/challenge_session.dart';
import 'package:algoquest/domain/entities/challenge_spec.dart';
import 'package:algoquest/domain/entities/game_action.dart';
import 'package:algoquest/domain/enums/session_status.dart';
import 'package:algoquest/domain/enums/structure_type.dart';

void main() {
  late ExecuteMoveUseCase useCase;

  setUp(() {
    useCase = const ExecuteMoveUseCase();
  });

  ChallengeSpec buildSwapSpec({
    List<ChallengeConstraint> constraints = const [],
    InteractionModeType interactionMode = InteractionModeType.swap,
  }) {
    return ChallengeSpec(
      id: 'challenge_1',
      title: 'Heap Repair',
      instruction: 'Swap nodes to fix the heap',
      theoryRef: null,
      constraints: constraints,
      content: StructureChallengeContent(
        engineConfig: ChallengeEngineConfig(
          structureType: StructureType.heap,
          validationStrategy: MaxHeapValidationStrategy(),
          layoutStrategy: LayoutStrategyType.pyramid,
          connectionType: ConnectionType.explicit,
          interactionMode: interactionMode,
        ),
        initialState: const ChallengeInitialStateSpec(
          nodes: [
            ChallengeNodeSpec(id: 'n1', value: 3),
            ChallengeNodeSpec(id: 'n2', value: 10),
          ],
          edges: [ChallengeEdgeSpec(source: 'n1', target: 'n2')],
          slots: [],
          inventory: [],
        ),
      ),
    );
  }

  ChallengeSpec buildSetValueSpec({
    List<ChallengeConstraint> constraints = const [],
  }) {
    return ChallengeSpec(
      id: 'challenge_1',
      title: 'Fill blank',
      instruction: 'Assign a value to the empty slot',
      theoryRef: null,
      constraints: constraints,
      content: StructureChallengeContent(
        engineConfig: ChallengeEngineConfig(
          structureType: StructureType.heap,
          validationStrategy: MaxHeapValidationStrategy(),
          layoutStrategy: LayoutStrategyType.pyramid,
          interactionMode: InteractionModeType.setValue,
          connectionType: ConnectionType.explicit,
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

  ChallengeSpec buildLinkSpec({
    List<ChallengeConstraint> constraints = const [],
  }) {
    return ChallengeSpec(
      id: 'challenge_link',
      title: 'Link nodes',
      instruction: 'Connect two nodes',
      theoryRef: null,
      constraints: constraints,
      content: StructureChallengeContent(
        engineConfig: ChallengeEngineConfig(
          structureType: StructureType.graph,
          validationStrategy: MaxHeapValidationStrategy(),
          layoutStrategy: LayoutStrategyType.linear,
          interactionMode: InteractionModeType.link,
          connectionType: ConnectionType.explicit,
        ),
        initialState: const ChallengeInitialStateSpec(
          nodes: [
            ChallengeNodeSpec(id: 'n1', value: 1),
            ChallengeNodeSpec(id: 'n2', value: 2),
            ChallengeNodeSpec(id: 'n3', value: 3),
          ],
          edges: [ChallengeEdgeSpec(source: 'n1', target: 'n2')],
          slots: [],
          inventory: [],
        ),
      ),
    );
  }

  test('applies valid SwapNodesAction and updates session metadata', () {
    final spec = buildSwapSpec();

    final session = ChallengeSession.start(
      sessionId: 'session_1',
      userId: 'user_1',
      spec: spec,
    );

    final updated = useCase(
      session: session,
      action: const SwapNodesAction(firstNodeId: 'n1', secondNodeId: 'n2'),
    );

    expect(updated.structureRuntimeState.movesUsed, 1);
    expect(updated.structureRuntimeState.history.length, 1);
    expect(updated.status, SessionStatus.inProgress);
    expect(
      updated.updatedAt.isAfter(session.updatedAt) ||
          updated.updatedAt.isAtSameMomentAs(session.updatedAt),
      isTrue,
    );

    expect(updated.structureRuntimeState.structure.nodes['n1']!.value, 10);
    expect(updated.structureRuntimeState.structure.nodes['n2']!.value, 3);
  });

  test('does not change session when action is not applicable', () {
    final spec = buildSwapSpec();

    final session = ChallengeSession.start(
      sessionId: 'session_1',
      userId: 'user_1',
      spec: spec,
    );

    final updated = useCase(
      session: session,
      action: const SwapNodesAction(
        firstNodeId: 'n1',
        secondNodeId: 'unknown_node',
      ),
    );

    expect(updated.structureRuntimeState.structure.nodes['n1']!.value, 3);
    expect(updated.structureRuntimeState.structure.nodes['n2']!.value, 10);
    expect(updated.structureRuntimeState.movesUsed, 0);
    expect(updated.structureRuntimeState.history, isEmpty);
  });

  test('does not execute action when MaxMovesConstraint is reached', () {
    final spec = buildSwapSpec(constraints: const [MaxMovesConstraint(0)]);

    final session = ChallengeSession.start(
      sessionId: 'session_1',
      userId: 'user_1',
      spec: spec,
    );

    final updated = useCase(
      session: session,
      action: const SwapNodesAction(firstNodeId: 'n1', secondNodeId: 'n2'),
    );

    expect(updated.structureRuntimeState.movesUsed, 0);
    expect(updated.structureRuntimeState.history, isEmpty);
    expect(updated.structureRuntimeState.structure.nodes['n1']!.value, 3);
    expect(updated.structureRuntimeState.structure.nodes['n2']!.value, 10);
  });

  test('does not execute SwapNodesAction on locked nodes', () {
    final spec = buildSwapSpec(
      constraints: const [
        LockedNodesConstraint(['n1']),
      ],
    );

    final session = ChallengeSession.start(
      sessionId: 'session_1',
      userId: 'user_1',
      spec: spec,
    );

    final updated = useCase(
      session: session,
      action: const SwapNodesAction(firstNodeId: 'n1', secondNodeId: 'n2'),
    );

    expect(updated.structureRuntimeState.movesUsed, 0);
    expect(updated.structureRuntimeState.history, isEmpty);
    expect(updated.structureRuntimeState.structure.nodes['n1']!.value, 3);
    expect(updated.structureRuntimeState.structure.nodes['n2']!.value, 10);
  });

  test('executes SetValueAction on unlocked slot', () {
    final spec = buildSetValueSpec();

    final session = ChallengeSession.start(
      sessionId: 'session_1',
      userId: 'user_1',
      spec: spec,
    );

    final updated = useCase(
      session: session,
      action: const SetValueAction(slotId: 's1', value: 42),
    );

    expect(updated.structureRuntimeState.movesUsed, 1);
    expect(updated.structureRuntimeState.history.length, 1);
    expect(
      updated.structureRuntimeState.structure.slots['s1']!.filledNodeId,
      isNotNull,
    );
    expect(
      updated.structureRuntimeState.structure.inventory.contains(42),
      isFalse,
    );

    final createdNodeId =
        updated.structureRuntimeState.structure.slots['s1']!.filledNodeId!;
    expect(
      updated.structureRuntimeState.structure.nodes[createdNodeId]!.value,
      42,
    );
  });

  test('does not execute SetValueAction on locked slot', () {
    final spec = buildSetValueSpec(
      constraints: const [
        LockedNodesConstraint(['s1']),
      ],
    );

    final session = ChallengeSession.start(
      sessionId: 'session_1',
      userId: 'user_1',
      spec: spec,
    );

    final updated = useCase(
      session: session,
      action: const SetValueAction(slotId: 's1', value: 42),
    );

    expect(updated.structureRuntimeState.movesUsed, 0);
    expect(updated.structureRuntimeState.history, isEmpty);
    expect(
      updated.structureRuntimeState.structure.slots['s1']!.filledNodeId,
      isNull,
    );
    expect(
      updated.structureRuntimeState.structure.inventory.contains(42),
      isTrue,
    );
  });

  test('does not execute SetValueAction if slot is already filled', () {
    final spec = ChallengeSpec(
      id: 'challenge_1',
      title: 'Filled slot',
      instruction: 'Cannot overwrite slot',
      theoryRef: null,
      constraints: const [],
      content: StructureChallengeContent(
        engineConfig: ChallengeEngineConfig(
          structureType: StructureType.heap,
          validationStrategy: MaxHeapValidationStrategy(),
          layoutStrategy: LayoutStrategyType.pyramid,
          interactionMode: InteractionModeType.setValue,
          connectionType: ConnectionType.explicit,
        ),
        initialState: const ChallengeInitialStateSpec(
          nodes: [ChallengeNodeSpec(id: 'n1', value: 10)],
          edges: [],
          slots: [ChallengeSlotSpec(id: 's1', index: 0)],
          inventory: [42],
        ),
      ),
    );

    final initialSession = ChallengeSession.start(
      sessionId: 'session_1',
      userId: 'user_1',
      spec: spec,
    );

    final structureRuntimeState = initialSession.structureRuntimeState;

    final session = initialSession.copyWith(
      runtimeState: structureRuntimeState.copyWith(
        structure: structureRuntimeState.structure.copyWith(
          slots: {
            's1': const SlotState(id: 's1', index: 0, filledNodeId: 'n1'),
          },
        ),
      ),
    );

    final updated = useCase(
      session: session,
      action: const SetValueAction(slotId: 's1', value: 42),
    );

    expect(updated.structureRuntimeState.movesUsed, 0);
    expect(updated.structureRuntimeState.history, isEmpty);
    expect(
      updated.structureRuntimeState.structure.slots['s1']!.filledNodeId,
      'n1',
    );
    expect(
      updated.structureRuntimeState.structure.inventory.contains(42),
      isTrue,
    );
  });

  test('does not execute SetValueAction if value is not in inventory', () {
    final spec = ChallengeSpec(
      id: 'challenge_1',
      title: 'Wrong inventory',
      instruction: 'Value missing from inventory',
      theoryRef: null,
      constraints: const [],
      content: StructureChallengeContent(
        engineConfig: ChallengeEngineConfig(
          structureType: StructureType.heap,
          validationStrategy: MaxHeapValidationStrategy(),
          layoutStrategy: LayoutStrategyType.pyramid,
          interactionMode: InteractionModeType.setValue,
          connectionType: ConnectionType.explicit,
        ),
        initialState: const ChallengeInitialStateSpec(
          nodes: [ChallengeNodeSpec(id: 'n1', value: 10)],
          edges: [],
          slots: [ChallengeSlotSpec(id: 's1', index: 0)],
          inventory: [7],
        ),
      ),
    );

    final session = ChallengeSession.start(
      sessionId: 'session_1',
      userId: 'user_1',
      spec: spec,
    );

    final updated = useCase(
      session: session,
      action: const SetValueAction(slotId: 's1', value: 42),
    );

    expect(updated.structureRuntimeState.movesUsed, 0);
    expect(updated.structureRuntimeState.history, isEmpty);
    expect(
      updated.structureRuntimeState.structure.slots['s1']!.filledNodeId,
      isNull,
    );
    expect(updated.structureRuntimeState.structure.inventory, [7]);
  });

  test('does not execute SetValueAction in swap interaction mode', () {
    final spec = buildSwapSpec();

    final session = ChallengeSession.start(
      sessionId: 'session_1',
      userId: 'user_1',
      spec: spec,
    );

    final updated = useCase(
      session: session,
      action: const SetValueAction(slotId: 'n1', value: 42),
    );

    expect(updated.structureRuntimeState.movesUsed, 0);
    expect(updated.structureRuntimeState.history, isEmpty);
    expect(updated.structureRuntimeState.structure.nodes['n1']!.value, 3);
    expect(updated.structureRuntimeState.structure.nodes['n2']!.value, 10);
  });

  test('does not execute SwapNodesAction in setValue interaction mode', () {
    final spec = buildSetValueSpec();

    final session = ChallengeSession.start(
      sessionId: 'session_1',
      userId: 'user_1',
      spec: spec,
    );

    final updated = useCase(
      session: session,
      action: const SwapNodesAction(firstNodeId: 'n1', secondNodeId: 's1'),
    );

    expect(updated.structureRuntimeState.movesUsed, 0);
    expect(updated.structureRuntimeState.history, isEmpty);
    expect(updated.structureRuntimeState.structure.nodes['n1']!.value, 10);
    expect(
      updated.structureRuntimeState.structure.slots['s1']!.filledNodeId,
      isNull,
    );
    expect(updated.structureRuntimeState.structure.inventory, [42]);
  });

  test('does not execute SwapNodesAction in drag interaction mode', () {
    final spec = buildSwapSpec(interactionMode: InteractionModeType.drag);

    final session = ChallengeSession.start(
      sessionId: 'session_1',
      userId: 'user_1',
      spec: spec,
    );

    final updated = useCase(
      session: session,
      action: const SwapNodesAction(firstNodeId: 'n1', secondNodeId: 'n2'),
    );

    expect(updated.structureRuntimeState.movesUsed, 0);
    expect(updated.structureRuntimeState.history, isEmpty);
    expect(updated.structureRuntimeState.structure.nodes['n1']!.value, 3);
    expect(updated.structureRuntimeState.structure.nodes['n2']!.value, 10);
  });

  test('executes LinkAction and adds a new edge in link interaction mode', () {
    final spec = buildLinkSpec();

    final session = ChallengeSession.start(
      sessionId: 'session_1',
      userId: 'user_1',
      spec: spec,
    );

    final updated = useCase(
      session: session,
      action: const LinkAction(sourceNodeId: 'n2', targetNodeId: 'n3'),
    );

    expect(updated.structureRuntimeState.movesUsed, 1);
    expect(updated.structureRuntimeState.history.length, 1);
    expect(
      updated.structureRuntimeState.structure.edges.any(
        (edge) => edge.source == 'n2' && edge.target == 'n3',
      ),
      isTrue,
    );
  });

  test('does not execute LinkAction when edge already exists', () {
    final spec = buildLinkSpec();

    final session = ChallengeSession.start(
      sessionId: 'session_1',
      userId: 'user_1',
      spec: spec,
    );

    final updated = useCase(
      session: session,
      action: const LinkAction(sourceNodeId: 'n1', targetNodeId: 'n2'),
    );

    expect(updated.structureRuntimeState.movesUsed, 0);
    expect(updated.structureRuntimeState.history, isEmpty);
    expect(updated.structureRuntimeState.structure.edges.length, 1);
  });

  test('does not execute LinkAction when linking node to itself', () {
    final spec = buildLinkSpec();

    final session = ChallengeSession.start(
      sessionId: 'session_1',
      userId: 'user_1',
      spec: spec,
    );

    final updated = useCase(
      session: session,
      action: const LinkAction(sourceNodeId: 'n1', targetNodeId: 'n1'),
    );

    expect(updated.structureRuntimeState.movesUsed, 0);
    expect(updated.structureRuntimeState.history, isEmpty);
    expect(updated.structureRuntimeState.structure.edges.length, 1);
  });

  test('does not execute LinkAction when source node does not exist', () {
    final spec = buildLinkSpec();

    final session = ChallengeSession.start(
      sessionId: 'session_1',
      userId: 'user_1',
      spec: spec,
    );

    final updated = useCase(
      session: session,
      action: const LinkAction(sourceNodeId: 'missing', targetNodeId: 'n2'),
    );

    expect(updated.structureRuntimeState.movesUsed, 0);
    expect(updated.structureRuntimeState.history, isEmpty);
    expect(updated.structureRuntimeState.structure.edges.length, 1);
  });

  test('does not execute LinkAction when target node does not exist', () {
    final spec = buildLinkSpec();

    final session = ChallengeSession.start(
      sessionId: 'session_1',
      userId: 'user_1',
      spec: spec,
    );

    final updated = useCase(
      session: session,
      action: const LinkAction(sourceNodeId: 'n1', targetNodeId: 'missing'),
    );

    expect(updated.structureRuntimeState.movesUsed, 0);
    expect(updated.structureRuntimeState.history, isEmpty);
    expect(updated.structureRuntimeState.structure.edges.length, 1);
  });

  test('does not execute LinkAction on locked nodes', () {
    final spec = buildLinkSpec(
      constraints: const [
        LockedNodesConstraint(['n2']),
      ],
    );

    final session = ChallengeSession.start(
      sessionId: 'session_1',
      userId: 'user_1',
      spec: spec,
    );

    final updated = useCase(
      session: session,
      action: const LinkAction(sourceNodeId: 'n2', targetNodeId: 'n3'),
    );

    expect(updated.structureRuntimeState.movesUsed, 0);
    expect(updated.structureRuntimeState.history, isEmpty);
    expect(updated.structureRuntimeState.structure.edges.length, 1);
  });

  test('does not execute LinkAction in swap interaction mode', () {
    final spec = buildSwapSpec();

    final session = ChallengeSession.start(
      sessionId: 'session_1',
      userId: 'user_1',
      spec: spec,
    );

    final updated = useCase(
      session: session,
      action: const LinkAction(sourceNodeId: 'n1', targetNodeId: 'n2'),
    );

    expect(updated.structureRuntimeState.movesUsed, 0);
    expect(updated.structureRuntimeState.history, isEmpty);
  });

  test('does not execute LinkAction when reverse edge already exists', () {
    final spec = buildLinkSpec();

    final session = ChallengeSession.start(
      sessionId: 'session_1',
      userId: 'user_1',
      spec: spec,
    );

    final updated = useCase(
      session: session,
      action: const LinkAction(sourceNodeId: 'n2', targetNodeId: 'n1'),
    );

    expect(updated.structureRuntimeState.movesUsed, 0);
    expect(updated.structureRuntimeState.history, isEmpty);
    expect(updated.structureRuntimeState.structure.edges.length, 1);
  });

  test('clears redo stack when executing a new action after undo', () {
    final spec = buildSwapSpec();

    final session = ChallengeSession.start(
      sessionId: 'session_1',
      userId: 'user_1',
      spec: spec,
    );

    final moved = useCase(
      session: session,
      action: const SwapNodesAction(firstNodeId: 'n1', secondNodeId: 'n2'),
    );

    final undone = const UndoMoveUseCase()(moved);

    expect(undone.structureRuntimeState.redoStack, isNotEmpty);

    final movedAgain = useCase(
      session: undone,
      action: const SwapNodesAction(firstNodeId: 'n1', secondNodeId: 'n2'),
    );

    expect(movedAgain.structureRuntimeState.redoStack, isEmpty);
  });

  test(
    'executes RemoveLinkAction and removes existing edge in link interaction mode',
    () {
      final spec = buildLinkSpec();

      final session = ChallengeSession.start(
        sessionId: 'session_1',
        userId: 'user_1',
        spec: spec,
      );

      final updated = useCase(
        session: session,
        action: const RemoveLinkAction(sourceNodeId: 'n1', targetNodeId: 'n2'),
      );

      expect(updated.structureRuntimeState.movesUsed, 1);
      expect(updated.structureRuntimeState.history.length, 1);
      expect(updated.structureRuntimeState.structure.edges, isEmpty);
    },
  );

  test('does not execute RemoveLinkAction when edge does not exist', () {
    final spec = buildLinkSpec();

    final session = ChallengeSession.start(
      sessionId: 'session_1',
      userId: 'user_1',
      spec: spec,
    );

    final updated = useCase(
      session: session,
      action: const RemoveLinkAction(sourceNodeId: 'n2', targetNodeId: 'n3'),
    );

    expect(updated.structureRuntimeState.movesUsed, 0);
    expect(updated.structureRuntimeState.history, isEmpty);
    expect(updated.structureRuntimeState.structure.edges.length, 1);
  });

  test('does not execute RemoveLinkAction on locked nodes', () {
    final spec = buildLinkSpec(
      constraints: const [
        LockedNodesConstraint(['n1']),
      ],
    );

    final session = ChallengeSession.start(
      sessionId: 'session_1',
      userId: 'user_1',
      spec: spec,
    );

    final updated = useCase(
      session: session,
      action: const RemoveLinkAction(sourceNodeId: 'n1', targetNodeId: 'n2'),
    );

    expect(updated.structureRuntimeState.movesUsed, 0);
    expect(updated.structureRuntimeState.history, isEmpty);
    expect(updated.structureRuntimeState.structure.edges.length, 1);
  });

  test('does not execute RemoveLinkAction in swap interaction mode', () {
    final spec = buildSwapSpec();

    final session = ChallengeSession.start(
      sessionId: 'session_1',
      userId: 'user_1',
      spec: spec,
    );

    final updated = useCase(
      session: session,
      action: const RemoveLinkAction(sourceNodeId: 'n1', targetNodeId: 'n2'),
    );

    expect(updated.structureRuntimeState.movesUsed, 0);
    expect(updated.structureRuntimeState.history, isEmpty);
    expect(updated.structureRuntimeState.structure.edges.length, 1);
  });
}
