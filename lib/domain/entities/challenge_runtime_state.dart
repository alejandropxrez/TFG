import 'package:algoquest/domain/entities/structure_state.dart';

/// Base type for the mutable runtime state of a challenge.
///
/// Each concrete subtype represents the transient state required by a
/// particular challenge category while the user is interacting with it.
///
/// This hierarchy is sealed so that all supported runtime state variants are
/// known at compile time and can be handled exhaustively with pattern matching.
sealed class ChallengeRuntimeState {
  const ChallengeRuntimeState();
}

/// Runtime state for challenges based on editable data structures.
///
/// Stores the current structure, the undo/redo history, and the number of
/// moves performed during the current challenge session.
class StructureRuntimeState extends ChallengeRuntimeState {
  /// Current structure displayed and manipulated by the user.
  final StructureState structure;

  /// Previous structure states available for undo operations.
  ///
  /// The most recent snapshot is expected to be stored at the end of the list.
  final List<StructureState> history;

  /// Structure states that can be restored through redo operations.
  ///
  /// This stack is typically cleared when a new action is executed after an
  /// undo operation.
  final List<StructureState> redoStack;

  /// Number of valid structure-modifying moves performed by the user.
  final int movesUsed;

  const StructureRuntimeState({
    required this.structure,
    this.history = const [],
    this.redoStack = const [],
    this.movesUsed = 0,
  });

  /// Creates a new runtime state with selected values replaced.
  ///
  /// Fields that are not provided retain their current value.
  StructureRuntimeState copyWith({
    StructureState? structure,
    List<StructureState>? history,
    List<StructureState>? redoStack,
    int? movesUsed,
  }) {
    return StructureRuntimeState(
      structure: structure ?? this.structure,
      history: history ?? this.history,
      redoStack: redoStack ?? this.redoStack,
      movesUsed: movesUsed ?? this.movesUsed,
    );
  }
}

/// Runtime state for single-choice and multiple-choice quiz challenges.
class QuizRuntimeState extends ChallengeRuntimeState {
  /// Identifiers of the options currently selected by the user.
  final Set<String> selectedOptionIds;

  /// Whether the current selection has been submitted for evaluation.
  ///
  /// In multiple-choice challenges this becomes `false` again when all
  /// options are deselected.
  final bool submitted;

  const QuizRuntimeState({
    this.selectedOptionIds = const {},
    this.submitted = false,
  });

  /// Creates a new quiz state with selected values replaced.
  QuizRuntimeState copyWith({Set<String>? selectedOptionIds, bool? submitted}) {
    return QuizRuntimeState(
      selectedOptionIds: selectedOptionIds ?? this.selectedOptionIds,
      submitted: submitted ?? this.submitted,
    );
  }
}

/// Runtime state for challenges where the user identifies nodes or edges.
class IdentifyTargetRuntimeState extends ChallengeRuntimeState {
  /// Structure rendered as the visual context of the challenge.
  ///
  /// This state is kept separately from the selected targets because the
  /// structure itself is not modified during an identification challenge.
  final StructureState visualState;

  /// Identifiers of the currently selected nodes or edges.
  final Set<String> selectedTargetIds;

  /// Whether the selected targets have been submitted for evaluation.
  final bool submitted;

  const IdentifyTargetRuntimeState({
    required this.visualState,
    this.selectedTargetIds = const {},
    this.submitted = false,
  });

  /// Creates a new identification state with selected values replaced.
  IdentifyTargetRuntimeState copyWith({
    StructureState? visualState,
    Set<String>? selectedTargetIds,
    bool? submitted,
  }) {
    return IdentifyTargetRuntimeState(
      visualState: visualState ?? this.visualState,
      selectedTargetIds: selectedTargetIds ?? this.selectedTargetIds,
      submitted: submitted ?? this.submitted,
    );
  }
}

/// Runtime state for categorization challenges.
///
/// The map stores the selected category identifier for each challenge item.
class CategorizeRuntimeState extends ChallengeRuntimeState {
  /// Mapping from item identifiers to their currently selected category.
  ///
  /// Items that have not yet been classified are absent from the map.
  final Map<String, String> selectedCategoryByItemId;

  const CategorizeRuntimeState({this.selectedCategoryByItemId = const {}});

  /// Creates a new categorization state with the mapping replaced.
  CategorizeRuntimeState copyWith({
    Map<String, String>? selectedCategoryByItemId,
  }) {
    return CategorizeRuntimeState(
      selectedCategoryByItemId:
          selectedCategoryByItemId ?? this.selectedCategoryByItemId,
    );
  }
}
