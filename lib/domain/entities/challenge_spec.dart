import 'package:algoquest/domain/strategies/validation_strategy.dart';

import 'package:algoquest/domain/enums/structure_type.dart';

// Domain enums (no dependency on data layer)
enum LayoutStrategyType { pyramid, linear }

enum InteractionModeType { swap, drag, setValue, link }

enum ValidationStrategyType { maxHeap, minHeap, bst }

enum ConnectionType { implicit, explicit, none }

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
  final StructureType structureType;
  final ValidationStrategy validationStrategy;
  final LayoutStrategyType layoutStrategy;
  final InteractionModeType interactionMode;
  final ConnectionType connectionType;
  final List<ChallengeConstraint> constraints;

  const ChallengeEngineConfig({
    required this.structureType,
    required this.validationStrategy,
    required this.layoutStrategy,
    required this.interactionMode,
    required this.connectionType,
    required this.constraints,
  });
}

/// Immutable initial blueprint state (loaded from JSON)
class ChallengeNodeSpec {
  final String id;
  final int? value;

  const ChallengeNodeSpec({required this.id, required this.value});
}

class ChallengeEdgeSpec {
  final String source;
  final String target;

  const ChallengeEdgeSpec({required this.source, required this.target});
}

class ChallengeSlotSpec {
  final String id;
  final int? index;

  const ChallengeSlotSpec({required this.id, this.index});
}

class ChallengeInitialStateSpec {
  final List<ChallengeNodeSpec> nodes;
  final List<ChallengeEdgeSpec> edges;
  final List<ChallengeSlotSpec> slots;

  /// Optional inventory for set-value/fill-in-the-blanks mechanics
  final List<int> inventory;

  const ChallengeInitialStateSpec({
    required this.nodes,
    required this.edges,
    required this.slots,
    this.inventory = const [],
  });
}

/// Static configuration loaded at challenge start
class ChallengeSpec {
  final String id;
  final String title;
  final String instruction;
  final String? theoryRef;
  final ChallengeEngineConfig engineConfig;
  final ChallengeInitialStateSpec initialState;

  const ChallengeSpec({
    required this.id,
    required this.title,
    required this.instruction,
    required this.theoryRef,
    required this.engineConfig,
    required this.initialState,
  });
}
