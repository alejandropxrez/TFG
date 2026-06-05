import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:algoquest/domain/entities/challenge_spec.dart';
import 'package:algoquest/domain/enums/structure_type.dart';

part 'challenge_model.freezed.dart';
part 'challenge_model.g.dart';

@freezed
abstract class ChallengeModel with _$ChallengeModel {
  const factory ChallengeModel({
    required ChallengeMetadataModel metadata,
    required ChallengeEngineConfigModel engineConfig,
    required ChallengeInitialStateModel initialState,
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

LayoutStrategyType _layoutFromJson(String value) {
  switch (value.trim().toUpperCase()) {
    case 'PYRAMID':
      return LayoutStrategyType.pyramid;
    case 'LINEAR':
      return LayoutStrategyType.linear;
    default:
      throw FormatException('Unknown layout strategy: $value');
  }
}

String _layoutToJson(LayoutStrategyType value) {
  switch (value) {
    case LayoutStrategyType.pyramid:
      return 'PYRAMID';
    case LayoutStrategyType.linear:
      return 'LINEAR';
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
  }
}

@freezed
abstract class ChallengeEngineConfigModel with _$ChallengeEngineConfigModel {
  const factory ChallengeEngineConfigModel({
    @JsonKey(fromJson: _structureTypeFromJson, toJson: _structureTypeToJson)
    required StructureType structureType,

    @JsonKey(fromJson: _validationFromJson, toJson: _validationToJson)
    required ValidationStrategyType validationStrategy,

    @JsonKey(fromJson: _layoutFromJson, toJson: _layoutToJson)
    required LayoutStrategyType layoutStrategy,

    @JsonKey(fromJson: _interactionFromJson, toJson: _interactionToJson)
    required InteractionModeType interactionMode,

    @JsonKey(
      name: 'connectionType',
      fromJson: _connectionTypeFromJson,
      toJson: _connectionTypeToJson,
    )
    @Default(ConnectionType.explicit)
    ConnectionType connectionType,

    @Default(<ChallengeConstraintModel>[])
    List<ChallengeConstraintModel> constraints,
  }) = _ChallengeEngineConfigModel;

  factory ChallengeEngineConfigModel.fromJson(Map<String, dynamic> json) =>
      _$ChallengeEngineConfigModelFromJson(json);
}

ConnectionType _connectionTypeFromJson(String? value) {
  switch (value?.trim().toUpperCase()) {
    case null:
    case '':
    case 'EXPLICIT':
      return ConnectionType.explicit;
    case 'IMPLICIT':
      return ConnectionType.implicit;
    case 'NONE':
      return ConnectionType.none;
    default:
      throw FormatException('Unknown connection type: $value');
  }
}

String _connectionTypeToJson(ConnectionType value) {
  switch (value) {
    case ConnectionType.implicit:
      return 'IMPLICIT';
    case ConnectionType.explicit:
      return 'EXPLICIT';
    case ConnectionType.none:
      return 'NONE';
  }
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
