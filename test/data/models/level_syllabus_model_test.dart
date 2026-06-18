import 'dart:convert';

import 'package:algoquest/data/mappers/level_syllabus_mapper.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:algoquest/data/models/level_syllabus_model.dart';

void main() {
  group('LevelSyllabusModel JSON parsing', () {
    test('parses a valid level syllabus JSON correctly', () {
      final jsonString = '''
      {
        "id": "level_bst_insertion",
        "title": "Inserción en BST",
        "subtitle": "Aprende a insertar nodos en un BST",
        "topic": "BST",
        "challenges": ["bst_ins_tuto", "bst_ins_easy", "bst_ins_hard"],
        "rewards": { "xp": 100, "stars": 3 }
      }
      ''';

      final Map<String, dynamic> jsonMap = json.decode(jsonString);

      final level = LevelSyllabusModel.fromJson(jsonMap);

      expect(level.id, 'level_bst_insertion');
      expect(level.title, 'Inserción en BST');
      expect(level.subtitle, 'Aprende a insertar nodos en un BST');
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

    test('defaults subtitle to empty string when omitted', () {
      final level = LevelSyllabusModel.fromJson({
        'id': 'level_heaps_1',
        'title': 'Heaps 1',
        'topic': 'HEAPS',
        'challenges': ['heap_1'],
        'rewards': {'xp': 50, 'stars': 2},
      });

      expect(level.subtitle, '');
    });
  });

  test('parses level theory from json', () {
    final model = LevelSyllabusModel.fromJson({
      'id': 'level_heap_intro',
      'title': 'Introducción a Heaps',
      'topic': 'HEAPS',
      'theory': {
        'id': 'test',
        'title': '¿Qué es un Max-Heap?',
        'content': 'Un Max-Heap mantiene el valor máximo en la raíz.',
        'keyPoints': [
          'La raíz contiene el valor máximo.',
          'Cada padre debe ser mayor o igual que sus hijos.',
        ],
      },
      'challenges': ['quiz_heap_property'],
      'rewards': {'xp': 100, 'stars': 3, 'lives': 1},
    });

    expect(model.theory, isNotNull);
    expect(model.theory!.title, '¿Qué es un Max-Heap?');
    expect(model.theory!.content, contains('valor máximo'));
    expect(model.theory!.keyPoints, hasLength(2));
  });

  test('maps level theory to domain', () {
    final model = LevelSyllabusModel.fromJson({
      'id': 'level_heap_intro',
      'title': 'Introducción a Heaps',
      'topic': 'HEAPS',
      'theory': {
        'id': 'test',
        'title': '¿Qué es un Max-Heap?',
        'content': 'Un Max-Heap mantiene el valor máximo en la raíz.',
        'keyPoints': ['La raíz contiene el valor máximo.'],
      },
      'challenges': ['quiz_heap_property'],
      'rewards': {'xp': 100, 'stars': 3, 'lives': 1},
    });

    final domain = LevelSyllabusMapper.toDomain(model);

    expect(domain.theory, isNotNull);
    expect(domain.theory!.title, '¿Qué es un Max-Heap?');
    expect(domain.theory!.keyPoints, ['La raíz contiene el valor máximo.']);
  });

  test('maps subtitle to domain', () {
    final model = LevelSyllabusModel.fromJson({
      'id': 'level_heap_intro',
      'title': 'Introducción a Heaps',
      'subtitle': 'Repara heaps usando intercambios',
      'topic': 'HEAPS',
      'challenges': ['quiz_heap_property'],
      'rewards': {'xp': 100, 'stars': 3},
    });

    final domain = LevelSyllabusMapper.toDomain(model);

    expect(domain.subtitle, 'Repara heaps usando intercambios');
  });
}
