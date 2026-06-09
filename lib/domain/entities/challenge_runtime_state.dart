import 'package:algoquest/domain/entities/structure_state.dart';

sealed class ChallengeRuntimeState {
  const ChallengeRuntimeState();
}

class StructureRuntimeState extends ChallengeRuntimeState {
  final StructureState structure;
  final List<StructureState> history;
  final List<StructureState> redoStack;
  final int movesUsed;

  const StructureRuntimeState({
    required this.structure,
    this.history = const [],
    this.redoStack = const [],
    this.movesUsed = 0,
  });

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

class QuizRuntimeState extends ChallengeRuntimeState {
  final Set<String> selectedOptionIds;
  final bool submitted;

  const QuizRuntimeState({
    this.selectedOptionIds = const {},
    this.submitted = false,
  });

  QuizRuntimeState copyWith({Set<String>? selectedOptionIds, bool? submitted}) {
    return QuizRuntimeState(
      selectedOptionIds: selectedOptionIds ?? this.selectedOptionIds,
      submitted: submitted ?? this.submitted,
    );
  }
}

class IdentifyTargetRuntimeState extends ChallengeRuntimeState {
  final StructureState visualState;
  final Set<String> selectedTargetIds;
  final bool submitted;

  const IdentifyTargetRuntimeState({
    required this.visualState,
    this.selectedTargetIds = const {},
    this.submitted = false,
  });

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
