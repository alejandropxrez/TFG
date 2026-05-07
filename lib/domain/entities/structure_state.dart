import 'package:algoquest/domain/enums/structure_type.dart';

/// Represents the runtime state of a structure (heap, BST, graph, etc.)
///
/// Key ideas:
/// - Nodes represent both filled values AND empty positions
/// - A node with `value == null` is considered an empty slot
/// - Inventory holds values that can be assigned to empty nodes
sealed class StructureState {
  final Map<String, NodeState> nodes;
  final List<EdgeState> edges;
  final Map<String, SlotState> slots;
  final List<int> inventory;

  const StructureState({
    required this.nodes,
    required this.edges,
    required this.slots,
    required this.inventory,
  });

  factory StructureState.fromNodesAndEdges({
    required StructureType type,
    required List<NodeState> nodes,
    required List<EdgeState> edges,
    List<SlotState> slots = const [],
    List<int> inventory = const [],
  }) {
    final nodeMap = {for (final n in nodes) n.id: n};
    final slotMap = {for (final s in slots) s.id: s};

    switch (type) {
      case StructureType.heap:
        return HeapState._(
          nodes: nodeMap,
          edges: edges,
          slots: slotMap,
          inventory: inventory,
        );
      case StructureType.bst:
        return BstState._(
          nodes: nodeMap,
          edges: edges,
          slots: slotMap,
          inventory: inventory,
        );
      case StructureType.graph:
        return GraphState._(
          nodes: nodeMap,
          edges: edges,
          slots: slotMap,
          inventory: inventory,
        );
      case StructureType.linkedList:
        return LinkedListState._(
          nodes: nodeMap,
          edges: edges,
          slots: slotMap,
          inventory: inventory,
        );
    }
  }

  StructureState copyWith({
    Map<String, NodeState>? nodes,
    List<EdgeState>? edges,
    Map<String, SlotState>? slots,
    List<int>? inventory,
  });
}

class NodeState {
  final String id;
  final int? value;

  const NodeState({required this.id, this.value});

  NodeState copyWith({int? value}) {
    return NodeState(id: id, value: value ?? this.value);
  }
}

class EdgeState {
  final String source;
  final String target;

  const EdgeState({required this.source, required this.target});
}

class SlotState {
  final String id;
  final int? index;
  final String? filledNodeId;

  const SlotState({required this.id, this.index, this.filledNodeId});

  SlotState copyWith({String? filledNodeId}) {
    return SlotState(
      id: id,
      index: index,
      filledNodeId: filledNodeId ?? this.filledNodeId,
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
