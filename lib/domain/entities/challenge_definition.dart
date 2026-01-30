import '../../data/models/challenge_model.dart'
    show
        LayoutStrategyType,
        ConnectionStrategyType,
        InteractionModeType,
        ValidationStrategyType;

sealed class ChallengeConstraint {
  const ChallengeConstraint();
}

class MaxMovesConstraint extends ChallengeConstraint {
  final int maxMoves;
  const MaxMovesConstraint(this.maxMoves);
}

class LockedNodesConstraint extends ChallengeConstraint {
  final List<String> nodeIds;
  const LockedNodesConstraint(this.nodeIds);
}

class ChallengeEngineConfig {
  final ValidationStrategyType validationStrategy;
  final LayoutStrategyType layoutStrategy;
  final ConnectionStrategyType connectionStrategy;
  final InteractionModeType interactionMode;
  final List<ChallengeConstraint> constraints;

  const ChallengeEngineConfig({
    required this.validationStrategy,
    required this.layoutStrategy,
    required this.connectionStrategy,
    required this.interactionMode,
    required this.constraints,
  });
}

class ChallengeNode {
  final String id;
  final int value;
  const ChallengeNode({required this.id, required this.value});
}

class ChallengeEdge {
  final String source;
  final String target;
  const ChallengeEdge({required this.source, required this.target});
}

class ChallengeSlot {
  final String id;
  final int? index;
  const ChallengeSlot({required this.id, this.index});
}

class ChallengeInitialState {
  final List<ChallengeNode> nodes;
  final List<ChallengeEdge> edges;
  final List<ChallengeSlot> slots;

  const ChallengeInitialState({
    required this.nodes,
    required this.edges,
    required this.slots,
  });
}

class ChallengeDefinition {
  final String title;
  final String instruction;
  final String? theoryRef;
  final ChallengeEngineConfig engineConfig;
  final ChallengeInitialState initialState;

  const ChallengeDefinition({
    required this.title,
    required this.instruction,
    required this.theoryRef,
    required this.engineConfig,
    required this.initialState,
  });
}
