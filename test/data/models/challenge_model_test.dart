import 'dart:convert';

import 'package:algoquest/data/models/challenge_model.dart';
import 'package:algoquest/domain/entities/challenge_spec.dart';
import 'package:algoquest/domain/enums/structure_type.dart';
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
          "connectionType": "EXPLICIT",
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
          "connectionType": "EXPLICIT",
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
          "connectionType": "EXPLICIT",
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
          "connectionType": "EXPLICIT",
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
          "connectionType": "EXPLICIT",
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

  test('parses connection type correctly', () {
    final jsonString = '''
  {
    "metadata": {
      "title": "No edges visual",
      "instruction": "Solve it"
    },
    "engineConfig": {
      "structureType": "GRAPH",
      "validationStrategy": "BST",
      "layoutStrategy": "LINEAR",
      "interactionMode": "LINK",
      "connectionType": "NONE",
      "constraints": []
    },
    "initialState": {
      "nodes": [
        { "id": "n1", "value": 1 },
        { "id": "n2", "value": 2 }
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

    expect(challenge.engineConfig!.connectionType, ConnectionType.none);
  });

  test('defaults connection type to explicit when omitted', () {
    final jsonString = '''
  {
    "metadata": {
      "title": "Default edges",
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

    expect(challenge.engineConfig!.connectionType, ConnectionType.explicit);
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
      "connectionType": "EXPLICIT",
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
      "connectionType": "EXPLICIT",
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
      "connectionType": "EXPLICIT",
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
}
