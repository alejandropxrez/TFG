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

      // Metadata
      expect(challenge.metadata.title, 'Reparación de Heap');
      expect(challenge.metadata.instruction, 'Arrastra para corregir');
      expect(challenge.metadata.theoryRef, 'heap_repair');

      // Engine config
      expect(challenge.engineConfig.structureType, StructureType.heap);
      expect(
        challenge.engineConfig.validationStrategy,
        ValidationStrategyType.maxHeap,
      );
      expect(challenge.engineConfig.layoutStrategy, LayoutStrategyType.pyramid);
      expect(challenge.engineConfig.interactionMode, InteractionModeType.swap);

      // Constraints
      expect(challenge.engineConfig.constraints.length, 2);

      final maxMovesConstraint =
          challenge.engineConfig.constraints.first as MaxMovesConstraintModel;
      expect(maxMovesConstraint.maxMoves, 5);

      final lockedNodesConstraint =
          challenge.engineConfig.constraints.last as LockedNodesConstraintModel;
      expect(lockedNodesConstraint.nodeIds, ['n1', 'n3']);

      // Initial state
      expect(challenge.initialState.nodes.length, 2);
      expect(challenge.initialState.nodes.first.id, 'n1');
      expect(challenge.initialState.nodes.first.value, 10);

      expect(challenge.initialState.edges.length, 1);
      expect(challenge.initialState.edges.first.source, 'n1');
      expect(challenge.initialState.edges.first.target, 'n2');

      expect(challenge.initialState.slots, isEmpty);
      expect(challenge.initialState.inventory, isEmpty);
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

      expect(challenge.engineConfig.structureType, StructureType.bst);
      expect(
        challenge.engineConfig.validationStrategy,
        ValidationStrategyType.bst,
      );
      expect(challenge.engineConfig.layoutStrategy, LayoutStrategyType.linear);
      expect(
        challenge.engineConfig.interactionMode,
        InteractionModeType.setValue,
      );

      expect(challenge.initialState.nodes.length, 2);
      expect(challenge.initialState.nodes[0].value, 10);
      expect(challenge.initialState.nodes[1].value, isNull);

      expect(challenge.initialState.slots.length, 1);
      expect(challenge.initialState.slots.first.id, 's1');
      expect(challenge.initialState.inventory, [5, 15]);
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

    expect(challenge.engineConfig.connectionType, ConnectionType.none);
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

    expect(challenge.engineConfig.connectionType, ConnectionType.explicit);
  });
}
