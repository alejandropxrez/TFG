import 'package:flutter_test/flutter_test.dart';

import 'package:algoquest/data/datasources/local/content_local_data_source.dart';
import 'package:algoquest/data/models/challenge_model.dart';
import 'package:algoquest/data/models/level_syllabus_model.dart';
import 'package:algoquest/data/repositories/content_repository_impl.dart';

class FakeContentLocalDataSource implements ContentLocalDataSource {
  final Map<String, LevelSyllabusModel> levels;
  final Map<String, ChallengeModel> challenges;

  FakeContentLocalDataSource({required this.levels, required this.challenges});

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
}
