import 'package:algoquest/domain/entities/identify_target_spec.dart';
import 'package:flutter/material.dart';

class InteractiveBinaryTreeNode {
  final String id;
  final String value;
  final InteractiveBinaryTreeNode? left;
  final InteractiveBinaryTreeNode? right;

  const InteractiveBinaryTreeNode({
    required this.id,
    required this.value,
    this.left,
    this.right,
  });
}

class InteractiveBinaryTree extends StatelessWidget {
  final InteractiveBinaryTreeNode root;
  final IdentifyTargetType targetType;
  final Set<String> selectedTargetIds;
  final bool allowMultiple;
  final ValueChanged<Set<String>> onSelectionChanged;

  const InteractiveBinaryTree({
    super.key,
    required this.root,
    required this.targetType,
    required this.selectedTargetIds,
    required this.allowMultiple,
    required this.onSelectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: 360,
          height: 360,
          child: _BinaryTreeCanvas(
            root: root,
            targetType: targetType,
            selectedTargetIds: selectedTargetIds,
            allowMultiple: allowMultiple,
            onSelectionChanged: onSelectionChanged,
          ),
        ),
      ),
    );
  }
}

class _BinaryTreeCanvas extends StatelessWidget {
  final InteractiveBinaryTreeNode root;
  final IdentifyTargetType targetType;
  final Set<String> selectedTargetIds;
  final bool allowMultiple;
  final ValueChanged<Set<String>> onSelectionChanged;

  const _BinaryTreeCanvas({
    required this.root,
    required this.targetType,
    required this.selectedTargetIds,
    required this.allowMultiple,
    required this.onSelectionChanged,
  });

  static const double _nodeSize = 70;

  bool get _isSelectingNodes => targetType == IdentifyTargetType.node;
  bool get _isSelectingEdges => targetType == IdentifyTargetType.edge;

  @override
  Widget build(BuildContext context) {
    final positionedNodes = _layoutTree(root);
    final positionedEdges = _positionedEdges(positionedNodes);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: _BinaryTreeConnectorPainter(
              nodes: positionedNodes,
              targetType: targetType,
              selectedTargetIds: selectedTargetIds,
            ),
          ),
        ),

        if (_isSelectingEdges)
          for (final edge in positionedEdges)
            _EdgeHitTarget(edge: edge, onTap: () => _toggleSelection(edge.id)),

        for (final positionedNode in positionedNodes)
          Positioned(
            left: positionedNode.x - _nodeSize / 2,
            top: positionedNode.y - _nodeSize / 2,
            width: _nodeSize,
            height: _nodeSize,
            child: _BinaryTreeNodeButton(
              value: positionedNode.node.value,
              selected:
                  _isSelectingNodes &&
                  selectedTargetIds.contains(positionedNode.node.id),
              enabled: _isSelectingNodes,
              onTap: () => _toggleSelection(positionedNode.node.id),
            ),
          ),
      ],
    );
  }

  void _toggleSelection(String targetId) {
    if (allowMultiple) {
      final next = {...selectedTargetIds};

      if (next.contains(targetId)) {
        next.remove(targetId);
      } else {
        next.add(targetId);
      }

      onSelectionChanged(next);
      return;
    }

    onSelectionChanged({targetId});
  }

  List<_PositionedTreeNode> _layoutTree(InteractiveBinaryTreeNode root) {
    final result = <_PositionedTreeNode>[];

    void visit(
      InteractiveBinaryTreeNode node, {
      required double x,
      required double y,
      required double horizontalGap,
    }) {
      result.add(_PositionedTreeNode(node: node, x: x, y: y));

      final nextY = y + 74;

      if (node.left != null) {
        visit(
          node.left!,
          x: x - horizontalGap,
          y: nextY,
          horizontalGap: horizontalGap * 0.55,
        );
      }

      if (node.right != null) {
        visit(
          node.right!,
          x: x + horizontalGap,
          y: nextY,
          horizontalGap: horizontalGap * 0.55,
        );
      }
    }

    visit(root, x: 180, y: 28, horizontalGap: 92);

    return result;
  }

  List<_PositionedTreeEdge> _positionedEdges(List<_PositionedTreeNode> nodes) {
    final nodesById = {for (final node in nodes) node.node.id: node};

    final edges = <_PositionedTreeEdge>[];

    for (final parent in nodes) {
      for (final childNode in [parent.node.left, parent.node.right]) {
        if (childNode == null) continue;

        final child = nodesById[childNode.id];
        if (child == null) continue;

        edges.add(
          _PositionedTreeEdge(
            id: _edgeId(parent.node.id, child.node.id),
            sourceId: parent.node.id,
            targetId: child.node.id,
            start: Offset(parent.x, parent.y),
            end: Offset(child.x, child.y),
          ),
        );
      }
    }

    return edges;
  }
}

class _BinaryTreeNodeButton extends StatelessWidget {
  final String value;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  const _BinaryTreeNodeButton({
    required this.value,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final nodeFillColor = selected
        ? const Color(0xFFFFE3DA)
        : const Color(0xFFF0E7FF);

    final nodeBorderColor = selected
        ? const Color(0xFFFF3D3D)
        : const Color(0xFF6B3DEB);

    final textColor = selected
        ? const Color(0xFFE51F1F)
        : const Color(0xFF101235);

    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: SizedBox(
        width: 96,
        height: 96,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: nodeFillColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: nodeBorderColor,
                  width: selected ? 3 : 2,
                ),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: const Color(
                            0xFFFF3D3D,
                          ).withValues(alpha: 0.18),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
            ),
            Transform.translate(
              offset: const Offset(0, -2),
              child: Text(
                value,
                style: TextStyle(
                  color: textColor,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EdgeHitTarget extends StatelessWidget {
  final _PositionedTreeEdge edge;
  final VoidCallback onTap;

  const _EdgeHitTarget({required this.edge, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: edge.bounds.left,
      top: edge.bounds.top,
      width: edge.bounds.width,
      height: edge.bounds.height,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: onTap,
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _BinaryTreeConnectorPainter extends CustomPainter {
  final List<_PositionedTreeNode> nodes;
  final IdentifyTargetType targetType;
  final Set<String> selectedTargetIds;

  const _BinaryTreeConnectorPainter({
    required this.nodes,
    required this.targetType,
    required this.selectedTargetIds,
  });

  bool get _isSelectingEdges => targetType == IdentifyTargetType.edge;

  @override
  void paint(Canvas canvas, Size size) {
    final nodesById = {for (final node in nodes) node.node.id: node};

    for (final positionedNode in nodes) {
      final parent = positionedNode;

      for (final childNode in [
        positionedNode.node.left,
        positionedNode.node.right,
      ]) {
        if (childNode == null) continue;

        final child = nodesById[childNode.id];
        if (child == null) continue;

        final edgeId = _edgeId(parent.node.id, child.node.id);
        final selected =
            _isSelectingEdges && selectedTargetIds.contains(edgeId);

        final paint = Paint()
          ..color = selected ? const Color(0xFFFF3D3D) : const Color(0xFF6B3DEB)
          ..strokeWidth = selected ? 4 : 2.2
          ..strokeCap = StrokeCap.round;

        canvas.drawLine(
          Offset(parent.x, parent.y),
          Offset(child.x, child.y),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _BinaryTreeConnectorPainter oldDelegate) {
    return oldDelegate.nodes != nodes ||
        oldDelegate.targetType != targetType ||
        oldDelegate.selectedTargetIds != selectedTargetIds;
  }
}

class _PositionedTreeNode {
  final InteractiveBinaryTreeNode node;
  final double x;
  final double y;

  const _PositionedTreeNode({
    required this.node,
    required this.x,
    required this.y,
  });
}

class _PositionedTreeEdge {
  final String id;
  final String sourceId;
  final String targetId;
  final Offset start;
  final Offset end;

  const _PositionedTreeEdge({
    required this.id,
    required this.sourceId,
    required this.targetId,
    required this.start,
    required this.end,
  });

  Rect get bounds {
    const extraPadding = 18.0;

    return Rect.fromLTRB(
      start.dx < end.dx ? start.dx : end.dx,
      start.dy < end.dy ? start.dy : end.dy,
      start.dx > end.dx ? start.dx : end.dx,
      start.dy > end.dy ? start.dy : end.dy,
    ).inflate(extraPadding);
  }
}

String _edgeId(String sourceId, String targetId) {
  return '$sourceId->$targetId';
}
