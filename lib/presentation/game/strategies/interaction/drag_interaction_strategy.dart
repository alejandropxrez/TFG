import 'package:algoquest/domain/entities/game_action.dart';
import 'package:algoquest/presentation/game/strategies/interaction/interaction_strategy.dart';

class DragInteractionStrategy implements InteractionStrategy {
  @override
  Set<String> get selectedNodeIds => const {};

  @override
  int? get selectedInventoryValue => null;

  @override
  GameAction? handleEdgeTap(String sourceNodeId, String targetNodeId) => null;

  @override
  GameAction? handleNodeTap(String nodeId) {
    throw UnimplementedError(
      'Drag interaction strategy is not implemented yet.',
    );
  }

  @override
  GameAction? handleInventoryTap(int value) {
    throw UnimplementedError(
      'Drag interaction strategy is not implemented yet.',
    );
  }
}
