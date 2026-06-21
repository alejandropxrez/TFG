import 'package:algoquest/domain/enums/structure_type.dart';

/// Immutable runtime representation of an interactive data structure.
///
/// Concrete subtypes identify the semantic structure being manipulated:
/// heaps, binary search trees, graphs, or linked lists.
///
/// The state contains:
///
/// - [nodes], indexed by their unique identifiers;
/// - [edges], representing relationships between nodes;
/// - [slots], used by placement and ordering challenges;
/// - [inventory], containing values available for assignment.
///
/// A node whose [NodeState.value] is `null` represents an empty position.
sealed class StructureState {
  /// Nodes belonging to the structure, indexed by node identifier.
  final Map<String, NodeState> nodes;

  /// Connections between nodes.
  final List<EdgeState> edges;

  /// Placement slots, indexed by slot identifier.
  final Map<String, SlotState> slots;

  /// Values currently available for placement into slots.
  final List<int> inventory;

  const StructureState({
    required this.nodes,
    required this.edges,
    required this.slots,
    required this.inventory,
  });

  /// Creates the appropriate concrete structure state for [type].
  ///
  /// Node and slot collections are converted into maps to provide efficient
  /// lookup by identifier.
  factory StructureState.fromNodesAndEdges({
    required StructureType type,
    required List<NodeState> nodes,
    required List<EdgeState> edges,
    List<SlotState> slots = const [],
    List<int> inventory = const [],
  }) {
    final nodeMap = {for (final node in nodes) node.id: node};

    final slotMap = {for (final slot in slots) slot.id: slot};

    return switch (type) {
      StructureType.heap => HeapState._(
        nodes: nodeMap,
        edges: edges,
        slots: slotMap,
        inventory: inventory,
      ),
      StructureType.bst => BstState._(
        nodes: nodeMap,
        edges: edges,
        slots: slotMap,
        inventory: inventory,
      ),
      StructureType.graph => GraphState._(
        nodes: nodeMap,
        edges: edges,
        slots: slotMap,
        inventory: inventory,
      ),
      StructureType.linkedList => LinkedListState._(
        nodes: nodeMap,
        edges: edges,
        slots: slotMap,
        inventory: inventory,
      ),
    };
  }

  /// Creates a new state of the same concrete structure type.
  ///
  /// Fields that are not supplied retain their current values.
  StructureState copyWith({
    Map<String, NodeState>? nodes,
    List<EdgeState>? edges,
    Map<String, SlotState>? slots,
    List<int>? inventory,
  });
}

/// State of an individual structure node.
class NodeState {
  /// Unique identifier of the node.
  final String id;

  /// Value stored by the node.
  ///
  /// A `null` value represents an empty node or position.
  final int? value;

  const NodeState({required this.id, this.value});

  /// Creates a new node with the supplied value.
  ///
  /// When [value] is omitted or `null`, the existing value is preserved.
  NodeState copyWith({int? value}) {
    return NodeState(id: id, value: value ?? this.value);
  }
}

/// Directed representation of a connection between two nodes.
///
/// Some challenge operations interpret edges as undirected and therefore
/// consider both source-target orientations equivalent.
class EdgeState {
  /// Identifier of the source node.
  final String source;

  /// Identifier of the target node.
  final String target;

  const EdgeState({required this.source, required this.target});
}

/// Sentinel used to distinguish an omitted value from an explicit `null`.
const _unset = Object();

/// State of a placement slot used by list and sequence challenges.
class SlotState {
  /// Unique identifier of the slot.
  final String id;

  /// Optional logical position of the slot in an ordered sequence.
  final int? index;

  /// Identifier of the node currently assigned to this slot.
  ///
  /// A `null` value means that the slot is empty.
  final String? filledNodeId;

  const SlotState({required this.id, this.index, this.filledNodeId});

  /// Creates a new slot with an optionally replaced node assignment.
  ///
  /// A sentinel is used so that:
  ///
  /// - omitting [filledNodeId] preserves the current assignment;
  /// - passing `null` explicitly clears the slot.
  SlotState copyWith({Object? filledNodeId = _unset}) {
    return SlotState(
      id: id,
      index: index,
      filledNodeId: filledNodeId == _unset
          ? this.filledNodeId
          : filledNodeId as String?,
    );
  }
}

class HeapState extends StructureState {
  const HeapState._({
    required super.nodes,
    required super.edges,
    required super.slots,
    required super.inventory,
  });

  @override
  HeapState copyWith({
    Map<String, NodeState>? nodes,
    List<EdgeState>? edges,
    Map<String, SlotState>? slots,
    List<int>? inventory,
  }) {
    return HeapState._(
      nodes: nodes ?? this.nodes,
      edges: edges ?? this.edges,
      slots: slots ?? this.slots,
      inventory: inventory ?? this.inventory,
    );
  }
}

class BstState extends StructureState {
  const BstState._({
    required super.nodes,
    required super.edges,
    required super.slots,
    required super.inventory,
  });

  @override
  BstState copyWith({
    Map<String, NodeState>? nodes,
    List<EdgeState>? edges,
    Map<String, SlotState>? slots,
    List<int>? inventory,
  }) {
    return BstState._(
      nodes: nodes ?? this.nodes,
      edges: edges ?? this.edges,
      slots: slots ?? this.slots,
      inventory: inventory ?? this.inventory,
    );
  }
}

class GraphState extends StructureState {
  const GraphState._({
    required super.nodes,
    required super.edges,
    required super.slots,
    required super.inventory,
  });

  @override
  GraphState copyWith({
    Map<String, NodeState>? nodes,
    List<EdgeState>? edges,
    Map<String, SlotState>? slots,
    List<int>? inventory,
  }) {
    return GraphState._(
      nodes: nodes ?? this.nodes,
      edges: edges ?? this.edges,
      slots: slots ?? this.slots,
      inventory: inventory ?? this.inventory,
    );
  }
}

class LinkedListState extends StructureState {
  const LinkedListState._({
    required super.nodes,
    required super.edges,
    required super.slots,
    required super.inventory,
  });

  @override
  LinkedListState copyWith({
    Map<String, NodeState>? nodes,
    List<EdgeState>? edges,
    Map<String, SlotState>? slots,
    List<int>? inventory,
  }) {
    return LinkedListState._(
      nodes: nodes ?? this.nodes,
      edges: edges ?? this.edges,
      slots: slots ?? this.slots,
      inventory: inventory ?? this.inventory,
    );
  }
}
