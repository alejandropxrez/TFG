import 'dart:convert';

import 'package:algoquest/data/mappers/challenge_mapper.dart';
import 'package:algoquest/data/models/challenge_model.dart';
import 'package:algoquest/domain/entities/challenge_spec.dart';
import 'package:algoquest/domain/entities/identify_target_spec.dart';
import 'package:algoquest/domain/enums/structure_type.dart';
import 'package:algoquest/domain/strategies/expected_slot_values_validation_strategy.dart';
import 'package:algoquest/domain/strategies/ordered_sequence_validation_strategy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ChallengeModel JSON parsing', () {
    test('parses a valid challenge JSON correctly', () {
      final jsonString = '''
      {
        "metadata": {
          "title": "Reparación de Heap",
          "instruction": "Arrastra para corregir",
          "theoryRef": "heap_repair"
        },
        "engineConfig": {
          "structureType": "HEAP",
          "validationStrategy": "MAX_HEAP",
          "layoutStrategy": "PYRAMID",
          "interactionMode": "SWAP",
          "constraints": [
            { "type": "MAX_MOVES", "maxMoves": 5 },
            { "type": "LOCKED_NODES", "nodeIds": ["n1", "n3"] }
          ]
        },
        "initialState": {
          "nodes": [
            { "id": "n1", "value": 10 },
            { "id": "n2", "value": 3 }
          ],
          "edges": [
            { "source": "n1", "target": "n2" }
          ],
          "slots": [],
          "inventory": []
        }
      }
      ''';

      final Map<String, dynamic> jsonMap = json.decode(jsonString);
      final challenge = ChallengeModel.fromJson(jsonMap);

      final engineConfig = challenge.engineConfig!;
      final initialState = challenge.initialState!;

      // Metadata
      expect(challenge.metadata.title, 'Reparación de Heap');
      expect(challenge.metadata.instruction, 'Arrastra para corregir');
      expect(challenge.metadata.theoryRef, 'heap_repair');

      // Engine config
      expect(engineConfig.structureType, StructureType.heap);
      expect(engineConfig.validationStrategy, ValidationStrategyType.maxHeap);
      expect(engineConfig.layoutStrategy, LayoutStrategyType.pyramid);
      expect(engineConfig.interactionMode, InteractionModeType.swap);

      // Constraints
      expect(engineConfig.constraints.length, 2);

      expect(
        engineConfig.constraints.first.when(
          maxMoves: (maxMoves) => maxMoves,
          lockedNodes: (_) => null,
          maxAttempts: (_) => null,
          livesConsumedOnFail: (_) => null,
        ),
        5,
      );

      expect(
        engineConfig.constraints.last.when(
          maxMoves: (_) => null,
          lockedNodes: (nodeIds) => nodeIds,
          maxAttempts: (_) => null,
          livesConsumedOnFail: (_) => null,
        ),
        ['n1', 'n3'],
      );

      // Initial state
      expect(initialState.nodes.length, 2);
      expect(initialState.nodes.first.id, 'n1');
      expect(initialState.nodes.first.value, 10);

      expect(initialState.edges.length, 1);
      expect(initialState.edges.first.source, 'n1');
      expect(initialState.edges.first.target, 'n2');

      expect(initialState.slots, isEmpty);
      expect(initialState.inventory, isEmpty);
    });

    test('parses a challenge with nullable node values and inventory', () {
      final jsonString = '''
      {
        "metadata": {
          "title": "Fill the blanks",
          "instruction": "Set the missing values"
        },
        "engineConfig": {
          "structureType": "BST",
          "validationStrategy": "BST",
          "layoutStrategy": "LINEAR",
          "interactionMode": "SET_VALUE",
          "constraints": []
        },
        "initialState": {
          "nodes": [
            { "id": "n1", "value": 10 },
            { "id": "n2", "value": null }
          ],
          "edges": [
            { "source": "n1", "target": "n2" }
          ],
          "slots": [
            { "id": "s1", "index": 0 }
          ],
          "inventory": [5, 15]
        }
      }
      ''';

      final Map<String, dynamic> jsonMap = json.decode(jsonString);
      final challenge = ChallengeModel.fromJson(jsonMap);

      final engineConfig = challenge.engineConfig!;
      final initialState = challenge.initialState!;

      expect(engineConfig.structureType, StructureType.bst);
      expect(engineConfig.validationStrategy, ValidationStrategyType.bst);
      expect(engineConfig.layoutStrategy, LayoutStrategyType.linear);
      expect(engineConfig.interactionMode, InteractionModeType.setValue);

      expect(initialState.nodes.length, 2);
      expect(initialState.nodes[0].value, 10);
      expect(initialState.nodes[1].value, isNull);

      expect(initialState.slots.length, 1);
      expect(initialState.slots.first.id, 's1');
      expect(initialState.inventory, [5, 15]);
    });

    test('throws when an unknown constraint type is provided', () {
      final jsonString = '''
      {
        "metadata": {
          "title": "Test",
          "instruction": "Test"
        },
        "engineConfig": {
          "structureType": "HEAP",
          "validationStrategy": "MAX_HEAP",
          "layoutStrategy": "PYRAMID",
          "interactionMode": "SWAP",
          "constraints": [
            { "type": "UNKNOWN_CONSTRAINT", "foo": 1 }
          ]
        },
        "initialState": {
          "nodes": [],
          "edges": [],
          "slots": [],
          "inventory": []
        }
      }
      ''';

      final Map<String, dynamic> jsonMap = json.decode(jsonString);

      expect(() => ChallengeModel.fromJson(jsonMap), throwsA(isA<Object>()));
    });

    test('throws when an unknown structure type is provided', () {
      final jsonString = '''
      {
        "metadata": {
          "title": "Test",
          "instruction": "Test"
        },
        "engineConfig": {
          "structureType": "UNKNOWN_STRUCTURE",
          "validationStrategy": "MAX_HEAP",
          "layoutStrategy": "PYRAMID",
          "interactionMode": "SWAP",
          "constraints": []
        },
        "initialState": {
          "nodes": [],
          "edges": [],
          "slots": [],
          "inventory": []
        }
      }
      ''';

      final Map<String, dynamic> jsonMap = json.decode(jsonString);

      expect(
        () => ChallengeModel.fromJson(jsonMap),
        throwsA(isA<FormatException>()),
      );
    });

    test('throws when an unknown interaction mode is provided', () {
      final jsonString = '''
      {
        "metadata": {
          "title": "Test",
          "instruction": "Test"
        },
        "engineConfig": {
          "structureType": "HEAP",
          "validationStrategy": "MAX_HEAP",
          "layoutStrategy": "PYRAMID",
          "interactionMode": "UNKNOWN_MODE",
          "constraints": []
        },
        "initialState": {
          "nodes": [],
          "edges": [],
          "slots": [],
          "inventory": []
        }
      }
      ''';

      final Map<String, dynamic> jsonMap = json.decode(jsonString);

      expect(
        () => ChallengeModel.fromJson(jsonMap),
        throwsA(isA<FormatException>()),
      );
    });
  });

  test('parses CIRCULAR layout strategy correctly', () {
    final jsonString = '''
  {
    "metadata": {
      "title": "Circular graph",
      "instruction": "Inspect the graph"
    },
    "engineConfig": {
      "structureType": "GRAPH",
      "validationStrategy": "BST",
      "layoutStrategy": "CIRCULAR",
      "interactionMode": "LINK",
      "constraints": []
    },
    "initialState": {
      "nodes": [
        { "id": "n1", "value": 1 },
        { "id": "n2", "value": 2 }
      ],
      "edges": [],
      "slots": [],
      "inventory": []
    }
  }
  ''';

    final Map<String, dynamic> jsonMap = json.decode(jsonString);
    final challenge = ChallengeModel.fromJson(jsonMap);

    expect(challenge.engineConfig!.layoutStrategy, LayoutStrategyType.circular);
  });

  test('parses FREE layout strategy correctly', () {
    final jsonString = '''
  {
    "metadata": {
      "title": "Free layout graph",
      "instruction": "Inspect the graph"
    },
    "engineConfig": {
      "structureType": "GRAPH",
      "validationStrategy": "BST",
      "layoutStrategy": "FREE",
      "interactionMode": "LINK",
      "constraints": []
    },
    "initialState": {
      "nodes": [
        { "id": "n1", "value": 1 },
        { "id": "n2", "value": 2 }
      ],
      "edges": [],
      "slots": [],
      "inventory": []
    }
  }
  ''';

    final Map<String, dynamic> jsonMap = json.decode(jsonString);
    final challenge = ChallengeModel.fromJson(jsonMap);

    expect(challenge.engineConfig!.layoutStrategy, LayoutStrategyType.free);
  });

  test('parses MAX_ATTEMPTS constraint correctly', () {
    final json = {'type': 'MAX_ATTEMPTS', 'maxAttempts': 3};

    final constraint = ChallengeConstraintModel.fromJson(json);

    expect(
      constraint.when(
        maxMoves: (_) => null,
        lockedNodes: (_) => null,
        maxAttempts: (maxAttempts) => maxAttempts,
        livesConsumedOnFail: (_) => null,
      ),
      3,
    );
  });

  test('parses LIVES_CONSUMED_ON_FAIL constraint correctly', () {
    final json = {'type': 'LIVES_CONSUMED_ON_FAIL', 'lives': 0};

    final constraint = ChallengeConstraintModel.fromJson(json);

    expect(
      constraint.when(
        maxMoves: (_) => null,
        lockedNodes: (_) => null,
        maxAttempts: (_) => null,
        livesConsumedOnFail: (lives) => lives,
      ),
      0,
    );
  });

  test('defaults challenge kind to structure when omitted', () {
    final jsonString = '''
  {
    "metadata": {
      "title": "Default structure",
      "instruction": "Solve it"
    },
    "engineConfig": {
      "structureType": "HEAP",
      "validationStrategy": "MAX_HEAP",
      "layoutStrategy": "PYRAMID",
      "interactionMode": "SWAP",
      "constraints": []
    },
    "initialState": {
      "nodes": [],
      "edges": [],
      "slots": [],
      "inventory": []
    }
  }
  ''';

    final Map<String, dynamic> jsonMap = json.decode(jsonString);
    final challenge = ChallengeModel.fromJson(jsonMap);

    expect(challenge.kind, ChallengeKindModel.structure);
    expect(challenge.engineConfig, isNotNull);
    expect(challenge.initialState, isNotNull);
    expect(challenge.quiz, isNull);
  });

  test('parses SINGLE_CHOICE quiz challenge correctly', () {
    final jsonString = '''
  {
    "kind": "SINGLE_CHOICE",
    "metadata": {
      "title": "Propiedad de Max Heap",
      "instruction": "Selecciona la opción correcta",
      "theoryRef": "heap_intro"
    },
    "constraints": [
      { "type": "MAX_ATTEMPTS", "maxAttempts": 3 },
      { "type": "LIVES_CONSUMED_ON_FAIL", "lives": 1 }
    ],
    "quiz": {
      "question": "¿Qué propiedad debe cumplir un max-heap?",
      "options": [
        {
          "id": "a",
          "text": "Cada padre debe ser mayor o igual que sus hijos."
        },
        {
          "id": "b",
          "text": "Cada hijo debe ser mayor que su padre."
        }
      ],
      "correctOptionIds": ["a"],
      "allowMultiple": false
    }
  }
  ''';

    final Map<String, dynamic> jsonMap = json.decode(jsonString);
    final challenge = ChallengeModel.fromJson(jsonMap);

    expect(challenge.kind, ChallengeKindModel.singleChoice);

    expect(challenge.metadata.title, 'Propiedad de Max Heap');
    expect(challenge.metadata.instruction, 'Selecciona la opción correcta');
    expect(challenge.metadata.theoryRef, 'heap_intro');

    expect(challenge.engineConfig, isNull);
    expect(challenge.initialState, isNull);

    expect(challenge.constraints.length, 2);

    expect(
      challenge.constraints.first.when(
        maxMoves: (_) => null,
        lockedNodes: (_) => null,
        maxAttempts: (maxAttempts) => maxAttempts,
        livesConsumedOnFail: (_) => null,
      ),
      3,
    );

    expect(
      challenge.constraints.last.when(
        maxMoves: (_) => null,
        lockedNodes: (_) => null,
        maxAttempts: (_) => null,
        livesConsumedOnFail: (lives) => lives,
      ),
      1,
    );

    final quiz = challenge.quiz!;

    expect(quiz.question, '¿Qué propiedad debe cumplir un max-heap?');
    expect(quiz.options.length, 2);
    expect(quiz.options.first.id, 'a');
    expect(
      quiz.options.first.text,
      'Cada padre debe ser mayor o igual que sus hijos.',
    );
    expect(quiz.correctOptionIds, ['a']);
    expect(quiz.allowMultiple, isFalse);
  });

  test('maps SINGLE_CHOICE challenge model to QuizChallengeContent', () {
    final model = ChallengeModel.fromJson({
      'kind': 'SINGLE_CHOICE',
      'metadata': {
        'title': 'Propiedad de Max Heap',
        'instruction': 'Selecciona la opción correcta',
        'theoryRef': 'heap_intro',
      },
      'constraints': [
        {'type': 'MAX_ATTEMPTS', 'maxAttempts': 3},
        {'type': 'LIVES_CONSUMED_ON_FAIL', 'lives': 1},
      ],
      'quiz': {
        'question': '¿Qué propiedad debe cumplir un max-heap?',
        'options': [
          {
            'id': 'a',
            'text': 'Cada padre debe ser mayor o igual que sus hijos.',
          },
          {'id': 'b', 'text': 'Cada hijo debe ser mayor que su padre.'},
        ],
        'correctOptionIds': ['a'],
        'allowMultiple': false,
      },
    });

    final spec = ChallengeMapper.toDomain('quiz_heap_property', model);

    expect(spec.id, 'quiz_heap_property');
    expect(spec.title, 'Propiedad de Max Heap');
    expect(spec.instruction, 'Selecciona la opción correcta');
    expect(spec.theoryRef, 'heap_intro');

    expect(spec.constraints, hasLength(2));
    expect(spec.maxAttempts, 3);
    expect(spec.livesConsumedOnFail, 1);

    expect(spec.content, isA<QuizChallengeContent>());

    final content = spec.content as QuizChallengeContent;

    expect(
      content.quizSpec.question,
      '¿Qué propiedad debe cumplir un max-heap?',
    );
    expect(content.quizSpec.options, hasLength(2));
    expect(content.quizSpec.correctOptionIds, {'a'});
    expect(content.quizSpec.allowMultiple, isFalse);
  });

  test('parses MULTIPLE_CHOICE quiz challenge correctly', () {
    final jsonString = '''
  {
    "kind": "MULTIPLE_CHOICE",
    "metadata": {
      "title": "Propiedades de Max Heap",
      "instruction": "Selecciona todas las afirmaciones correctas",
      "theoryRef": "heap_intro"
    },
    "constraints": [
      { "type": "MAX_ATTEMPTS", "maxAttempts": 3 },
      { "type": "LIVES_CONSUMED_ON_FAIL", "lives": 1 }
    ],
    "quiz": {
      "question": "¿Qué afirmaciones son verdaderas sobre un max-heap?",
      "options": [
        {
          "id": "a",
          "text": "Cada padre es mayor o igual que sus hijos."
        },
        {
          "id": "b",
          "text": "El valor máximo está en la raíz."
        },
        {
          "id": "c",
          "text": "Los valores deben estar ordenados en inorden."
        }
      ],
      "correctOptionIds": ["a", "b"],
      "allowMultiple": true
    }
  }
  ''';

    final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
    final challenge = ChallengeModel.fromJson(jsonMap);

    expect(challenge.kind, ChallengeKindModel.multipleChoice);
    expect(challenge.engineConfig, isNull);
    expect(challenge.initialState, isNull);

    expect(challenge.constraints.length, 2);

    final quiz = challenge.quiz!;
    expect(
      quiz.question,
      '¿Qué afirmaciones son verdaderas sobre un max-heap?',
    );
    expect(quiz.options.length, 3);
    expect(quiz.correctOptionIds, ['a', 'b']);
    expect(quiz.allowMultiple, isTrue);
  });

  test('maps MULTIPLE_CHOICE challenge model to QuizChallengeContent', () {
    final model = ChallengeModel.fromJson({
      'kind': 'MULTIPLE_CHOICE',
      'metadata': {
        'title': 'Propiedades de Max Heap',
        'instruction': 'Selecciona todas las afirmaciones correctas',
        'theoryRef': 'heap_intro',
      },
      'constraints': [
        {'type': 'MAX_ATTEMPTS', 'maxAttempts': 3},
        {'type': 'LIVES_CONSUMED_ON_FAIL', 'lives': 1},
      ],
      'quiz': {
        'question': '¿Qué afirmaciones son verdaderas sobre un max-heap?',
        'options': [
          {'id': 'a', 'text': 'Cada padre es mayor o igual que sus hijos.'},
          {'id': 'b', 'text': 'El valor máximo está en la raíz.'},
          {'id': 'c', 'text': 'Los valores deben estar ordenados en inorden.'},
        ],
        'correctOptionIds': ['a', 'b'],
        'allowMultiple': true,
      },
    });

    final spec = ChallengeMapper.toDomain(
      'quiz_heap_properties_multiple',
      model,
    );

    expect(spec.id, 'quiz_heap_properties_multiple');
    expect(spec.title, 'Propiedades de Max Heap');
    expect(spec.instruction, 'Selecciona todas las afirmaciones correctas');
    expect(spec.theoryRef, 'heap_intro');

    expect(spec.maxAttempts, 3);
    expect(spec.livesConsumedOnFail, 1);

    expect(spec.content, isA<QuizChallengeContent>());

    final content = spec.content as QuizChallengeContent;

    expect(
      content.quizSpec.question,
      '¿Qué afirmaciones son verdaderas sobre un max-heap?',
    );
    expect(content.quizSpec.allowMultiple, isTrue);
    expect(content.quizSpec.correctOptionIds, {'a', 'b'});
    expect(content.quizSpec.options.length, 3);
  });

  test('throws when MULTIPLE_CHOICE quiz has allowMultiple false', () {
    final model = ChallengeModel.fromJson({
      'kind': 'MULTIPLE_CHOICE',
      'metadata': {
        'title': 'Invalid multiple choice',
        'instruction': 'Select answers',
      },
      'quiz': {
        'question': 'Question',
        'options': [
          {'id': 'a', 'text': 'A'},
          {'id': 'b', 'text': 'B'},
        ],
        'correctOptionIds': ['a'],
        'allowMultiple': false,
      },
    });

    expect(
      () => ChallengeMapper.toDomain('invalid_multiple_choice', model),
      throwsA(isA<FormatException>()),
    );
  });

  test('throws when MULTIPLE_CHOICE correct option does not exist', () {
    final model = ChallengeModel.fromJson({
      'kind': 'MULTIPLE_CHOICE',
      'metadata': {
        'title': 'Invalid multiple choice',
        'instruction': 'Select answers',
      },
      'quiz': {
        'question': 'Question',
        'options': [
          {'id': 'a', 'text': 'A'},
          {'id': 'b', 'text': 'B'},
        ],
        'correctOptionIds': ['missing'],
        'allowMultiple': true,
      },
    });

    expect(
      () => ChallengeMapper.toDomain('invalid_multiple_choice', model),
      throwsA(isA<FormatException>()),
    );
  });

  test('parses IDENTIFY_NODE challenge correctly', () {
    final jsonString = '''
  {
    "kind": "IDENTIFY_NODE",
    "metadata": {
      "title": "Nodo incorrecto",
      "instruction": "Toca el nodo que rompe la propiedad de max-heap",
      "theoryRef": "heap_property"
    },
    "constraints": [
      { "type": "MAX_ATTEMPTS", "maxAttempts": 3 },
      { "type": "LIVES_CONSUMED_ON_FAIL", "lives": 1 }
    ],
    "identifyTarget": {
      "prompt": "¿Qué nodo rompe la propiedad de max-heap?",
      "targetType": "NODE",
      "correctTargetIds": ["n2"],
      "allowMultiple": false
    },
    "engineConfig": {
      "structureType": "HEAP",
      "validationStrategy": "MAX_HEAP",
      "layoutStrategy": "PYRAMID",
      "interactionMode": "SWAP",
      "constraints": []
    },
    "initialState": {
      "nodes": [
        { "id": "n1", "value": 10 },
        { "id": "n2", "value": 15 },
        { "id": "n3", "value": 7 }
      ],
      "edges": [
        { "source": "n1", "target": "n2" },
        { "source": "n1", "target": "n3" }
      ],
      "slots": [],
      "inventory": []
    }
  }
  ''';

    final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
    final challenge = ChallengeModel.fromJson(jsonMap);

    expect(challenge.kind, ChallengeKindModel.identifyNode);

    expect(challenge.metadata.title, 'Nodo incorrecto');
    expect(
      challenge.metadata.instruction,
      'Toca el nodo que rompe la propiedad de max-heap',
    );
    expect(challenge.metadata.theoryRef, 'heap_property');

    expect(challenge.constraints.length, 2);

    final identifyTarget = challenge.identifyTarget!;
    expect(identifyTarget.prompt, '¿Qué nodo rompe la propiedad de max-heap?');
    expect(identifyTarget.targetType, IdentifyTargetTypeModel.node);
    expect(identifyTarget.correctTargetIds, ['n2']);
    expect(identifyTarget.allowMultiple, isFalse);

    final engineConfig = challenge.engineConfig!;
    expect(engineConfig.structureType, StructureType.heap);
    expect(engineConfig.validationStrategy, ValidationStrategyType.maxHeap);
    expect(engineConfig.layoutStrategy, LayoutStrategyType.pyramid);
    expect(engineConfig.interactionMode, InteractionModeType.swap);

    final initialState = challenge.initialState!;
    expect(initialState.nodes.length, 3);
    expect(initialState.nodes[1].id, 'n2');
    expect(initialState.nodes[1].value, 15);
    expect(initialState.edges.length, 2);
  });

  test(
    'maps IDENTIFY_NODE challenge model to IdentifyTargetChallengeContent',
    () {
      final model = ChallengeModel.fromJson({
        'kind': 'IDENTIFY_NODE',
        'metadata': {
          'title': 'Nodo incorrecto',
          'instruction': 'Toca el nodo que rompe la propiedad de max-heap',
          'theoryRef': 'heap_property',
        },
        'constraints': [
          {'type': 'MAX_ATTEMPTS', 'maxAttempts': 3},
          {'type': 'LIVES_CONSUMED_ON_FAIL', 'lives': 1},
        ],
        'identifyTarget': {
          'prompt': '¿Qué nodo rompe la propiedad de max-heap?',
          'targetType': 'NODE',
          'correctTargetIds': ['n2'],
          'allowMultiple': false,
        },
        'engineConfig': {
          'structureType': 'HEAP',
          'validationStrategy': 'MAX_HEAP',
          'layoutStrategy': 'PYRAMID',
          'interactionMode': 'SWAP',
          'constraints': [],
        },
        'initialState': {
          'nodes': [
            {'id': 'n1', 'value': 10},
            {'id': 'n2', 'value': 15},
            {'id': 'n3', 'value': 7},
          ],
          'edges': [
            {'source': 'n1', 'target': 'n2'},
            {'source': 'n1', 'target': 'n3'},
          ],
          'slots': [],
          'inventory': [],
        },
      });

      final spec = ChallengeMapper.toDomain('identify_heap_wrong_node', model);

      expect(spec.id, 'identify_heap_wrong_node');
      expect(spec.title, 'Nodo incorrecto');
      expect(
        spec.instruction,
        'Toca el nodo que rompe la propiedad de max-heap',
      );
      expect(spec.theoryRef, 'heap_property');

      expect(spec.maxAttempts, 3);
      expect(spec.livesConsumedOnFail, 1);

      expect(spec.content, isA<IdentifyTargetChallengeContent>());

      final content = spec.content as IdentifyTargetChallengeContent;

      expect(
        content.identifySpec.prompt,
        '¿Qué nodo rompe la propiedad de max-heap?',
      );
      expect(content.identifySpec.targetType, IdentifyTargetType.node);
      expect(content.identifySpec.correctTargetIds, {'n2'});
      expect(content.identifySpec.allowMultiple, isFalse);

      expect(
        content.visualStructure.engineConfig.structureType,
        StructureType.heap,
      );
      expect(content.visualStructure.initialState.nodes.length, 3);
      expect(content.visualStructure.initialState.nodes[1].id, 'n2');
      expect(content.visualStructure.initialState.nodes[1].value, 15);
    },
  );

  test('throws when IDENTIFY_NODE has no identifyTarget', () {
    final model = ChallengeModel.fromJson({
      'kind': 'IDENTIFY_NODE',
      'metadata': {
        'title': 'Invalid identify node',
        'instruction': 'Tap the wrong node',
      },
      'engineConfig': {
        'structureType': 'HEAP',
        'validationStrategy': 'MAX_HEAP',
        'layoutStrategy': 'PYRAMID',
        'interactionMode': 'SWAP',
        'constraints': [],
      },
      'initialState': {
        'nodes': [
          {'id': 'n1', 'value': 10},
        ],
        'edges': [],
        'slots': [],
        'inventory': [],
      },
    });

    expect(
      () => ChallengeMapper.toDomain('invalid_identify_node', model),
      throwsA(isA<FormatException>()),
    );
  });

  test('throws when IDENTIFY_NODE targetType is not NODE', () {
    final model = ChallengeModel.fromJson({
      'kind': 'IDENTIFY_NODE',
      'metadata': {
        'title': 'Invalid identify node',
        'instruction': 'Tap the wrong node',
      },
      'identifyTarget': {
        'prompt': 'Which edge is wrong?',
        'targetType': 'EDGE',
        'correctTargetIds': ['n1->n2'],
        'allowMultiple': false,
      },
      'engineConfig': {
        'structureType': 'HEAP',
        'validationStrategy': 'MAX_HEAP',
        'layoutStrategy': 'PYRAMID',
        'interactionMode': 'SWAP',
        'constraints': [],
      },
      'initialState': {
        'nodes': [
          {'id': 'n1', 'value': 10},
          {'id': 'n2', 'value': 15},
        ],
        'edges': [
          {'source': 'n1', 'target': 'n2'},
        ],
        'slots': [],
        'inventory': [],
      },
    });

    expect(
      () => ChallengeMapper.toDomain('invalid_identify_node', model),
      throwsA(isA<FormatException>()),
    );
  });

  test(
    'throws when IDENTIFY_NODE correct target does not reference existing node',
    () {
      final model = ChallengeModel.fromJson({
        'kind': 'IDENTIFY_NODE',
        'metadata': {
          'title': 'Invalid identify node',
          'instruction': 'Tap the wrong node',
        },
        'identifyTarget': {
          'prompt': 'Which node is wrong?',
          'targetType': 'NODE',
          'correctTargetIds': ['missing'],
          'allowMultiple': false,
        },
        'engineConfig': {
          'structureType': 'HEAP',
          'validationStrategy': 'MAX_HEAP',
          'layoutStrategy': 'PYRAMID',
          'interactionMode': 'SWAP',
          'constraints': [],
        },
        'initialState': {
          'nodes': [
            {'id': 'n1', 'value': 10},
            {'id': 'n2', 'value': 15},
          ],
          'edges': [
            {'source': 'n1', 'target': 'n2'},
          ],
          'slots': [],
          'inventory': [],
        },
      });

      expect(
        () => ChallengeMapper.toDomain('invalid_identify_node', model),
        throwsA(isA<FormatException>()),
      );
    },
  );

  test('throws when IDENTIFY_NODE has no engineConfig', () {
    final model = ChallengeModel.fromJson({
      'kind': 'IDENTIFY_NODE',
      'metadata': {
        'title': 'Invalid identify node',
        'instruction': 'Tap the wrong node',
      },
      'identifyTarget': {
        'prompt': 'Which node is wrong?',
        'targetType': 'NODE',
        'correctTargetIds': ['n1'],
        'allowMultiple': false,
      },
      'initialState': {
        'nodes': [
          {'id': 'n1', 'value': 10},
        ],
        'edges': [],
        'slots': [],
        'inventory': [],
      },
    });

    expect(
      () => ChallengeMapper.toDomain('invalid_identify_node', model),
      throwsA(isA<FormatException>()),
    );
  });

  test('throws when IDENTIFY_NODE has no initialState', () {
    final model = ChallengeModel.fromJson({
      'kind': 'IDENTIFY_NODE',
      'metadata': {
        'title': 'Invalid identify node',
        'instruction': 'Tap the wrong node',
      },
      'identifyTarget': {
        'prompt': 'Which node is wrong?',
        'targetType': 'NODE',
        'correctTargetIds': ['n1'],
        'allowMultiple': false,
      },
      'engineConfig': {
        'structureType': 'HEAP',
        'validationStrategy': 'MAX_HEAP',
        'layoutStrategy': 'PYRAMID',
        'interactionMode': 'SWAP',
        'constraints': [],
      },
    });

    expect(
      () => ChallengeMapper.toDomain('invalid_identify_node', model),
      throwsA(isA<FormatException>()),
    );
  });

  test('parses ORDERED_SEQUENCE validation strategy correctly', () {
    final jsonString = '''
  {
    "metadata": {
      "title": "Ordena la secuencia",
      "instruction": "Arrastra los valores en orden ascendente"
    },
    "engineConfig": {
      "structureType": "LINKED_LIST",
      "validationStrategy": "ORDERED_SEQUENCE",
      "layoutStrategy": "LINEAR",
      "interactionMode": "DRAG",
      "constraints": []
    },
    "initialState": {
      "nodes": [
        { "id": "n1", "value": 3 },
        { "id": "n2", "value": 1 },
        { "id": "n3", "value": 2 }
      ],
      "edges": [],
      "slots": [
        { "id": "s1", "index": 0 },
        { "id": "s2", "index": 1 },
        { "id": "s3", "index": 2 }
      ],
      "inventory": [3, 1, 2]
    }
  }
  ''';

    final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
    final challenge = ChallengeModel.fromJson(jsonMap);

    expect(
      challenge.engineConfig!.validationStrategy,
      ValidationStrategyType.orderedSequence,
    );
  });

  test('maps ORDERED_SEQUENCE validation strategy', () {
    final model = ChallengeModel.fromJson({
      'metadata': {
        'title': 'Ordena la secuencia',
        'instruction': 'Arrastra los valores en orden ascendente',
      },
      'engineConfig': {
        'structureType': 'LINKED_LIST',
        'validationStrategy': 'ORDERED_SEQUENCE',
        'layoutStrategy': 'LINEAR',
        'interactionMode': 'DRAG',
        'constraints': [],
      },
      'initialState': {
        'nodes': [
          {'id': 'n1', 'value': 3},
          {'id': 'n2', 'value': 1},
          {'id': 'n3', 'value': 2},
        ],
        'edges': [],
        'slots': [
          {'id': 's1', 'index': 0},
          {'id': 's2', 'index': 1},
          {'id': 's3', 'index': 2},
        ],
        'inventory': [3, 1, 2],
      },
    });

    final spec = ChallengeMapper.toDomain('list_order_sequence_intro', model);

    final content = spec.content as StructureChallengeContent;

    expect(
      content.engineConfig.validationStrategy,
      isA<OrderedSequenceValidationStrategy>(),
    );
  });

  test('parses challenge solution expected slot values', () {
    final model = ChallengeModel.fromJson({
      'kind': 'STRUCTURE',
      'metadata': {
        'title': 'Completa el valor',
        'instruction': 'Arrastra el valor correcto',
      },
      'engineConfig': {
        'structureType': 'LINKED_LIST',
        'validationStrategy': 'EXPECTED_SLOT_VALUES',
        'layoutStrategy': 'LINEAR',
        'interactionMode': 'DRAG',
        'constraints': [],
      },
      'initialState': {
        'nodes': [],
        'edges': [],
        'slots': [
          {'id': 's1', 'index': 0},
        ],
        'inventory': [2, 4],
      },
      'solution': {
        'expectedSlotValues': {'s1': 2},
      },
    });

    expect(model.solution, isNotNull);
    expect(model.solution!.expectedSlotValues, {'s1': 2});
  });

  test('maps EXPECTED_SLOT_VALUES validation strategy from solution', () {
    final model = ChallengeModel.fromJson({
      'kind': 'STRUCTURE',
      'metadata': {
        'title': 'Completa el valor',
        'instruction': 'Arrastra el valor correcto',
      },
      'engineConfig': {
        'structureType': 'LINKED_LIST',
        'validationStrategy': 'EXPECTED_SLOT_VALUES',
        'layoutStrategy': 'LINEAR',
        'interactionMode': 'DRAG',
        'constraints': [],
      },
      'initialState': {
        'nodes': [],
        'edges': [],
        'slots': [
          {'id': 's1', 'index': 0},
        ],
        'inventory': [2, 4],
      },
      'solution': {
        'expectedSlotValues': {'s1': 2},
      },
    });

    final spec = ChallengeMapper.toDomain('fill_missing_value_intro', model);
    final content = spec.content as StructureChallengeContent;

    expect(
      content.engineConfig.validationStrategy,
      isA<ExpectedSlotValuesValidationStrategy>(),
    );

    expect(content.initialState.nodes.length, 2);
    expect(content.initialState.nodes[0].id, 'inv_0');
    expect(content.initialState.nodes[0].value, 2);
    expect(content.initialState.nodes[1].id, 'inv_1');
    expect(content.initialState.nodes[1].value, 4);
  });

  test('throws when EXPECTED_SLOT_VALUES has no solution', () {
    final model = ChallengeModel.fromJson({
      'kind': 'STRUCTURE',
      'metadata': {
        'title': 'Completa el valor',
        'instruction': 'Arrastra el valor correcto',
      },
      'engineConfig': {
        'structureType': 'LINKED_LIST',
        'validationStrategy': 'EXPECTED_SLOT_VALUES',
        'layoutStrategy': 'LINEAR',
        'interactionMode': 'DRAG',
        'constraints': [],
      },
      'initialState': {
        'nodes': [],
        'edges': [],
        'slots': [
          {'id': 's1', 'index': 0},
        ],
        'inventory': [2, 4],
      },
    });

    expect(
      () => ChallengeMapper.toDomain('fill_missing_value_intro', model),
      throwsA(isA<FormatException>()),
    );
  });

  test('parses IDENTIFY_EDGE challenge correctly', () {
    final model = ChallengeModel.fromJson({
      'kind': 'IDENTIFY_EDGE',
      'metadata': {
        'title': 'Identifica la arista incorrecta',
        'instruction': 'Toca la arista incorrecta',
        'theoryRef': 'edge_violation',
      },
      'identifyTarget': {
        'prompt': '¿Qué arista es incorrecta?',
        'targetType': 'EDGE',
        'correctTargetIds': ['n1->n3'],
        'allowMultiple': false,
      },
      'engineConfig': {
        'structureType': 'GRAPH',
        'validationStrategy': 'CONNECTED_GRAPH',
        'layoutStrategy': 'LINEAR',
        'interactionMode': 'LINK',
        'constraints': [],
      },
      'initialState': {
        'nodes': [
          {'id': 'n1', 'value': 1},
          {'id': 'n2', 'value': 2},
          {'id': 'n3', 'value': 3},
        ],
        'edges': [
          {'source': 'n1', 'target': 'n2'},
          {'source': 'n1', 'target': 'n3'},
        ],
        'slots': [],
        'inventory': [],
      },
    });

    expect(model.kind, ChallengeKindModel.identifyEdge);
    expect(model.identifyTarget, isNotNull);
    expect(model.identifyTarget!.targetType, IdentifyTargetTypeModel.edge);
    expect(model.identifyTarget!.correctTargetIds, ['n1->n3']);
  });

  test(
    'maps IDENTIFY_EDGE challenge model to IdentifyTargetChallengeContent',
    () {
      final model = ChallengeModel.fromJson({
        'kind': 'IDENTIFY_EDGE',
        'metadata': {
          'title': 'Identifica la arista incorrecta',
          'instruction': 'Toca la arista incorrecta',
          'theoryRef': 'edge_violation',
        },
        'identifyTarget': {
          'prompt': '¿Qué arista es incorrecta?',
          'targetType': 'EDGE',
          'correctTargetIds': ['n1->n3'],
          'allowMultiple': false,
        },
        'engineConfig': {
          'structureType': 'GRAPH',
          'validationStrategy': 'CONNECTED_GRAPH',
          'layoutStrategy': 'LINEAR',
          'interactionMode': 'LINK',
          'constraints': [],
        },
        'initialState': {
          'nodes': [
            {'id': 'n1', 'value': 1},
            {'id': 'n2', 'value': 2},
            {'id': 'n3', 'value': 3},
          ],
          'edges': [
            {'source': 'n1', 'target': 'n2'},
            {'source': 'n1', 'target': 'n3'},
          ],
          'slots': [],
          'inventory': [],
        },
      });

      final spec = ChallengeMapper.toDomain('identify_edge_1', model);

      expect(spec.id, 'identify_edge_1');
      expect(spec.title, 'Identifica la arista incorrecta');

      final content = spec.content;
      expect(content, isA<IdentifyTargetChallengeContent>());

      final identifyContent = content as IdentifyTargetChallengeContent;

      expect(identifyContent.identifySpec.targetType, IdentifyTargetType.edge);
      expect(identifyContent.identifySpec.correctTargetIds, {'n1->n3'});
      expect(identifyContent.identifySpec.allowMultiple, isFalse);

      expect(identifyContent.visualStructure.initialState.edges.length, 2);
    },
  );

  test('throws when IDENTIFY_EDGE targetType is not EDGE', () {
    final model = ChallengeModel.fromJson({
      'kind': 'IDENTIFY_EDGE',
      'metadata': {
        'title': 'Identifica la arista incorrecta',
        'instruction': 'Toca la arista incorrecta',
      },
      'identifyTarget': {
        'prompt': '¿Qué arista es incorrecta?',
        'targetType': 'NODE',
        'correctTargetIds': ['n1'],
        'allowMultiple': false,
      },
      'engineConfig': {
        'structureType': 'GRAPH',
        'validationStrategy': 'CONNECTED_GRAPH',
        'layoutStrategy': 'LINEAR',
        'interactionMode': 'LINK',
        'constraints': [],
      },
      'initialState': {
        'nodes': [
          {'id': 'n1', 'value': 1},
          {'id': 'n2', 'value': 2},
        ],
        'edges': [
          {'source': 'n1', 'target': 'n2'},
        ],
        'slots': [],
        'inventory': [],
      },
    });

    expect(
      () => ChallengeMapper.toDomain('identify_edge_1', model),
      throwsA(isA<FormatException>()),
    );
  });

  test(
    'throws when IDENTIFY_EDGE correctTargetIds reference missing edges',
    () {
      final model = ChallengeModel.fromJson({
        'kind': 'IDENTIFY_EDGE',
        'metadata': {
          'title': 'Identifica la arista incorrecta',
          'instruction': 'Toca la arista incorrecta',
        },
        'identifyTarget': {
          'prompt': '¿Qué arista es incorrecta?',
          'targetType': 'EDGE',
          'correctTargetIds': ['n2->n3'],
          'allowMultiple': false,
        },
        'engineConfig': {
          'structureType': 'GRAPH',
          'validationStrategy': 'CONNECTED_GRAPH',
          'layoutStrategy': 'LINEAR',
          'interactionMode': 'LINK',
          'constraints': [],
        },
        'initialState': {
          'nodes': [
            {'id': 'n1', 'value': 1},
            {'id': 'n2', 'value': 2},
            {'id': 'n3', 'value': 3},
          ],
          'edges': [
            {'source': 'n1', 'target': 'n2'},
            {'source': 'n1', 'target': 'n3'},
          ],
          'slots': [],
          'inventory': [],
        },
      });

      expect(
        () => ChallengeMapper.toDomain('identify_edge_1', model),
        throwsA(isA<FormatException>()),
      );
    },
  );
}
