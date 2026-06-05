import 'package:algoquest/domain/entities/structure_state.dart';

class HeapStructureValidator {
  const HeapStructureValidator();

  bool hasValidHeapShape(StructureState state) {
    if (state.nodes.isEmpty) return true;

    final rootId = _findRootId(state);
    if (rootId == null) return false;

    final childrenMap = <String, List<String>>{};
    final parentCount = <String, int>{
      for (final nodeId in state.nodes.keys) nodeId: 0,
    };

    for (final edge in state.edges) {
      if (!state.nodes.containsKey(edge.source)) return false;
      if (!state.nodes.containsKey(edge.target)) return false;
      if (edge.source == edge.target) return false;

      childrenMap.putIfAbsent(edge.source, () => []).add(edge.target);
      parentCount[edge.target] = (parentCount[edge.target] ?? 0) + 1;
    }

    for (final entry in childrenMap.entries) {
      if (entry.value.length > 2) return false;
    }

    for (final nodeId in state.nodes.keys) {
      final parents = parentCount[nodeId] ?? 0;

      if (nodeId == rootId) {
        if (parents != 0) return false;
      } else {
        if (parents != 1) return false;
      }
    }

    if (state.edges.length != state.nodes.length - 1) {
      return false;
    }

    final visited = <String>{};
    final visiting = <String>{};

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

    return visited.length == state.nodes.length;
  }

  String? _findRootId(StructureState state) {
    final allNodeIds = state.nodes.keys.toSet();
    final childIds = state.edges.map((edge) => edge.target).toSet();

    final roots = allNodeIds.difference(childIds);

    if (roots.length != 1) return null;

    return roots.first;
  }
}
