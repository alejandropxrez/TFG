import 'package:algoquest/data/models/challenge_model.dart';
import 'package:algoquest/domain/entities/categorize_spec.dart';
import 'package:algoquest/domain/entities/challenge_spec.dart';
import 'package:algoquest/domain/entities/identify_target_spec.dart';
import 'package:algoquest/domain/entities/quiz_spec.dart';
import 'package:algoquest/domain/strategies/bst_validation_strategy.dart';
import 'package:algoquest/domain/strategies/connected_graph_validation_strategy.dart';
import 'package:algoquest/domain/strategies/expected_slot_values_validation_strategy.dart';
import 'package:algoquest/domain/strategies/linked_list_validation_strategy.dart';
import 'package:algoquest/domain/strategies/max_heap_validation_strategy.dart';
import 'package:algoquest/domain/strategies/min_heap_validation_strategy.dart';
import 'package:algoquest/domain/strategies/ordered_sequence_validation_strategy.dart';
import 'package:algoquest/domain/strategies/validation_strategy.dart';

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
      ChallengeKindModel.identifyNode => _mapIdentifyNodeChallenge(
        challengeId,
        challengeModel,
      ),
      ChallengeKindModel.identifyEdge => _mapIdentifyEdgeChallenge(
        challengeId,
        challengeModel,
      ),
      ChallengeKindModel.categorize => _mapCategorizeChallenge(
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
      content: _mapStructureContent(
        engineConfig: engineConfig,
        initialState: initialState,
        solution: challengeModel.solution,
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

  static ChallengeSpec _mapIdentifyNodeChallenge(
    String challengeId,
    ChallengeModel challengeModel,
  ) {
    final identifyTarget = challengeModel.identifyTarget;
    final engineConfig = challengeModel.engineConfig;
    final initialState = challengeModel.initialState;

    if (identifyTarget == null) {
      throw FormatException('IDENTIFY_NODE challenge requires identifyTarget.');
    }

    if (identifyTarget.targetType != IdentifyTargetTypeModel.node) {
      throw FormatException('IDENTIFY_NODE requires targetType=NODE.');
    }

    if (engineConfig == null) {
      throw FormatException('IDENTIFY_NODE challenge requires engineConfig.');
    }

    if (initialState == null) {
      throw FormatException('IDENTIFY_NODE challenge requires initialState.');
    }

    if (identifyTarget.correctTargetIds.isEmpty) {
      throw FormatException(
        'IDENTIFY_NODE challenge requires at least one correct target.',
      );
    }

    final nodeIds = initialState.nodes.map((node) => node.id).toSet();

    if (!nodeIds.containsAll(identifyTarget.correctTargetIds)) {
      throw FormatException(
        'IDENTIFY_NODE correctTargetIds must reference existing nodes.',
      );
    }

    final visualStructure = _mapStructureContent(
      engineConfig: engineConfig,
      initialState: initialState,
    );

    return ChallengeSpec(
      id: challengeId,
      title: challengeModel.metadata.title,
      instruction: challengeModel.metadata.instruction,
      theoryRef: challengeModel.metadata.theoryRef,
      constraints: _mapConstraints(challengeModel),
      content: IdentifyTargetChallengeContent(
        identifySpec: IdentifyTargetSpec(
          prompt: identifyTarget.prompt,
          targetType: IdentifyTargetType.node,
          correctTargetIds: identifyTarget.correctTargetIds.toSet(),
          allowMultiple: identifyTarget.allowMultiple,
        ),
        visualStructure: visualStructure,
      ),
    );
  }

  static ChallengeSpec _mapIdentifyEdgeChallenge(
    String challengeId,
    ChallengeModel challengeModel,
  ) {
    final identifyTarget = challengeModel.identifyTarget;
    final engineConfig = challengeModel.engineConfig;
    final initialState = challengeModel.initialState;

    if (identifyTarget == null) {
      throw FormatException('IDENTIFY_EDGE challenge requires identifyTarget.');
    }

    if (identifyTarget.targetType != IdentifyTargetTypeModel.edge) {
      throw FormatException('IDENTIFY_EDGE requires targetType=EDGE.');
    }

    if (engineConfig == null) {
      throw FormatException('IDENTIFY_EDGE challenge requires engineConfig.');
    }

    if (initialState == null) {
      throw FormatException('IDENTIFY_EDGE challenge requires initialState.');
    }

    if (identifyTarget.correctTargetIds.isEmpty) {
      throw FormatException(
        'IDENTIFY_EDGE challenge requires at least one correct target.',
      );
    }

    final edgeIds = initialState.edges
        .map((edge) => _edgeId(edge.source, edge.target))
        .toSet();

    if (!edgeIds.containsAll(identifyTarget.correctTargetIds)) {
      throw FormatException(
        'IDENTIFY_EDGE correctTargetIds must reference existing edges.',
      );
    }

    final visualStructure = _mapStructureContent(
      engineConfig: engineConfig,
      initialState: initialState,
    );

    return ChallengeSpec(
      id: challengeId,
      title: challengeModel.metadata.title,
      instruction: challengeModel.metadata.instruction,
      theoryRef: challengeModel.metadata.theoryRef,
      constraints: _mapConstraints(challengeModel),
      content: IdentifyTargetChallengeContent(
        identifySpec: IdentifyTargetSpec(
          prompt: identifyTarget.prompt,
          targetType: IdentifyTargetType.edge,
          correctTargetIds: identifyTarget.correctTargetIds.toSet(),
          allowMultiple: identifyTarget.allowMultiple,
        ),
        visualStructure: visualStructure,
      ),
    );
  }

  static ChallengeSpec _mapCategorizeChallenge(
    String challengeId,
    ChallengeModel challengeModel,
  ) {
    final categorize = challengeModel.categorize;

    if (categorize == null) {
      throw FormatException('CATEGORIZE challenge requires categorize.');
    }

    if (categorize.categories.isEmpty) {
      throw FormatException(
        'CATEGORIZE challenge requires at least one category.',
      );
    }

    if (categorize.items.isEmpty) {
      throw FormatException('CATEGORIZE challenge requires at least one item.');
    }

    if (categorize.correctCategoryByItemId.isEmpty) {
      throw FormatException(
        'CATEGORIZE challenge requires correctCategoryByItemId.',
      );
    }

    final categoryIds = categorize.categories
        .map((category) => category.id)
        .toSet();

    final itemIds = categorize.items.map((item) => item.id).toSet();

    if (!itemIds.containsAll(categorize.correctCategoryByItemId.keys)) {
      throw FormatException(
        'CATEGORIZE correctCategoryByItemId must reference existing items.',
      );
    }

    if (!categoryIds.containsAll(categorize.correctCategoryByItemId.values)) {
      throw FormatException(
        'CATEGORIZE correctCategoryByItemId must reference existing categories.',
      );
    }

    return ChallengeSpec(
      id: challengeId,
      title: challengeModel.metadata.title,
      instruction: challengeModel.metadata.instruction,
      theoryRef: challengeModel.metadata.theoryRef,
      constraints: _mapConstraints(challengeModel),
      content: CategorizeChallengeContent(
        categorizeSpec: CategorizeSpec(
          prompt: categorize.prompt,
          categories: categorize.categories
              .map(
                (category) =>
                    CategorizeCategory(id: category.id, label: category.label),
              )
              .toList(growable: false),
          items: categorize.items
              .map((item) => CategorizeItem(id: item.id, text: item.text))
              .toList(growable: false),
          correctCategoryByItemId: Map<String, String>.from(
            categorize.correctCategoryByItemId,
          ),
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

  static ValidationStrategy _mapValidationStrategy({
    required ChallengeEngineConfigModel engineConfig,
    ChallengeSolutionModel? solution,
  }) {
    switch (engineConfig.validationStrategy) {
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

      case ValidationStrategyType.orderedSequence:
        return OrderedSequenceValidationStrategy();

      case ValidationStrategyType.expectedSlotValues:
        final expectedSlotValues = solution?.expectedSlotValues ?? const {};

        if (expectedSlotValues.isEmpty) {
          throw FormatException(
            'EXPECTED_SLOT_VALUES requires solution.expectedSlotValues.',
          );
        }

        return ExpectedSlotValuesValidationStrategy(
          expectedValuesBySlotId: expectedSlotValues,
        );
    }
  }

  static StructureChallengeContent _mapStructureContent({
    required ChallengeEngineConfigModel engineConfig,
    required ChallengeInitialStateModel initialState,
    ChallengeSolutionModel? solution,
  }) {
    return StructureChallengeContent(
      engineConfig: ChallengeEngineConfig(
        structureType: engineConfig.structureType,
        validationStrategy: _mapValidationStrategy(
          engineConfig: engineConfig,
          solution: solution,
        ),
        layoutStrategy: engineConfig.layoutStrategy,
        interactionMode: engineConfig.interactionMode,
      ),
      initialState: ChallengeInitialStateSpec(
        nodes: _mapInitialNodes(initialState),
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
    );
  }

  static List<ChallengeNodeSpec> _mapInitialNodes(
    ChallengeInitialStateModel initialState,
  ) {
    if (initialState.nodes.isNotEmpty) {
      return initialState.nodes
          .map((node) => ChallengeNodeSpec(id: node.id, value: node.value))
          .toList(growable: false);
    }

    return [
      for (var i = 0; i < initialState.inventory.length; i++)
        ChallengeNodeSpec(id: 'inv_$i', value: initialState.inventory[i]),
    ];
  }

  static String _edgeId(String source, String target) => '$source->$target';
}
