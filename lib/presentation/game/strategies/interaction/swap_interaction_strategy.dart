import 'package:algoquest/domain/entities/game_action.dart';
import 'interaction_strategy.dart';

class SwapInteractionStrategy implements InteractionStrategy {
  String? _selectedNodeId;

  @override
  Set<String> get selectedNodeIds {
    return _selectedNodeId == null ? const {} : {_selectedNodeId!};
  }

  @override
  int? get selectedInventoryValue => null;

  @override
  GameAction? handleEdgeTap(String sourceNodeId, String targetNodeId) => null;

  @override
  GameAction? handleNodeTap(String nodeId) {
    if (_selectedNodeId == null) {
      _selectedNodeId = nodeId;
      return null;
    }

    if (_selectedNodeId == nodeId) {
      _selectedNodeId = null;
      return null;
    }

    final first = _selectedNodeId!;
    final second = nodeId;

    _selectedNodeId = null;

    return SwapNodesAction(firstNodeId: first, secondNodeId: second);
  }

  @override
  GameAction? handleInventoryTap(int value) => null;
}
