import 'package:algoquest/domain/entities/challenge_spec.dart';
import 'package:algoquest/data/models/challenge_model.dart';
import 'package:algoquest/domain/entities/quiz_spec.dart';
import 'package:algoquest/domain/strategies/bst_validation_strategy.dart';
import 'package:algoquest/domain/strategies/max_heap_validation_strategy.dart';
import 'package:algoquest/domain/strategies/min_heap_validation_strategy.dart';
import 'package:algoquest/domain/strategies/validation_strategy.dart';
import 'package:algoquest/domain/strategies/connected_graph_validation_strategy.dart';
import 'package:algoquest/domain/strategies/linked_list_validation_strategy.dart';

class ChallengeMapper {
  static ChallengeSpec toDomain(
    String challengeId,
    ChallengeModel challengeModel,
  ) {
    return switch (challengeModel.kind) {
      ChallengeKindModel.structure => _mapStructureChallenge(
        challengeId,
        challengeModel,
      ),
      ChallengeKindModel.singleChoice => _mapSingleChoiceChallenge(
        challengeId,
        challengeModel,
      ),
      ChallengeKindModel.multipleChoice => _mapMultipleChoiceChallenge(
        challengeId,
        challengeModel,
      ),
    };
  }

  static ChallengeSpec _mapStructureChallenge(
    String challengeId,
    ChallengeModel challengeModel,
  ) {
    final engineConfig = challengeModel.engineConfig;
    final initialState = challengeModel.initialState;

    if (engineConfig == null) {
      throw FormatException('STRUCTURE challenge requires engineConfig.');
    }

    if (initialState == null) {
      throw FormatException('STRUCTURE challenge requires initialState.');
    }

    return ChallengeSpec(
      id: challengeId,
      title: challengeModel.metadata.title,
      instruction: challengeModel.metadata.instruction,
      theoryRef: challengeModel.metadata.theoryRef,
      constraints: _mapConstraints(challengeModel),
      content: StructureChallengeContent(
        engineConfig: ChallengeEngineConfig(
          structureType: engineConfig.structureType,
          validationStrategy: _mapValidationStrategy(
            engineConfig.validationStrategy,
          ),
          layoutStrategy: engineConfig.layoutStrategy,
          interactionMode: engineConfig.interactionMode,
          connectionType: engineConfig.connectionType,
        ),
        initialState: ChallengeInitialStateSpec(
          nodes: initialState.nodes
              .map((node) => ChallengeNodeSpec(id: node.id, value: node.value))
              .toList(growable: false),
          edges: initialState.edges
              .map(
                (edge) =>
                    ChallengeEdgeSpec(source: edge.source, target: edge.target),
              )
              .toList(growable: false),
          slots: initialState.slots
              .map((slot) => ChallengeSlotSpec(id: slot.id, index: slot.index))
              .toList(growable: false),
          inventory: initialState.inventory,
        ),
      ),
    );
  }

  static ChallengeSpec _mapSingleChoiceChallenge(
    String challengeId,
    ChallengeModel challengeModel,
  ) {
    final quiz = challengeModel.quiz;

    if (quiz == null) {
      throw FormatException('SINGLE_CHOICE challenge requires quiz.');
    }

    if (quiz.allowMultiple) {
      throw FormatException(
        'SINGLE_CHOICE challenge cannot have allowMultiple=true.',
      );
    }

    if (quiz.correctOptionIds.length != 1) {
      throw FormatException(
        'SINGLE_CHOICE challenge requires exactly one correct option.',
      );
    }

    final optionIds = quiz.options.map((option) => option.id).toSet();

    if (!optionIds.containsAll(quiz.correctOptionIds)) {
      throw FormatException(
        'SINGLE_CHOICE correctOptionIds must reference existing options.',
      );
    }

    return ChallengeSpec(
      id: challengeId,
      title: challengeModel.metadata.title,
      instruction: challengeModel.metadata.instruction,
      theoryRef: challengeModel.metadata.theoryRef,
      constraints: _mapConstraints(challengeModel),
      content: QuizChallengeContent(
        quizSpec: QuizSpec(
          question: quiz.question,
          options: quiz.options
              .map((option) => QuizOption(id: option.id, text: option.text))
              .toList(growable: false),
          correctOptionIds: quiz.correctOptionIds.toSet(),
          allowMultiple: false,
        ),
      ),
    );
  }

  static ChallengeSpec _mapMultipleChoiceChallenge(
    String challengeId,
    ChallengeModel challengeModel,
  ) {
    final quiz = challengeModel.quiz;

    if (quiz == null) {
      throw FormatException('MULTIPLE_CHOICE challenge requires quiz.');
    }

    if (!quiz.allowMultiple) {
      throw FormatException(
        'MULTIPLE_CHOICE challenge requires allowMultiple=true.',
      );
    }

    if (quiz.correctOptionIds.isEmpty) {
      throw FormatException(
        'MULTIPLE_CHOICE challenge requires at least one correct option.',
      );
    }

    final optionIds = quiz.options.map((option) => option.id).toSet();

    if (!optionIds.containsAll(quiz.correctOptionIds)) {
      throw FormatException(
        'MULTIPLE_CHOICE correctOptionIds must reference existing options.',
      );
    }

    return ChallengeSpec(
      id: challengeId,
      title: challengeModel.metadata.title,
      instruction: challengeModel.metadata.instruction,
      theoryRef: challengeModel.metadata.theoryRef,
      constraints: _mapConstraints(challengeModel),
      content: QuizChallengeContent(
        quizSpec: QuizSpec(
          question: quiz.question,
          options: quiz.options
              .map((option) => QuizOption(id: option.id, text: option.text))
              .toList(growable: false),
          correctOptionIds: quiz.correctOptionIds.toSet(),
          allowMultiple: true,
        ),
      ),
    );
  }

  static List<ChallengeConstraint> _mapConstraints(
    ChallengeModel challengeModel,
  ) {
    final rootConstraints = challengeModel.constraints;

    if (rootConstraints.isNotEmpty) {
      return rootConstraints.map(_mapConstraint).toList(growable: false);
    }

    return challengeModel.engineConfig?.constraints
            .map(_mapConstraint)
            .toList(growable: false) ??
        const [];
  }

  static ChallengeConstraint _mapConstraint(
    ChallengeConstraintModel constraintModel,
  ) {
    return constraintModel.when(
      maxMoves: (maxMoves) => MaxMovesConstraint(maxMoves),
      lockedNodes: (nodeIds) => LockedNodesConstraint(nodeIds),
      maxAttempts: (maxAttempts) => MaxAttemptsConstraint(maxAttempts),
      livesConsumedOnFail: (lives) => LivesConsumedOnFailConstraint(lives),
    );
  }

  static ValidationStrategy _mapValidationStrategy(
    ValidationStrategyType type,
  ) {
    switch (type) {
      case ValidationStrategyType.maxHeap:
        return MaxHeapValidationStrategy();
      case ValidationStrategyType.minHeap:
        return MinHeapValidationStrategy();
      case ValidationStrategyType.bst:
        return BstValidationStrategy();
      case ValidationStrategyType.connectedGraph:
        return ConnectedGraphValidationStrategy();
      case ValidationStrategyType.linkedList:
        return LinkedListValidationStrategy();
    }
  }
}
