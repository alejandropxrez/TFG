import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:algoquest/data/models/challenge_model.dart';

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
          "validationStrategy": "MAX_HEAP",
          "layoutStrategy": "PYRAMID",
          "connectionStrategy": "IMPLICIT_HEAP",
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
          "edges": [],
          "slots": []
        }
      }
      ''';

      final Map<String, dynamic> jsonMap = json.decode(jsonString);

      final challenge = ChallengeModel.fromJson(jsonMap);

      // Metadata
      expect(challenge.metadata.title, 'Reparación de Heap');
      expect(challenge.metadata.instruction, 'Arrastra para corregir');
      expect(challenge.metadata.theoryRef, 'heap_repair');

      // Engine config (enums)
      expect(
        challenge.engineConfig.validationStrategy,
        ValidationStrategyType.maxHeap,
      );
      expect(challenge.engineConfig.layoutStrategy, LayoutStrategyType.pyramid);
      expect(
        challenge.engineConfig.connectionStrategy,
        ConnectionStrategyType.implicitHeap,
      );
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
    });

    test('throws when an unknown constraint type is provided', () {
      final jsonString = '''
      {
        "metadata": {
          "title": "Test",
          "instruction": "Test"
        },
        "engineConfig": {
          "validationStrategy": "MAX_HEAP",
          "layoutStrategy": "PYRAMID",
          "connectionStrategy": "IMPLICIT_HEAP",
          "interactionMode": "SWAP",
          "constraints": [
            { "type": "UNKNOWN_CONSTRAINT", "foo": 1 }
          ]
        },
        "initialState": {
          "nodes": []
        }
      }
      ''';

      final Map<String, dynamic> jsonMap = json.decode(jsonString);

      expect(() => ChallengeModel.fromJson(jsonMap), throwsA(isA<Object>()));
    });
  });
}
