import 'package:algoquest/domain/entities/challenge_spec.dart' as domain;

import 'package:algoquest/data/models/challenge_model.dart' as model;

class ChallengeMapper {
  static domain.ChallengeSpec toDomain(model.ChallengeModel challengeModel) {
    return domain.ChallengeSpec(
      title: challengeModel.metadata.title,
      instruction: challengeModel.metadata.instruction,
      theoryRef: challengeModel.metadata.theoryRef,
      engineConfig: domain.ChallengeEngineConfig(
        validationStrategy: _mapValidationStrategy(
          challengeModel.engineConfig.validationStrategy,
        ),
        layoutStrategy: _mapLayoutStrategy(
          challengeModel.engineConfig.layoutStrategy,
        ),
        connectionStrategy: _mapConnectionStrategy(
          challengeModel.engineConfig.connectionStrategy,
        ),
        interactionMode: _mapInteractionMode(
          challengeModel.engineConfig.interactionMode,
        ),
        constraints: challengeModel.engineConfig.constraints
            .map(_mapConstraint)
            .toList(),
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

  static domain.ConnectionStrategyType _mapConnectionStrategy(
    model.ConnectionStrategyType strategyType,
  ) {
    switch (strategyType) {
      case model.ConnectionStrategyType.implicitHeap:
        return domain.ConnectionStrategyType.implicitHeap;
      case model.ConnectionStrategyType.explicit:
        return domain.ConnectionStrategyType.explicit;
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
    }
  }
}
