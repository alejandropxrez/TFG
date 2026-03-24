import '../../domain/entities/challenge_spec.dart' as domain;
import '../../domain/enums/structure_type.dart' as domain;
import '../models/challenge_model.dart' as model;

class ChallengeMapper {
  static domain.ChallengeSpec toDomain(model.ChallengeModel challengeModel) {
    return domain.ChallengeSpec(
      title: challengeModel.metadata.title,
      instruction: challengeModel.metadata.instruction,
      theoryRef: challengeModel.metadata.theoryRef,
      engineConfig: domain.ChallengeEngineConfig(
        structureType: _mapStructureType(
          challengeModel.engineConfig.structureType,
        ),
        validationStrategy: _mapValidationStrategy(
          challengeModel.engineConfig.validationStrategy,
        ),
        layoutStrategy: _mapLayoutStrategy(
          challengeModel.engineConfig.layoutStrategy,
        ),
        interactionMode: _mapInteractionMode(
          challengeModel.engineConfig.interactionMode,
        ),
        constraints: challengeModel.engineConfig.constraints
            .map(_mapConstraint)
            .toList(growable: false),
      ),
      initialState: domain.ChallengeInitialStateSpec(
        nodes: challengeModel.initialState.nodes
            .map(
              (node) =>
                  domain.ChallengeNodeSpec(id: node.id, value: node.value),
            )
            .toList(growable: false),
        edges: challengeModel.initialState.edges
            .map(
              (edge) => domain.ChallengeEdgeSpec(
                source: edge.source,
                target: edge.target,
              ),
            )
            .toList(growable: false),
        slots: challengeModel.initialState.slots
            .map(
              (slot) =>
                  domain.ChallengeSlotSpec(id: slot.id, index: slot.index),
            )
            .toList(growable: false),
        inventory: challengeModel.initialState.inventory,
      ),
    );
  }

  static domain.ChallengeConstraint _mapConstraint(
    model.ChallengeConstraintModel constraintModel,
  ) {
    return constraintModel.when(
      maxMoves: (maxMoves) => domain.MaxMovesConstraint(maxMoves),
      lockedNodes: (nodeIds) => domain.LockedNodesConstraint(nodeIds),
    );
  }

  static domain.StructureType _mapStructureType(
    model.StructureTypeModel structureType,
  ) {
    switch (structureType) {
      case model.StructureTypeModel.heap:
        return domain.StructureType.heap;
      case model.StructureTypeModel.bst:
        return domain.StructureType.bst;
      case model.StructureTypeModel.graph:
        return domain.StructureType.graph;
      case model.StructureTypeModel.linkedList:
        return domain.StructureType.linkedList;
    }
  }

  static domain.ValidationStrategyType _mapValidationStrategy(
    model.ValidationStrategyType strategyType,
  ) {
    switch (strategyType) {
      case model.ValidationStrategyType.maxHeap:
        return domain.ValidationStrategyType.maxHeap;
      case model.ValidationStrategyType.minHeap:
        return domain.ValidationStrategyType.minHeap;
      case model.ValidationStrategyType.bst:
        return domain.ValidationStrategyType.bst;
    }
  }

  static domain.LayoutStrategyType _mapLayoutStrategy(
    model.LayoutStrategyType strategyType,
  ) {
    switch (strategyType) {
      case model.LayoutStrategyType.pyramid:
        return domain.LayoutStrategyType.pyramid;
      case model.LayoutStrategyType.linear:
        return domain.LayoutStrategyType.linear;
    }
  }

  static domain.InteractionModeType _mapInteractionMode(
    model.InteractionModeType strategyType,
  ) {
    switch (strategyType) {
      case model.InteractionModeType.swap:
        return domain.InteractionModeType.swap;
      case model.InteractionModeType.drag:
        return domain.InteractionModeType.drag;
      case model.InteractionModeType.setValue:
        return domain.InteractionModeType.setValue;
    }
  }
}
