import 'package:algoquest/domain/entities/level_syllabus.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:algoquest/domain/entities/challenge_session.dart';
import 'package:algoquest/domain/entities/challenge_spec.dart';
import 'package:algoquest/domain/repositories/content_repository.dart';
import 'package:algoquest/domain/usecases/start_challenge_session_use_case.dart';

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
        title: 'BST insertion',
        instruction: 'Insert the node into the BST',
        theoryRef: 'bst_insert',
        engineConfig: const ChallengeEngineConfig(
          validationStrategy: ValidationStrategyType.bst,
          layoutStrategy: LayoutStrategyType.linear,
          connectionStrategy: ConnectionStrategyType.explicit,
          interactionMode: InteractionModeType.drag,
          constraints: [MaxMovesConstraint(3)],
        ),
        initialState: const ChallengeInitialStateSpec(
          nodes: [
            ChallengeNodeSpec(id: 'n1', value: 10),
            ChallengeNodeSpec(id: 'n2', value: 5),
          ],
          edges: [ChallengeEdgeSpec(source: 'n1', target: 'n2')],
          slots: [ChallengeSlotSpec(id: 's1', index: 0)],
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

      // Session should start with initial snapshot from spec
      expect(session.nodes.length, 2);
      expect(session.nodes.first.id, 'n1');
      expect(session.nodes.first.value, 10);

      expect(session.edges.length, 1);
      expect(session.slots.length, 1);

      // Initial progress defaults
      expect(session.movesUsed, 0);
      expect(session.isCompleted, false);

      // Slot starts empty
      expect(session.slots.first.filledNodeId, isNull);
    },
  );
}
