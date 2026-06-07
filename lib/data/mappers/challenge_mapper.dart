import 'package:algoquest/domain/entities/challenge_spec.dart';
import 'package:algoquest/data/models/challenge_model.dart';
import 'package:algoquest/domain/strategies/bst_validation_strategy.dart';
import 'package:algoquest/domain/strategies/max_heap_validation_strategy.dart';
import 'package:algoquest/domain/strategies/min_heap_validation_strategy.dart';
import 'package:algoquest/domain/strategies/validation_strategy.dart';

class ChallengeMapper {
  static ChallengeSpec toDomain(
    String challengeId,
    ChallengeModel challengeModel,
  ) {
    return ChallengeSpec(
      id: challengeId,
      title: challengeModel.metadata.title,
      instruction: challengeModel.metadata.instruction,
      theoryRef: challengeModel.metadata.theoryRef,
      engineConfig: ChallengeEngineConfig(
        structureType: challengeModel.engineConfig.structureType,
        validationStrategy: _mapValidationStrategy(
          challengeModel.engineConfig.validationStrategy,
        ),
        layoutStrategy: challengeModel.engineConfig.layoutStrategy,
        interactionMode: challengeModel.engineConfig.interactionMode,
        connectionType: challengeModel.engineConfig.connectionType,
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
      maxAttempts: (maxAttempts) => MaxAttemptsConstraint(maxAttempts),
      livesConsumedOnFail: (lives) => LivesConsumedOnFailConstraint(lives),
    );
  }

  static ValidationStrategy _mapValidationStrategy(
    ValidationStrategyType type,
  ) {
    switch (type) {
      case ValidationStrategyType.maxHeap:
        return MaxHeapValidationStrategy();
      case ValidationStrategyType.minHeap:
        return MinHeapValidationStrategy();
      case ValidationStrategyType.bst:
        return BstValidationStrategy();
    }
  }
}
