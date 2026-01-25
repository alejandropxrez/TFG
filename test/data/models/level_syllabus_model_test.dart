import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:algoquest/data/models/level_syllabus_model.dart';

void main() {
  group('LevelSyllabusModel JSON parsing', () {
    test('parses a valid level syllabus JSON correctly', () {
      final jsonString = '''
      {
        "id": "level_bst_insertion",
        "title": "Inserción en BST",
        "topic": "BST",
        "challenges": ["bst_ins_tuto", "bst_ins_easy", "bst_ins_hard"],
        "rewards": { "xp": 100, "stars": 3 }
      }
      ''';

      final Map<String, dynamic> jsonMap = json.decode(jsonString);

      final level = LevelSyllabusModel.fromJson(jsonMap);

      expect(level.id, 'level_bst_insertion');
      expect(level.title, 'Inserción en BST');
      expect(level.topic, LevelTopic.bst);
      expect(level.challenges, [
        'bst_ins_tuto',
        'bst_ins_easy',
        'bst_ins_hard',
      ]);
      expect(level.rewards.xp, 100);
      expect(level.rewards.stars, 3);
    });

    test('throws FormatException for unknown topic', () {
      final jsonString = '''
      {
        "id": "level_x",
        "title": "Nivel X",
        "topic": "GRAPHS",
        "challenges": [],
        "rewards": { "xp": 10, "stars": 1 }
      }
      ''';

      final Map<String, dynamic> jsonMap = json.decode(jsonString);

      expect(
        () => LevelSyllabusModel.fromJson(jsonMap),
        throwsA(isA<FormatException>()),
      );
    });

    test('serializes topic back to uppercase string', () {
      final level = LevelSyllabusModel(
        id: 'level_heaps_1',
        title: 'Heaps 1',
        topic: LevelTopic.heaps,
        challenges: const ['heap_1'],
        rewards: const RewardsModel(xp: 50, stars: 2),
      );

      final jsonMap = level.toJson();

      expect(jsonMap['topic'], 'HEAPS');

      final rewards = jsonMap['rewards'] as RewardsModel;
      expect(rewards.xp, 50);
      expect(rewards.stars, 2);
    });
  });
}
