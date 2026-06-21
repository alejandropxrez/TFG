// Freezed copies JsonKey annotations from factory parameters to generated fields.
// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:algoquest/domain/entities/challenge_spec.dart';
import 'package:algoquest/domain/enums/structure_type.dart';

part 'challenge_model.freezed.dart';
part 'challenge_model.g.dart';

@freezed
abstract class ChallengeModel with _$ChallengeModel {
  const factory ChallengeModel({
    @JsonKey(fromJson: _challengeKindFromJson, toJson: _challengeKindToJson)
    @Default(ChallengeKindModel.structure)
    ChallengeKindModel kind,

    required ChallengeMetadataModel metadata,

    ChallengeEngineConfigModel? engineConfig,

    ChallengeInitialStateModel? initialState,

    @Default([]) List<ChallengeConstraintModel> constraints,

    QuizModel? quiz,
    CategorizeModel? categorize,
    IdentifyTargetModel? identifyTarget,

    ChallengeSolutionModel? solution,
  }) = _ChallengeModel;

  factory ChallengeModel.fromJson(Map<String, dynamic> json) =>
      _$ChallengeModelFromJson(json);
}

@freezed
abstract class ChallengeMetadataModel with _$ChallengeMetadataModel {
  const factory ChallengeMetadataModel({
    /// User-facing title (e.g. "Reparación de Heap")
    required String title,

    /// Short instruction (e.g. "Arrastra para corregir")
    required String instruction,

    /// Optional theory/help reference
    String? theoryRef,
  }) = _ChallengeMetadataModel;

  factory ChallengeMetadataModel.fromJson(Map<String, dynamic> json) =>
      _$ChallengeMetadataModelFromJson(json);
}

StructureType _structureTypeFromJson(String value) {
  switch (value.trim().toUpperCase()) {
    case 'HEAP':
      return StructureType.heap;
    case 'BST':
      return StructureType.bst;
    case 'GRAPH':
      return StructureType.graph;
    case 'LINKED_LIST':
      return StructureType.linkedList;
    default:
      throw FormatException('Unknown structure type: $value');
  }
}

String _structureTypeToJson(StructureType value) {
  switch (value) {
    case StructureType.heap:
      return 'HEAP';
    case StructureType.bst:
      return 'BST';
    case StructureType.graph:
      return 'GRAPH';
    case StructureType.linkedList:
      return 'LINKED_LIST';
  }
}

LayoutStrategyType _layoutStrategyFromJson(String value) {
  switch (value.trim().toUpperCase()) {
    case 'PYRAMID':
      return LayoutStrategyType.pyramid;
    case 'LINEAR':
      return LayoutStrategyType.linear;
    case 'CIRCULAR':
      return LayoutStrategyType.circular;
    case 'FREE':
      return LayoutStrategyType.free;
    default:
      throw FormatException('Unknown layout strategy: $value');
  }
}

String _layoutStrategyToJson(LayoutStrategyType value) {
  switch (value) {
    case LayoutStrategyType.pyramid:
      return 'PYRAMID';
    case LayoutStrategyType.linear:
      return 'LINEAR';
    case LayoutStrategyType.circular:
      return 'CIRCULAR';
    case LayoutStrategyType.free:
      return 'FREE';
  }
}

InteractionModeType _interactionFromJson(String value) {
  switch (value.trim().toUpperCase()) {
    case 'SWAP':
      return InteractionModeType.swap;
    case 'DRAG':
      return InteractionModeType.drag;
    case 'SET_VALUE':
      return InteractionModeType.setValue;
    case 'LINK':
      return InteractionModeType.link;
    default:
      throw FormatException('Unknown interaction mode: $value');
  }
}

String _interactionToJson(InteractionModeType value) {
  switch (value) {
    case InteractionModeType.swap:
      return 'SWAP';
    case InteractionModeType.drag:
      return 'DRAG';
    case InteractionModeType.setValue:
      return 'SET_VALUE';
    case InteractionModeType.link:
      return 'LINK';
  }
}

ValidationStrategyType _validationFromJson(String value) {
  switch (value.trim().toUpperCase()) {
    case 'MAX_HEAP':
      return ValidationStrategyType.maxHeap;
    case 'MIN_HEAP':
      return ValidationStrategyType.minHeap;
    case 'BST':
      return ValidationStrategyType.bst;
    case 'CONNECTED_GRAPH':
      return ValidationStrategyType.connectedGraph;
    case 'LINKED_LIST':
      return ValidationStrategyType.linkedList;
    case 'ORDERED_SEQUENCE':
      return ValidationStrategyType.orderedSequence;
    case 'EXPECTED_SLOT_VALUES':
      return ValidationStrategyType.expectedSlotValues;
    default:
      throw FormatException('Unknown validation strategy: $value');
  }
}

String _validationToJson(ValidationStrategyType value) {
  switch (value) {
    case ValidationStrategyType.maxHeap:
      return 'MAX_HEAP';
    case ValidationStrategyType.minHeap:
      return 'MIN_HEAP';
    case ValidationStrategyType.bst:
      return 'BST';
    case ValidationStrategyType.connectedGraph:
      return 'CONNECTED_GRAPH';
    case ValidationStrategyType.linkedList:
      return 'LINKED_LIST';
    case ValidationStrategyType.orderedSequence:
      return 'ORDERED_SEQUENCE';
    case ValidationStrategyType.expectedSlotValues:
      return 'EXPECTED_SLOT_VALUES';
  }
}

@freezed
abstract class ChallengeEngineConfigModel with _$ChallengeEngineConfigModel {
  const factory ChallengeEngineConfigModel({
    @JsonKey(fromJson: _structureTypeFromJson, toJson: _structureTypeToJson)
    required StructureType structureType,

    @JsonKey(fromJson: _validationFromJson, toJson: _validationToJson)
    required ValidationStrategyType validationStrategy,

    @JsonKey(fromJson: _layoutStrategyFromJson, toJson: _layoutStrategyToJson)
    required LayoutStrategyType layoutStrategy,

    @JsonKey(fromJson: _interactionFromJson, toJson: _interactionToJson)
    required InteractionModeType interactionMode,

    @Default(<ChallengeConstraintModel>[])
    List<ChallengeConstraintModel> constraints,
  }) = _ChallengeEngineConfigModel;

  factory ChallengeEngineConfigModel.fromJson(Map<String, dynamic> json) =>
      _$ChallengeEngineConfigModelFromJson(json);
}

@Freezed(unionKey: 'type')
sealed class ChallengeConstraintModel with _$ChallengeConstraintModel {
  const ChallengeConstraintModel._();

  @FreezedUnionValue('MAX_MOVES')
  const factory ChallengeConstraintModel.maxMoves({required int maxMoves}) =
      MaxMovesConstraintModel;

  @FreezedUnionValue('LOCKED_NODES')
  const factory ChallengeConstraintModel.lockedNodes({
    required List<String> nodeIds,
  }) = LockedNodesConstraintModel;

  @FreezedUnionValue('MAX_ATTEMPTS')
  const factory ChallengeConstraintModel.maxAttempts({
    required int maxAttempts,
  }) = MaxAttemptsConstraintModel;

  @FreezedUnionValue('LIVES_CONSUMED_ON_FAIL')
  const factory ChallengeConstraintModel.livesConsumedOnFail({
    required int lives,
  }) = LivesConsumedOnFailConstraintModel;

  factory ChallengeConstraintModel.fromJson(Map<String, dynamic> json) =>
      _$ChallengeConstraintModelFromJson(json);
}

@freezed
abstract class ChallengeInitialStateModel with _$ChallengeInitialStateModel {
  const factory ChallengeInitialStateModel({
    required List<ChallengeNodeModel> nodes,
    required List<ChallengeEdgeModel> edges,
    @Default(<ChallengeSlotModel>[]) List<ChallengeSlotModel> slots,
    @Default(<int>[]) List<int> inventory,
  }) = _ChallengeInitialStateModel;

  factory ChallengeInitialStateModel.fromJson(Map<String, dynamic> json) =>
      _$ChallengeInitialStateModelFromJson(json);
}

@freezed
abstract class ChallengeNodeModel with _$ChallengeNodeModel {
  const factory ChallengeNodeModel({required String id, int? value}) =
      _ChallengeNodeModel;

  factory ChallengeNodeModel.fromJson(Map<String, dynamic> json) =>
      _$ChallengeNodeModelFromJson(json);
}

@freezed
abstract class ChallengeEdgeModel with _$ChallengeEdgeModel {
  const factory ChallengeEdgeModel({
    required String source,
    required String target,
  }) = _ChallengeEdgeModel;

  factory ChallengeEdgeModel.fromJson(Map<String, dynamic> json) =>
      _$ChallengeEdgeModelFromJson(json);
}

@freezed
abstract class ChallengeSlotModel with _$ChallengeSlotModel {
  const factory ChallengeSlotModel({
    required String id,
    int? index,
    @Default(<String, dynamic>{}) Map<String, dynamic> props,
  }) = _ChallengeSlotModel;

  factory ChallengeSlotModel.fromJson(Map<String, dynamic> json) =>
      _$ChallengeSlotModelFromJson(json);
}

enum ChallengeKindModel {
  structure,
  singleChoice,
  multipleChoice,
  identifyNode,
  identifyEdge,
  categorize,
}

ChallengeKindModel _challengeKindFromJson(String? value) {
  switch (value?.trim().toUpperCase()) {
    case null:
    case '':
    case 'STRUCTURE':
      return ChallengeKindModel.structure;
    case 'SINGLE_CHOICE':
      return ChallengeKindModel.singleChoice;
    case 'MULTIPLE_CHOICE':
      return ChallengeKindModel.multipleChoice;
    case 'IDENTIFY_NODE':
      return ChallengeKindModel.identifyNode;
    case 'IDENTIFY_EDGE':
      return ChallengeKindModel.identifyEdge;
    case 'CATEGORIZE':
      return ChallengeKindModel.categorize;
    default:
      throw FormatException('Unknown challenge kind: $value');
  }
}

String _challengeKindToJson(ChallengeKindModel kind) {
  switch (kind) {
    case ChallengeKindModel.structure:
      return 'STRUCTURE';
    case ChallengeKindModel.singleChoice:
      return 'SINGLE_CHOICE';
    case ChallengeKindModel.multipleChoice:
      return 'MULTIPLE_CHOICE';
    case ChallengeKindModel.identifyNode:
      return 'IDENTIFY_NODE';
    case ChallengeKindModel.identifyEdge:
      return 'IDENTIFY_EDGE';
    case ChallengeKindModel.categorize:
      return 'CATEGORIZE';
  }
}

@freezed
abstract class QuizModel with _$QuizModel {
  const factory QuizModel({
    required String question,
    required List<QuizOptionModel> options,
    required List<String> correctOptionIds,
    @Default(false) bool allowMultiple,
  }) = _QuizModel;

  factory QuizModel.fromJson(Map<String, dynamic> json) =>
      _$QuizModelFromJson(json);
}

@freezed
abstract class QuizOptionModel with _$QuizOptionModel {
  const factory QuizOptionModel({required String id, required String text}) =
      _QuizOptionModel;

  factory QuizOptionModel.fromJson(Map<String, dynamic> json) =>
      _$QuizOptionModelFromJson(json);
}

enum IdentifyTargetTypeModel { node, edge }

IdentifyTargetTypeModel _identifyTargetTypeFromJson(String value) {
  switch (value.trim().toUpperCase()) {
    case 'NODE':
      return IdentifyTargetTypeModel.node;
    case 'EDGE':
      return IdentifyTargetTypeModel.edge;
    default:
      throw FormatException('Unknown identify target type: $value');
  }
}

String _identifyTargetTypeToJson(IdentifyTargetTypeModel type) {
  switch (type) {
    case IdentifyTargetTypeModel.node:
      return 'NODE';
    case IdentifyTargetTypeModel.edge:
      return 'EDGE';
  }
}

@freezed
abstract class IdentifyTargetModel with _$IdentifyTargetModel {
  const factory IdentifyTargetModel({
    required String prompt,

    @JsonKey(
      fromJson: _identifyTargetTypeFromJson,
      toJson: _identifyTargetTypeToJson,
    )
    required IdentifyTargetTypeModel targetType,

    required List<String> correctTargetIds,

    @Default(false) bool allowMultiple,
  }) = _IdentifyTargetModel;

  factory IdentifyTargetModel.fromJson(Map<String, dynamic> json) =>
      _$IdentifyTargetModelFromJson(json);
}

@freezed
abstract class ChallengeSolutionModel with _$ChallengeSolutionModel {
  const factory ChallengeSolutionModel({
    @Default(<String, int>{}) Map<String, int> expectedSlotValues,
  }) = _ChallengeSolutionModel;

  factory ChallengeSolutionModel.fromJson(Map<String, dynamic> json) =>
      _$ChallengeSolutionModelFromJson(json);
}

@freezed
abstract class CategorizeModel with _$CategorizeModel {
  const factory CategorizeModel({
    required String prompt,
    required List<CategorizeCategoryModel> categories,
    required List<CategorizeItemModel> items,
    required Map<String, String> correctCategoryByItemId,
  }) = _CategorizeModel;

  factory CategorizeModel.fromJson(Map<String, dynamic> json) =>
      _$CategorizeModelFromJson(json);
}

@freezed
abstract class CategorizeCategoryModel with _$CategorizeCategoryModel {
  const factory CategorizeCategoryModel({
    required String id,
    required String label,
  }) = _CategorizeCategoryModel;

  factory CategorizeCategoryModel.fromJson(Map<String, dynamic> json) =>
      _$CategorizeCategoryModelFromJson(json);
}

@freezed
abstract class CategorizeItemModel with _$CategorizeItemModel {
  const factory CategorizeItemModel({
    required String id,
    required String text,
  }) = _CategorizeItemModel;

  factory CategorizeItemModel.fromJson(Map<String, dynamic> json) =>
      _$CategorizeItemModelFromJson(json);
}
