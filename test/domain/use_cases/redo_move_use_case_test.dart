import 'package:algoquest/domain/entities/challenge_session.dart';
import 'package:algoquest/domain/entities/challenge_spec.dart';
import 'package:algoquest/domain/entities/game_action.dart';
import 'package:algoquest/domain/enums/structure_type.dart';
import 'package:algoquest/domain/strategies/validation_strategy.dart';
import 'package:algoquest/domain/usecases/execute_move_use_case.dart';
import 'package:algoquest/domain/usecases/redo_move_use_case.dart';
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
      constraints: const [],
      content: StructureChallengeContent(
        engineConfig: ChallengeEngineConfig(
          structureType: StructureType.heap,
          validationStrategy: AlwaysTrueValidationStrategy(),
          layoutStrategy: LayoutStrategyType.pyramid,
          interactionMode: InteractionModeType.swap,
          connectionType: ConnectionType.explicit,
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

  test('returns same session when redo stack is empty', () {
    final session = ChallengeSession.start(
      sessionId: 'session_1',
      userId: 'user_1',
      spec: buildSpec(),
    );

    const useCase = RedoMoveUseCase();

    final updated = useCase(session);

    expect(updated.structureRuntimeState.redoStack, isEmpty);
    expect(updated.structureRuntimeState.movesUsed, 0);
    expect(updated.structureRuntimeState.structure.nodes['n1']!.value, 3);
  });
  test('redoes previously undone move', () {
    final spec = buildSpec();

    final session = ChallengeSession.start(
      sessionId: 'session_1',
      userId: 'user_1',
      spec: spec,
    );

    const executeMove = ExecuteMoveUseCase();
    const undoMove = UndoMoveUseCase();
    const redoMove = RedoMoveUseCase();

    final moved = executeMove(
      session: session,
      action: const SwapNodesAction(firstNodeId: 'n1', secondNodeId: 'n2'),
    );

    final undone = undoMove(moved);

    expect(undone.structureRuntimeState.redoStack.length, 1);
    expect(undone.structureRuntimeState.structure.nodes['n1']!.value, 3);
    expect(undone.structureRuntimeState.structure.nodes['n2']!.value, 10);

    final redone = redoMove(undone);

    expect(redone.structureRuntimeState.structure.nodes['n1']!.value, 10);
    expect(redone.structureRuntimeState.structure.nodes['n2']!.value, 3);
    expect(redone.structureRuntimeState.movesUsed, 1);
    expect(redone.structureRuntimeState.history.length, 1);
    expect(redone.structureRuntimeState.redoStack, isEmpty);
  });
}
