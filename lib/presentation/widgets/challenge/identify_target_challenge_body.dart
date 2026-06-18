import 'package:algoquest/domain/entities/identify_target_spec.dart';
import 'package:algoquest/presentation/widgets/challenge/components/interactive_binary_tree.dart';
import 'package:flutter/material.dart';

class IdentifyTargetChallengeBody extends StatelessWidget {
  final InteractiveBinaryTreeNode root;
  final IdentifyTargetType targetType;
  final Set<String> selectedTargetIds;
  final bool allowMultiple;
  final ValueChanged<Set<String>> onSelectionChanged;

  const IdentifyTargetChallengeBody({
    super.key,
    required this.root,
    required this.targetType,
    required this.selectedTargetIds,
    required this.allowMultiple,
    required this.onSelectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InteractiveBinaryTree(
      root: root,
      targetType: targetType,
      selectedTargetIds: selectedTargetIds,
      allowMultiple: allowMultiple,
      onSelectionChanged: onSelectionChanged,
    );
  }
}
