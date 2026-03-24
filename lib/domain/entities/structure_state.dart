import '../enums/structure_type.dart';

sealed class StructureState {
  final Map<String, NodeState> nodes;
  final List<EdgeState> edges;

  const StructureState({required this.nodes, required this.edges});

  factory StructureState.fromNodesAndEdges({
    required StructureType type,
    required List<NodeState> nodes,
    required List<EdgeState> edges,
  }) {
    final nodeMap = {for (final n in nodes) n.id: n};

    switch (type) {
      case StructureType.heap:
        return HeapState._(nodes: nodeMap, edges: edges);
      case StructureType.bst:
        return BstState._(nodes: nodeMap, edges: edges);
      case StructureType.graph:
        return GraphState._(nodes: nodeMap, edges: edges);
      case StructureType.linkedList:
        return LinkedListState._(nodes: nodeMap, edges: edges);
    }
  }

  StructureState copyWith({
    Map<String, NodeState>? nodes,
    List<EdgeState>? edges,
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

class HeapState extends StructureState {
  const HeapState._({required super.nodes, required super.edges});

  List<NodeState> childrenOf(String nodeId) {
    return edges
        .where((e) => e.source == nodeId)
        .map((e) => nodes[e.target]!)
        .toList(growable: false);
  }

  @override
  HeapState copyWith({Map<String, NodeState>? nodes, List<EdgeState>? edges}) {
    return HeapState._(nodes: nodes ?? this.nodes, edges: edges ?? this.edges);
  }
}

class BstState extends StructureState {
  const BstState._({required super.nodes, required super.edges});

  NodeState? leftChild(String nodeId) {
    final edge = edges.firstWhere(
      (e) => e.source == nodeId,
      orElse: () => const EdgeState(source: '', target: ''),
    );

    return edge.target.isEmpty ? null : nodes[edge.target];
  }

  @override
  BstState copyWith({Map<String, NodeState>? nodes, List<EdgeState>? edges}) {
    return BstState._(nodes: nodes ?? this.nodes, edges: edges ?? this.edges);
  }
}

class GraphState extends StructureState {
  const GraphState._({required super.nodes, required super.edges});

  List<NodeState> neighbors(String nodeId) {
    return edges
        .where((e) => e.source == nodeId)
        .map((e) => nodes[e.target]!)
        .toList(growable: false);
  }

  @override
  GraphState copyWith({Map<String, NodeState>? nodes, List<EdgeState>? edges}) {
    return GraphState._(nodes: nodes ?? this.nodes, edges: edges ?? this.edges);
  }
}

class LinkedListState extends StructureState {
  const LinkedListState._({required super.nodes, required super.edges});

  NodeState? next(String nodeId) {
    final edge = edges.firstWhere(
      (e) => e.source == nodeId,
      orElse: () => const EdgeState(source: '', target: ''),
    );

    return edge.target.isEmpty ? null : nodes[edge.target];
  }

  @override
  LinkedListState copyWith({
    Map<String, NodeState>? nodes,
    List<EdgeState>? edges,
  }) {
    return LinkedListState._(
      nodes: nodes ?? this.nodes,
      edges: edges ?? this.edges,
    );
  }
}
