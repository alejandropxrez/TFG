import 'package:flutter_test/flutter_test.dart';

import 'package:algoquest/data/datasources/local/content_local_data_source.dart';
import 'package:algoquest/data/models/challenge_model.dart';
import 'package:algoquest/data/models/level_syllabus_model.dart';
import 'package:algoquest/data/models/syllabus_model.dart';
import 'package:algoquest/data/repositories/content_repository_impl.dart';

class FakeContentLocalDataSource implements ContentLocalDataSource {
  final SyllabusModel syllabus;
  final Map<String, LevelSyllabusModel> levels;
  final Map<String, ChallengeModel> challenges;

  FakeContentLocalDataSource({
    required this.syllabus,
    required this.levels,
    required this.challenges,
  });

  @override
  Future<SyllabusModel> getSyllabus() async {
    return syllabus;
  }

  @override
  Future<LevelSyllabusModel> getLevelSyllabus(String levelId) async {
    final level = levels[levelId];
    if (level == null) throw Exception('level not found');
    return level;
  }

  @override
  Future<ChallengeModel> getChallenge(String challengeId) async {
    final c = challenges[challengeId];
    if (c == null) throw Exception('challenge not found');
    return c;
  }
}

void main() {
  test('ContentRepositoryImpl maps LevelSyllabusModel to domain', () async {
    final ds = FakeContentLocalDataSource(
      syllabus: _testSyllabus(),
      levels: {
        'level_1': LevelSyllabusModel(
          id: 'level_1',
          title: 'Heaps Intro',
          topic: LevelTopic.heaps,
          challenges: const ['c1'],
          rewards: const RewardsModel(xp: 10, stars: 1),
        ),
      },
      challenges: {},
    );

    final repo = ContentRepositoryImpl(ds);
    final level = await repo.getLevelSyllabus('level_1');

    expect(level.id, 'level_1');
    expect(level.title, 'Heaps Intro');
  });

  test(
    'ContentRepositoryImpl returns next level id from syllabus order',
    () async {
      final ds = FakeContentLocalDataSource(
        syllabus: _testSyllabus(),
        levels: const {},
        challenges: const {},
      );

      final repo = ContentRepositoryImpl(ds);

      final nextLevelId = await repo.getNextLevelId('level_1');

      expect(nextLevelId, 'level_2');
    },
  );

  test(
    'ContentRepositoryImpl returns null when current level is last',
    () async {
      final ds = FakeContentLocalDataSource(
        syllabus: _testSyllabus(),
        levels: const {},
        challenges: const {},
      );

      final repo = ContentRepositoryImpl(ds);

      final nextLevelId = await repo.getNextLevelId('level_3');

      expect(nextLevelId, isNull);
    },
  );

  test('ContentRepositoryImpl throws when current level is missing', () async {
    final ds = FakeContentLocalDataSource(
      syllabus: _testSyllabus(),
      levels: const {},
      challenges: const {},
    );

    final repo = ContentRepositoryImpl(ds);

    expect(
      () => repo.getNextLevelId('missing_level'),
      throwsA(isA<StateError>()),
    );
  });
}

SyllabusModel _testSyllabus() {
  return const SyllabusModel(
    title: 'AlgoQuest',
    phases: [
      SyllabusPhaseModel(
        id: 'phase_1',
        title: 'Phase 1',
        levels: [
          SyllabusLevelRefModel(id: 'level_1'),
          SyllabusLevelRefModel(id: 'level_2'),
        ],
      ),
      SyllabusPhaseModel(
        id: 'phase_2',
        title: 'Phase 2',
        levels: [SyllabusLevelRefModel(id: 'level_3')],
      ),
    ],
  );
}
