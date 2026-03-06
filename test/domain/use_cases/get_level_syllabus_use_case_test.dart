import 'package:algoquest/domain/entities/challenge_spec.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:algoquest/domain/entities/level_syllabus.dart';
import 'package:algoquest/domain/repositories/content_repository.dart';
import 'package:algoquest/domain/usecases/get_level_syllabus_use_case.dart';

class FakeContentRepository implements ContentRepository {
  LevelSyllabus? level;

  @override
  Future<LevelSyllabus> getLevelSyllabus(String levelId) async {
    if (level == null) throw Exception('missing level');
    return level!;
  }

  @override
  Future<ChallengeSpec> getChallenge(String challengeId) {
    throw UnimplementedError();
  }
}

void main() {
  test('returns level syllabus from repository', () async {
    final repo = FakeContentRepository();
    repo.level = const LevelSyllabus(
      id: 'l1',
      title: 'Heaps Intro',
      topic: LevelTopic.heaps,
      challenges: ['c1'],
      rewards: LevelRewards(xp: 10, stars: 1),
    );

    final useCase = GetLevelSyllabusUseCase(repo);
    final result = await useCase('l1');

    expect(result.id, 'l1');
    expect(result.title, 'Heaps Intro');
  });
}
