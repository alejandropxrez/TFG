import 'package:algoquest/domain/entities/challenge_session.dart';
import 'package:algoquest/domain/entities/challenge_spec.dart';
import 'package:algoquest/domain/entities/game_action.dart';
import 'package:algoquest/domain/enums/session_status.dart';
import 'package:algoquest/domain/enums/structure_type.dart';
import 'package:algoquest/domain/strategies/validation_strategy.dart';
import 'package:algoquest/domain/usecases/execute_move_use_case.dart';
import 'package:algoquest/domain/usecases/undo_move_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

class AlwaysTrueValidationStrategy implements ValidationStrategy {
  @override
  bool isSolved(ChallengeSession session) => true;
}

void main() {
  ChallengeSpec buildSpec() {
    return ChallengeSpec(
      id: 'challenge_1',
      title: 'Undo Challenge',
      instruction: 'Swap and undo',
      theoryRef: null,
      engineConfig: ChallengeEngineConfig(
        structureType: StructureType.heap,
        validationStrategy: AlwaysTrueValidationStrategy(),
        layoutStrategy: LayoutStrategyType.pyramid,
        interactionMode: InteractionModeType.swap,
        connectionType: ConnectionType.explicit,
        constraints: const [],
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
    );
  }

  test('returns same session when history is empty', () {
    final session = ChallengeSession.start(
      sessionId: 'session_1',
      userId: 'user_1',
      spec: buildSpec(),
    );

    const useCase = UndoMoveUseCase();

    final updated = useCase(session);

    expect(updated.currentState.nodes['n1']!.value, 3);
    expect(updated.currentState.nodes['n2']!.value, 10);
    expect(updated.movesUsed, 0);
    expect(updated.history, isEmpty);
  });

  test('restores previous state and removes last history entry', () {
    final spec = buildSpec();

    final session = ChallengeSession.start(
      sessionId: 'session_1',
      userId: 'user_1',
      spec: spec,
    );

    const executeMove = ExecuteMoveUseCase();

    final movedSession = executeMove(
      session: session,
      action: const SwapNodesAction(firstNodeId: 'n1', secondNodeId: 'n2'),
    );

    expect(movedSession.currentState.nodes['n1']!.value, 10);
    expect(movedSession.currentState.nodes['n2']!.value, 3);
    expect(movedSession.movesUsed, 1);
    expect(movedSession.history.length, 1);

    const undoMove = UndoMoveUseCase();

    final undoneSession = undoMove(movedSession);

    expect(undoneSession.currentState.nodes['n1']!.value, 3);
    expect(undoneSession.currentState.nodes['n2']!.value, 10);
    expect(undoneSession.movesUsed, 0);
    expect(undoneSession.history, isEmpty);
    expect(undoneSession.status, SessionStatus.inProgress);
  });
}
