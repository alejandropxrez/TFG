import 'package:algoquest/domain/entities/challenge_spec.dart';
import 'package:algoquest/data/models/challenge_model.dart';

class ChallengeMapper {
  static ChallengeSpec toDomain(ChallengeModel challengeModel) {
    return ChallengeSpec(
      title: challengeModel.metadata.title,
      instruction: challengeModel.metadata.instruction,
      theoryRef: challengeModel.metadata.theoryRef,
      engineConfig: ChallengeEngineConfig(
        structureType: challengeModel.engineConfig.structureType,
        validationStrategy: challengeModel.engineConfig.validationStrategy,
        layoutStrategy: challengeModel.engineConfig.layoutStrategy,
        interactionMode: challengeModel.engineConfig.interactionMode,
        constraints: challengeModel.engineConfig.constraints
            .map(_mapConstraint)
            .toList(growable: false),
      ),
      initialState: ChallengeInitialStateSpec(
        nodes: challengeModel.initialState.nodes
            .map((node) => ChallengeNodeSpec(id: node.id, value: node.value))
            .toList(growable: false),
        edges: challengeModel.initialState.edges
            .map(
              (edge) =>
                  ChallengeEdgeSpec(source: edge.source, target: edge.target),
            )
            .toList(growable: false),
        slots: challengeModel.initialState.slots
            .map((slot) => ChallengeSlotSpec(id: slot.id, index: slot.index))
            .toList(growable: false),
        inventory: challengeModel.initialState.inventory,
      ),
    );
  }

  static ChallengeConstraint _mapConstraint(
    ChallengeConstraintModel constraintModel,
  ) {
    return constraintModel.when(
      maxMoves: (maxMoves) => MaxMovesConstraint(maxMoves),
      lockedNodes: (nodeIds) => LockedNodesConstraint(nodeIds),
    );
  }
}
