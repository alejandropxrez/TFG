import 'package:algoquest/domain/entities/game_action.dart';
import 'package:algoquest/presentation/game/strategies/interaction/interaction_strategy.dart';

class DragInteractionStrategy implements InteractionStrategy {
  int? _selectedInventoryValue;

  @override
  Set<String> get selectedNodeIds => const {};

  @override
  int? get selectedInventoryValue => _selectedInventoryValue;

  @override
  GameAction? handleInventoryTap(int value) {
    _selectedInventoryValue = value;
    return null;
  }

  @override
  GameAction? handleNodeTap(String nodeId) {
    final selectedValue = _selectedInventoryValue;

    if (selectedValue == null) {
      return null;
    }

    _selectedInventoryValue = null;

    return SetValueAction(slotId: nodeId, value: selectedValue);
  }

  @override
  GameAction? handleEdgeTap(String sourceNodeId, String targetNodeId) {
    return null;
  }

  @override
  void clearSelection() {
    _selectedInventoryValue = null;
  }
}
