import 'package:algoquest/domain/entities/game_action.dart';

abstract class InteractionStrategy {
  String? get selectedNodeId;
  int? get selectedInventoryValue => null;

  GameAction? handleNodeTap(String nodeId) => null;
  GameAction? handleInventoryTap(int value) => null;
}
