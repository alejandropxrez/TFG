sealed class GameAction {
  const GameAction();
}

class SwapNodesAction extends GameAction {
  final String aId;
  final String bId;
  const SwapNodesAction({required this.aId, required this.bId});
}

class DragNodeToSlotAction extends GameAction {
  final String nodeId;
  final String slotId;
  const DragNodeToSlotAction({required this.nodeId, required this.slotId});
}
