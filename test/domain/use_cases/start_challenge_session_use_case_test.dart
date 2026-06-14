import 'package:algoquest/domain/use_cases/start_challenge_session_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:algoquest/domain/entities/challenge_session.dart';
import 'package:algoquest/domain/entities/challenge_spec.dart';
import 'package:algoquest/domain/entities/level_syllabus.dart';
import 'package:algoquest/domain/enums/session_status.dart';
import 'package:algoquest/domain/enums/structure_type.dart';
import 'package:algoquest/domain/repositories/content_repository.dart';
import 'package:algoquest/domain/strategies/bst_validation_strategy.dart';

class FakeContentRepository implements ContentRepository {
  final Map<String, ChallengeSpec> specsById = {};

  @override
  Future<ChallengeSpec> getChallenge(String challengeId) async {
    final spec = specsById[challengeId];
    if (spec == null) throw Exception('Challenge spec not found: $challengeId');
    return spec;
  }

  @override
  Future<LevelSyllabus> getLevelSyllabus(String levelId) {
    throw UnimplementedError();
  }
}

void main() {
  test(
    'StartChallengeSessionUseCase creates a new session from spec',
    () async {
      final repo = FakeContentRepository();

      repo.specsById['c1'] = ChallengeSpec(
        id: 'c1',
        title: 'BST insertion',
        instruction: 'Insert the node into the BST',
        theoryRef: 'bst_insert',
        constraints: const [MaxMovesConstraint(3)],
        content: StructureChallengeContent(
          engineConfig: ChallengeEngineConfig(
            structureType: StructureType.bst,
            validationStrategy: BstValidationStrategy(),
            layoutStrategy: LayoutStrategyType.linear,
            interactionMode: InteractionModeType.drag,
            connectionType: ConnectionType.explicit,
          ),
          initialState: const ChallengeInitialStateSpec(
            nodes: [
              ChallengeNodeSpec(id: 'n1', value: 10),
              ChallengeNodeSpec(id: 'n2', value: 5),
            ],
            edges: [ChallengeEdgeSpec(source: 'n1', target: 'n2')],
            slots: [ChallengeSlotSpec(id: 's1', index: 0)],
          ),
        ),
      );

      final useCase = StartChallengeSessionUseCase(repo);

      final session = await useCase(
        userId: 'user_1',
        challengeId: 'c1',
        sessionId: 'session_123',
      );

      expect(session, isA<ChallengeSession>());
      expect(session.sessionId, 'session_123');
      expect(session.userId, 'user_1');
      expect(session.spec.title, 'BST insertion');

      // Session starts from StructureState built from spec
      expect(session.structureRuntimeState.structure.nodes.length, 2);
      expect(session.structureRuntimeState.structure.nodes['n1']?.value, 10);
      expect(session.structureRuntimeState.structure.nodes['n2']?.value, 5);

      expect(session.structureRuntimeState.structure.edges.length, 1);
      expect(session.structureRuntimeState.structure.edges.first.source, 'n1');
      expect(session.structureRuntimeState.structure.edges.first.target, 'n2');

      // Initial session metadata
      expect(session.structureRuntimeState.movesUsed, 0);
      expect(session.structureRuntimeState.history, isEmpty);
      expect(session.status, SessionStatus.inProgress);

      // Timestamps should be initialized
      expect(session.startedAt, isNotNull);
      expect(session.updatedAt, isNotNull);
    },
  );
}
