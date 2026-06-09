import 'package:algoquest/domain/entities/game_action.dart';

abstract class InteractionStrategy {
  Set<String> get selectedNodeIds;

  int? get selectedInventoryValue;

  GameAction? handleNodeTap(String nodeId);

  GameAction? handleInventoryTap(int value);

  GameAction? handleEdgeTap(String sourceNodeId, String targetNodeId);

  void clearSelection() {}
}
