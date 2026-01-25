import 'package:freezed_annotation/freezed_annotation.dart';

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

enum LayoutStrategyType { pyramid, linear }

enum ConnectionStrategyType { implicitHeap, explicit }

enum InteractionModeType { swap, drag }

enum ValidationStrategyType { maxHeap, minHeap, bst }

LayoutStrategyType _layoutFromJson(String value) {
  switch (value.toUpperCase()) {
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

ConnectionStrategyType _connectionFromJson(String value) {
  switch (value.toUpperCase()) {
    case 'IMPLICIT_HEAP':
      return ConnectionStrategyType.implicitHeap;
    case 'EXPLICIT':
      return ConnectionStrategyType.explicit;
    default:
      throw FormatException('Unknown connection strategy: $value');
  }
}

String _connectionToJson(ConnectionStrategyType value) {
  switch (value) {
    case ConnectionStrategyType.implicitHeap:
      return 'IMPLICIT_HEAP';
    case ConnectionStrategyType.explicit:
      return 'EXPLICIT';
  }
}

InteractionModeType _interactionFromJson(String value) {
  switch (value.toUpperCase()) {
    case 'SWAP':
      return InteractionModeType.swap;
    case 'DRAG':
      return InteractionModeType.drag;
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
  }
}

ValidationStrategyType _validationFromJson(String value) {
  switch (value.toUpperCase()) {
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
    /// Used by domain to instantiate ValidationStrategy
    @JsonKey(fromJson: _validationFromJson, toJson: _validationToJson)
    required ValidationStrategyType validationStrategy,

    /// Used by VisualSceneBuilder
    @JsonKey(fromJson: _layoutFromJson, toJson: _layoutToJson)
    required LayoutStrategyType layoutStrategy,

    @JsonKey(fromJson: _connectionFromJson, toJson: _connectionToJson)
    required ConnectionStrategyType connectionStrategy,

    @JsonKey(fromJson: _interactionFromJson, toJson: _interactionToJson)
    required InteractionModeType interactionMode,

    /// Typed, extensible constraint rules
    @Default(<ChallengeConstraintModel>[])
    List<ChallengeConstraintModel> constraints,
  }) = _ChallengeEngineConfigModel;

  factory ChallengeEngineConfigModel.fromJson(Map<String, dynamic> json) =>
      _$ChallengeEngineConfigModelFromJson(json);
}

@Freezed(unionKey: 'type')
sealed class ChallengeConstraintModel with _$ChallengeConstraintModel {
  const ChallengeConstraintModel._();

  /// JSON:
  /// { "type": "MAX_MOVES", "maxMoves": 5 }
  @FreezedUnionValue('MAX_MOVES')
  const factory ChallengeConstraintModel.maxMoves({required int maxMoves}) =
      MaxMovesConstraintModel;

  /// JSON:
  /// { "type": "LOCKED_NODES", "nodeIds": ["n1", "n3"] }
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

    /// Only used if connectionStrategy == explicit
    @Default(<ChallengeEdgeModel>[]) List<ChallengeEdgeModel> edges,

    /// Used for fill-in-the-blanks challenges
    @Default(<ChallengeSlotModel>[]) List<ChallengeSlotModel> slots,
  }) = _ChallengeInitialStateModel;

  factory ChallengeInitialStateModel.fromJson(Map<String, dynamic> json) =>
      _$ChallengeInitialStateModelFromJson(json);
}

@freezed
abstract class ChallengeNodeModel with _$ChallengeNodeModel {
  const factory ChallengeNodeModel({required String id, required int value}) =
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
