import 'package:algoquest/domain/entities/challenge_runtime_state.dart';
import 'package:algoquest/domain/entities/challenge_spec.dart';
import 'package:algoquest/domain/entities/game_action.dart';
import 'package:algoquest/domain/entities/structure_state.dart';
import 'package:algoquest/domain/enums/structure_type.dart';
import 'package:algoquest/presentation/application_state/level_state_provider.dart';
import 'package:algoquest/presentation/game/algoquest_game.dart';
import 'package:algoquest/presentation/widgets/challenge/categorize_challenge_body.dart';
import 'package:algoquest/presentation/widgets/challenge/components/interactive_binary_tree.dart';
import 'package:algoquest/presentation/widgets/challenge/identify_target_challenge_body.dart';
import 'package:algoquest/presentation/widgets/challenge/components/structure_flame_challenge_body.dart';
import 'package:algoquest/presentation/widgets/challenge/components/unsupported_challenge_body.dart';
import 'package:algoquest/presentation/widgets/quiz_challenge_view.dart';
import 'package:algoquest/presentation/widgets/challenge/components/linked_list_slots_challenge_body.dart';
import 'package:flutter/material.dart';

abstract final class ChallengeBodyFactory {
  static Widget build({
    required ChallengeSpec spec,
    required ChallengeRuntimeState runtimeState,
    required AlgoQuestGame game,
    required LevelStateNotifier notifier,
  }) {
    return switch ((spec.content, runtimeState)) {
      (
        QuizChallengeContent(:final quizSpec),
        QuizRuntimeState(:final selectedOptionIds),
      ) =>
        QuizChallengeView(
          quizSpec: quizSpec,
          selectedOptionIds: selectedOptionIds,
          onSelectOption: (optionId) {
            notifier.submitQuizAnswer(
              _nextQuizSelection(
                optionId: optionId,
                selectedOptionIds: selectedOptionIds,
                allowMultiple: quizSpec.allowMultiple,
              ),
            );
          },
        ),

      (
        CategorizeChallengeContent(:final categorizeSpec),
        CategorizeRuntimeState(:final selectedCategoryByItemId),
      ) =>
        CategorizeChallengeBody(
          categorizeSpec: categorizeSpec,
          selectedCategoryByItemId: selectedCategoryByItemId,
          onCategorySelected:
              ({required String itemId, required String categoryId}) {
                notifier.submitCategorization(
                  itemId: itemId,
                  categoryId: categoryId,
                );
              },
        ),

      (
        final IdentifyTargetChallengeContent content,
        final IdentifyTargetRuntimeState runtimeState,
      ) =>
        _buildIdentifyTargetBody(
          content: content,
          runtimeState: runtimeState,
          notifier: notifier,
        ),

      (
        final StructureChallengeContent content,
        final StructureRuntimeState runtimeState,
      )
          when content.engineConfig.structureType == StructureType.linkedList =>
        LinkedListSlotsChallengeBody(
          structure: runtimeState.structure,
          onValueDropped: ({required String slotId, required int value}) {
            notifier.executeAction(
              SetValueAction(slotId: slotId, value: value),
            );
          },
        ),

      (StructureChallengeContent(), StructureRuntimeState()) =>
        StructureFlameChallengeBody(game: game),

      _ => const UnsupportedChallengeBody(),
    };
  }

  static Set<String> _nextQuizSelection({
    required String optionId,
    required Set<String> selectedOptionIds,
    required bool allowMultiple,
  }) {
    if (!allowMultiple) {
      return {optionId};
    }

    final nextSelection = {...selectedOptionIds};

    if (nextSelection.contains(optionId)) {
      nextSelection.remove(optionId);
    } else {
      nextSelection.add(optionId);
    }

    return nextSelection;
  }

  static Widget _buildIdentifyTargetBody({
    required IdentifyTargetChallengeContent content,
    required IdentifyTargetRuntimeState runtimeState,
    required LevelStateNotifier notifier,
  }) {
    final root = _interactiveTreeFromStructure(runtimeState.visualState);

    if (root == null) {
      return const UnsupportedChallengeBody();
    }

    return IdentifyTargetChallengeBody(
      root: root,
      targetType: content.identifySpec.targetType,
      selectedTargetIds: runtimeState.selectedTargetIds,
      allowMultiple: content.identifySpec.allowMultiple,
      onSelectionChanged: notifier.submitIdentifyTarget,
    );
  }

  static InteractiveBinaryTreeNode? _interactiveTreeFromStructure(
    StructureState structure,
  ) {
    if (structure.nodes.isEmpty) {
      return null;
    }

    final childrenByParentId = <String, List<String>>{};

    for (final edge in structure.edges) {
      childrenByParentId.putIfAbsent(edge.source, () => []).add(edge.target);
    }

    final childIds = {for (final edge in structure.edges) edge.target};

    final rootState = structure.nodes.values.firstWhere(
      (node) => !childIds.contains(node.id),
      orElse: () => structure.nodes.values.first,
    );

    InteractiveBinaryTreeNode buildNode(String nodeId) {
      final node = structure.nodes[nodeId];

      if (node == null) {
        return InteractiveBinaryTreeNode(id: nodeId, value: '?');
      }

      final children = childrenByParentId[nodeId] ?? const <String>[];

      return InteractiveBinaryTreeNode(
        id: node.id,
        value: node.value?.toString() ?? '',
        left: children.isNotEmpty ? buildNode(children[0]) : null,
        right: children.length > 1 ? buildNode(children[1]) : null,
      );
    }

    return buildNode(rootState.id);
  }
}
