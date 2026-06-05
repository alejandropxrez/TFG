import 'package:algoquest/domain/entities/game_action.dart';
import 'package:algoquest/presentation/game/strategies/interaction/interaction_strategy.dart';

class SetValueInteractionStrategy implements InteractionStrategy {
  int? _selectedInventoryValue;
  String? _selectedNodeId;

  @override
  String? get selectedNodeId => _selectedNodeId;

  @override
  int? get selectedInventoryValue => _selectedInventoryValue;

  @override
  GameAction? handleInventoryTap(int value) {
    if (_selectedInventoryValue == value) {
      _selectedInventoryValue = null;
      return null;
    }

    _selectedInventoryValue = value;
    return null;
  }

  @override
  GameAction? handleNodeTap(String nodeId) {
    final value = _selectedInventoryValue;

    if (value == null) {
      _selectedNodeId = nodeId;
      return null;
    }

    _selectedInventoryValue = null;
    _selectedNodeId = null;

    return SetValueAction(slotId: nodeId, value: value);
  }
}
