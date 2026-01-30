import '../../domain/entities/challenge_definition.dart';
import '../models/challenge_model.dart';

class ChallengeMapper {
  static ChallengeDefinition toDomain(ChallengeModel model) {
    return ChallengeDefinition(
      title: model.metadata.title,
      instruction: model.metadata.instruction,
      theoryRef: model.metadata.theoryRef,
      engineConfig: ChallengeEngineConfig(
        validationStrategy: model.engineConfig.validationStrategy,
        layoutStrategy: model.engineConfig.layoutStrategy,
        connectionStrategy: model.engineConfig.connectionStrategy,
        interactionMode: model.engineConfig.interactionMode,
        constraints: model.engineConfig.constraints
            .map(_mapConstraint)
            .toList(),
      ),
      initialState: ChallengeInitialState(
        nodes: model.initialState.nodes
            .map((n) => ChallengeNode(id: n.id, value: n.value))
            .toList(),
        edges: model.initialState.edges
            .map((e) => ChallengeEdge(source: e.source, target: e.target))
            .toList(),
        slots: model.initialState.slots
            .map((s) => ChallengeSlot(id: s.id, index: s.index))
            .toList(),
      ),
    );
  }

  static ChallengeConstraint _mapConstraint(ChallengeConstraintModel c) {
    return c.when(
      maxMoves: (maxMoves) => MaxMovesConstraint(maxMoves),
      lockedNodes: (nodeIds) => LockedNodesConstraint(nodeIds),
    );
  }
}
