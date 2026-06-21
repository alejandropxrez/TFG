import 'package:algoquest/domain/entities/structure_state.dart';

/// Validates the structural properties required by a heap representation.
///
/// This validator checks that the structure forms a single directed binary
/// tree:
///
/// - exactly one root exists;
/// - every non-root node has exactly one parent;
/// - every node has at most two children;
/// - self-referencing edges are rejected;
/// - all edges reference existing nodes;
/// - the structure contains no cycles;
/// - every node is reachable from the root;
/// - a tree with `n` nodes contains exactly `n - 1` edges.
///
/// An empty structure is considered structurally valid.
///
/// NOTE: This validator does not verify that the binary tree is complete.
/// Determining the complete-tree shape of a heap would require an explicit
/// left-to-right child order or positional information for each node.
class HeapStructureValidator {
  const HeapStructureValidator();

  /// Returns whether [state] forms a valid rooted binary tree.
  ///
  /// This method validates only the structural requirements of the heap. It
  /// does not validate the min-heap or max-heap ordering property.
  bool hasValidHeapShape(StructureState state) {
    if (state.nodes.isEmpty) return true;

    final rootId = _findRootId(state);
    if (rootId == null) return false;

    final childrenMap = <String, List<String>>{};
    final parentCount = <String, int>{
      for (final nodeId in state.nodes.keys) nodeId: 0,
    };

    // Build the parent-child relationships and reject malformed edges.
    for (final edge in state.edges) {
      if (!state.nodes.containsKey(edge.source)) return false;
      if (!state.nodes.containsKey(edge.target)) return false;
      if (edge.source == edge.target) return false;

      childrenMap.putIfAbsent(edge.source, () => []).add(edge.target);
      parentCount[edge.target] = (parentCount[edge.target] ?? 0) + 1;
    }

    // A binary-tree node can have at most two children.
    for (final entry in childrenMap.entries) {
      if (entry.value.length > 2) return false;
    }

    // The root has no parent and every other node has exactly one.
    for (final nodeId in state.nodes.keys) {
      final parents = parentCount[nodeId] ?? 0;

      if (nodeId == rootId) {
        if (parents != 0) return false;
      } else {
        if (parents != 1) return false;
      }
    }

    // A tree with n nodes must contain exactly n - 1 edges.
    if (state.edges.length != state.nodes.length - 1) {
      return false;
    }

    final visited = <String>{};
    final visiting = <String>{};

    /// Traverses the tree while detecting cycles.
    bool dfs(String nodeId) {
      if (visiting.contains(nodeId)) return false;
      if (visited.contains(nodeId)) return true;

      visiting.add(nodeId);

      for (final childId in childrenMap[nodeId] ?? const <String>[]) {
        if (!dfs(childId)) return false;
      }

      visiting.remove(nodeId);
      visited.add(nodeId);

      return true;
    }

    if (!dfs(rootId)) return false;

    // Every node must belong to the same tree.
    return visited.length == state.nodes.length;
  }

  /// Finds the only node that is never referenced as an edge target.
  ///
  /// Returns `null` when the structure does not contain exactly one root.
  String? _findRootId(StructureState state) {
    final allNodeIds = state.nodes.keys.toSet();
    final childIds = state.edges.map((edge) => edge.target).toSet();

    final roots = allNodeIds.difference(childIds);

    if (roots.length != 1) return null;

    return roots.first;
  }
}
