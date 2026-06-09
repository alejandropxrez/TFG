import 'package:algoquest/domain/entities/game_action.dart';

abstract class InteractionStrategy {
  Set<String> get selectedNodeIds;
  int? get selectedInventoryValue => null;

  GameAction? handleNodeTap(String nodeId) => null;
  GameAction? handleInventoryTap(int value) => null;
  GameAction? handleEdgeTap(String sourceNodeId, String targetNodeId) => null;
}
