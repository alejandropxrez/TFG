import 'package:algoquest/domain/entities/identify_target_spec.dart';
import 'package:algoquest/presentation/widgets/challenge/identify_target_challenge_body.dart';
import 'package:algoquest/presentation/widgets/challenge/components/interactive_binary_tree.dart';
import 'package:flutter/material.dart';

class BinaryTreeSwapChallengeBody extends StatefulWidget {
  final InteractiveBinaryTreeNode root;
  final void Function({
    required String firstNodeId,
    required String secondNodeId,
  })
  onSwapNodes;

  const BinaryTreeSwapChallengeBody({
    super.key,
    required this.root,
    required this.onSwapNodes,
  });

  @override
  State<BinaryTreeSwapChallengeBody> createState() =>
      _BinaryTreeSwapChallengeBodyState();
}

class _BinaryTreeSwapChallengeBodyState
    extends State<BinaryTreeSwapChallengeBody> {
  Set<String> _selectedNodeIds = const {};

  @override
  Widget build(BuildContext context) {
    return IdentifyTargetChallengeBody(
      root: widget.root,
      targetType: IdentifyTargetType.node,
      selectedTargetIds: _selectedNodeIds,
      allowMultiple: true,
      onSelectionChanged: _handleSelectionChanged,
    );
  }

  void _handleSelectionChanged(Set<String> nextSelection) {
    if (nextSelection.length < 2) {
      setState(() {
        _selectedNodeIds = nextSelection;
      });
      return;
    }

    final selectedIds = nextSelection.take(2).toList(growable: false);

    setState(() {
      _selectedNodeIds = const {};
    });

    widget.onSwapNodes(
      firstNodeId: selectedIds[0],
      secondNodeId: selectedIds[1],
    );
  }
}
