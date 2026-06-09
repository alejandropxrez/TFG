import 'package:algoquest/domain/entities/game_action.dart';
import 'package:algoquest/presentation/game/strategies/interaction/interaction_strategy.dart';

class IdentifyInteractionStrategy implements InteractionStrategy {
  final Set<String> selectedTargetIds;
  final bool allowMultiple;
  final void Function(Set<String> selectedTargetIds) onSelectionChanged;

  const IdentifyInteractionStrategy({
    required this.selectedTargetIds,
    required this.allowMultiple,
    required this.onSelectionChanged,
  });

  @override
  Set<String> get selectedNodeIds => selectedTargetIds;

  @override
  int? get selectedInventoryValue => null;

  @override
  GameAction? handleNodeTap(String nodeId) {
    final nextSelection = allowMultiple
        ? (selectedTargetIds.contains(nodeId)
              ? ({...selectedTargetIds}..remove(nodeId))
              : {...selectedTargetIds, nodeId})
        : {nodeId};

    onSelectionChanged(nextSelection);

    return null;
  }

  @override
  GameAction? handleEdgeTap(String sourceNodeId, String targetNodeId) => null;

  @override
  GameAction? handleInventoryTap(int value) => null;
}
