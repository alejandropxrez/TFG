import 'package:algoquest/domain/entities/game_action.dart';
import 'package:algoquest/presentation/game/strategies/interaction/interaction_strategy.dart';

class LinkInteractionStrategy implements InteractionStrategy {
  String? _selectedSourceNodeId;

  @override
  Set<String> get selectedNodeIds {
    return _selectedSourceNodeId == null ? const {} : {_selectedSourceNodeId!};
  }

  @override
  int? get selectedInventoryValue => null;

  @override
  GameAction? handleInventoryTap(int value) => null;

  @override
  GameAction? handleNodeTap(String nodeId) {
    if (_selectedSourceNodeId == null) {
      _selectedSourceNodeId = nodeId;
      return null;
    }

    if (_selectedSourceNodeId == nodeId) {
      _selectedSourceNodeId = null;
      return null;
    }

    final source = _selectedSourceNodeId!;
    final target = nodeId;

    _selectedSourceNodeId = null;

    return LinkAction(sourceNodeId: source, targetNodeId: target);
  }

  @override
  GameAction? handleEdgeTap(String sourceNodeId, String targetNodeId) {
    _selectedSourceNodeId = null;

    return RemoveLinkAction(
      sourceNodeId: sourceNodeId,
      targetNodeId: targetNodeId,
    );
  }

  @override
  void clearSelection() {
    _selectedSourceNodeId = null;
  }
}
