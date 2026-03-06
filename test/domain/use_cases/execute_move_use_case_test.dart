import 'package:flutter_test/flutter_test.dart';

import 'package:algoquest/domain/entities/challenge_session.dart';
import 'package:algoquest/domain/entities/challenge_spec.dart';
import 'package:algoquest/domain/entities/game_action.dart';
import 'package:algoquest/domain/usecases/execute_move_use_case.dart';

void main() {
  late ExecuteMoveUseCase useCase;

  setUp(() {
    useCase = const ExecuteMoveUseCase();
  });

  ChallengeSpec spec() => const ChallengeSpec(
    title: 't',
    instruction: 'i',
    theoryRef: null,
    engineConfig: ChallengeEngineConfig(
      validationStrategy: ValidationStrategyType.maxHeap,
      layoutStrategy: LayoutStrategyType.pyramid,
      connectionStrategy: ConnectionStrategyType.implicitHeap,
      interactionMode: InteractionModeType.swap,
      constraints: [],
    ),
    initialState: ChallengeInitialStateSpec(
      nodes: [
        ChallengeNodeSpec(id: 'a', value: 10),
        ChallengeNodeSpec(id: 'b', value: 3),
      ],
      edges: [],
      slots: [ChallengeSlotSpec(id: 's1', index: 0)],
    ),
  );

  test('SwapNodesAction swaps node values and increments movesUsed', () {
    final session = ChallengeSession.start(
      sessionId: 's',
      userId: 'u',
      spec: spec(),
    );

    final updated = useCase(
      session: session,
      action: const SwapNodesAction(aId: 'a', bId: 'b'),
    );

    expect(updated.movesUsed, 1);
    expect(updated.nodes.firstWhere((n) => n.id == 'a').value, 3);
    expect(updated.nodes.firstWhere((n) => n.id == 'b').value, 10);
  });

  test(
    'SwapNodesAction with unknown ids keeps state but increments movesUsed',
    () {
      final session = ChallengeSession.start(
        sessionId: 's',
        userId: 'u',
        spec: spec(),
      );

      final updated = useCase(
        session: session,
        action: const SwapNodesAction(aId: 'x', bId: 'y'),
      );

      expect(updated.movesUsed, 1);
      // unchanged
      expect(updated.nodes.firstWhere((n) => n.id == 'a').value, 10);
      expect(updated.nodes.firstWhere((n) => n.id == 'b').value, 3);
    },
  );

  test('DragNodeToSlotAction fills slot and increments movesUsed', () {
    final session = ChallengeSession.start(
      sessionId: 's',
      userId: 'u',
      spec: spec(),
    );

    final updated = useCase(
      session: session,
      action: const DragNodeToSlotAction(nodeId: 'a', slotId: 's1'),
    );

    expect(updated.movesUsed, 1);
    expect(updated.slots.firstWhere((s) => s.id == 's1').filledNodeId, 'a');
  });

  test(
    'DragNodeToSlotAction with unknown slot keeps slots but increments movesUsed',
    () {
      final session = ChallengeSession.start(
        sessionId: 's',
        userId: 'u',
        spec: spec(),
      );

      final updated = useCase(
        session: session,
        action: const DragNodeToSlotAction(nodeId: 'a', slotId: 'unknown'),
      );

      expect(updated.movesUsed, 1);
      expect(
        updated.slots.firstWhere((s) => s.id == 's1').filledNodeId,
        isNull,
      );
    },
  );
}
