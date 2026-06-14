import 'package:algoquest/domain/strategies/max_heap_validation_strategy.dart';
import 'package:algoquest/domain/use_cases/load_challenge_spec_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:algoquest/domain/entities/challenge_spec.dart';
import 'package:algoquest/domain/entities/level_syllabus.dart';
import 'package:algoquest/domain/enums/structure_type.dart';
import 'package:algoquest/domain/repositories/content_repository.dart';

class FakeContentRepository implements ContentRepository {
  ChallengeSpec? spec;

  @override
  Future<ChallengeSpec> getChallenge(String challengeId) async {
    if (spec == null) throw Exception('missing spec');
    return spec!;
  }

  @override
  Future<LevelSyllabus> getLevelSyllabus(String levelId) {
    throw UnimplementedError();
  }

  @override
  Future<String?> getNextLevelId(String currentLevelId) {
    throw UnimplementedError();
  }
}

void main() {
  test('returns challenge spec from repository', () async {
    final repo = FakeContentRepository();

    repo.spec = ChallengeSpec(
      id: 'c1',
      title: 't',
      instruction: 'i',
      theoryRef: null,
      constraints: const [],
      content: StructureChallengeContent(
        engineConfig: ChallengeEngineConfig(
          structureType: StructureType.heap,
          validationStrategy: MaxHeapValidationStrategy(),
          layoutStrategy: LayoutStrategyType.pyramid,
          interactionMode: InteractionModeType.swap,
          connectionType: ConnectionType.explicit,
        ),
        initialState: const ChallengeInitialStateSpec(
          nodes: [],
          edges: [],
          slots: [],
        ),
      ),
    );

    final useCase = LoadChallengeSpecUseCase(repo);
    final result = await useCase('c1');

    expect(result.title, 't');
    expect(result.instruction, 'i');
    expect(result.engineConfig.structureType, StructureType.heap);
    expect(
      result.engineConfig.validationStrategy,
      isA<MaxHeapValidationStrategy>(),
    );
  });
}
