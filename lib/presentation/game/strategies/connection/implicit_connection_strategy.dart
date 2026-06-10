import 'package:algoquest/domain/entities/structure_state.dart';
import 'package:algoquest/presentation/game/strategies/connection/connection_strategy.dart';

class ImplicitConnectionStrategy implements ConnectionStrategy {
  const ImplicitConnectionStrategy();

  @override
  List<EdgeState> buildConnections(StructureState state) {
    return switch (state) {
      HeapState() => _buildBinaryTreeConnections(state),
      BstState() => _buildBinaryTreeConnections(state),
      LinkedListState() => _buildLinkedListConnections(state),
      GraphState() => state.edges,
    };
  }

  List<EdgeState> _buildBinaryTreeConnections(StructureState state) {
    final nodeIds = state.nodes.keys.toList(growable: false);

    return [
      for (var i = 0; i < nodeIds.length; i++) ...[
        if ((2 * i + 1) < nodeIds.length)
          EdgeState(source: nodeIds[i], target: nodeIds[2 * i + 1]),
        if ((2 * i + 2) < nodeIds.length)
          EdgeState(source: nodeIds[i], target: nodeIds[2 * i + 2]),
      ],
    ];
  }

  List<EdgeState> _buildLinkedListConnections(StructureState state) {
    final nodeIds = state.nodes.keys.toList(growable: false);

    return [
      for (var i = 0; i < nodeIds.length - 1; i++)
        EdgeState(source: nodeIds[i], target: nodeIds[i + 1]),
    ];
  }
}
