import 'package:algoquest/domain/entities/game_action.dart';

abstract class InteractionStrategy {
  String? get selectedNodeId;

  GameAction? handleNodeTap(String nodeId);
}
