import 'package:algoquest/domain/entities/challenge_runtime_state.dart';
import 'package:algoquest/domain/entities/challenge_session.dart';
import 'package:algoquest/domain/entities/challenge_spec.dart';
import 'package:algoquest/domain/entities/identify_target_action.dart';
import 'package:algoquest/domain/entities/identify_target_spec.dart';
import 'package:algoquest/domain/enums/session_status.dart';
import 'package:algoquest/domain/enums/structure_type.dart';
import 'package:algoquest/domain/strategies/max_heap_validation_strategy.dart';
import 'package:algoquest/domain/use_cases/check_identify_target_use_case.dart';
import 'package:algoquest/domain/use_cases/submit_identify_target_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  ChallengeSpec buildIdentifyNodeSpec({
    Set<String> correctTargetIds = const {'n2'},
    bool allowMultiple = false,
  }) {
    return ChallengeSpec(
      id: 'identify_heap_error',
      title: 'Nodo incorrecto',
      instruction: 'Toca el nodo que rompe la propiedad',
      theoryRef: null,
      constraints: const [],
      content: IdentifyTargetChallengeContent(
        identifySpec: IdentifyTargetSpec(
          prompt: '¿Qué nodo rompe la propiedad de max-heap?',
          targetType: IdentifyTargetType.node,
          correctTargetIds: correctTargetIds,
          allowMultiple: allowMultiple,
        ),
        visualStructure: StructureChallengeContent(
          engineConfig: ChallengeEngineConfig(
            structureType: StructureType.heap,
            validationStrategy: MaxHeapValidationStrategy(),
            layoutStrategy: LayoutStrategyType.pyramid,
            interactionMode: InteractionModeType.swap,
            connectionType: ConnectionType.explicit,
          ),
          initialState: const ChallengeInitialStateSpec(
            nodes: [
              ChallengeNodeSpec(id: 'n1', value: 10),
              ChallengeNodeSpec(id: 'n2', value: 15),
              ChallengeNodeSpec(id: 'n3', value: 7),
            ],
            edges: [
              ChallengeEdgeSpec(source: 'n1', target: 'n2'),
              ChallengeEdgeSpec(source: 'n1', target: 'n3'),
            ],
            slots: [],
            inventory: [],
          ),
        ),
      ),
    );
  }

  test('ChallengeSession.start creates IdentifyTargetRuntimeState', () {
    final session = ChallengeSession.start(
      sessionId: 'session_1',
      userId: 'user_1',
      spec: buildIdentifyNodeSpec(),
    );

    expect(session.runtimeState, isA<IdentifyTargetRuntimeState>());

    final runtimeState = session.runtimeState as IdentifyTargetRuntimeState;

    expect(runtimeState.selectedTargetIds, isEmpty);
    expect(runtimeState.submitted, isFalse);
    expect(session.status, SessionStatus.inProgress);
  });

  test('SubmitIdentifyTargetUseCase stores valid target', () {
    final session = ChallengeSession.start(
      sessionId: 'session_1',
      userId: 'user_1',
      spec: buildIdentifyNodeSpec(),
    );

    final updated = const SubmitIdentifyTargetUseCase()(
      session: session,
      action: SubmitIdentifyTargetAction.single('n2'),
    );

    final runtimeState = updated.runtimeState as IdentifyTargetRuntimeState;

    expect(runtimeState.selectedTargetIds, {'n2'});
    expect(runtimeState.submitted, isTrue);
    expect(updated.status, SessionStatus.inProgress);
  });

  test('SubmitIdentifyTargetUseCase ignores unknown target', () {
    final session = ChallengeSession.start(
      sessionId: 'session_1',
      userId: 'user_1',
      spec: buildIdentifyNodeSpec(),
    );

    final updated = const SubmitIdentifyTargetUseCase()(
      session: session,
      action: SubmitIdentifyTargetAction.single('missing'),
    );

    expect(identical(updated, session), isTrue);
  });

  test(
    'SubmitIdentifyTargetUseCase ignores multiple targets when single target challenge',
    () {
      final session = ChallengeSession.start(
        sessionId: 'session_1',
        userId: 'user_1',
        spec: buildIdentifyNodeSpec(),
      );

      final updated = const SubmitIdentifyTargetUseCase()(
        session: session,
        action: const SubmitIdentifyTargetAction(
          selectedTargetIds: {'n2', 'n3'},
        ),
      );

      expect(identical(updated, session), isTrue);
    },
  );

  test('SubmitIdentifyTargetUseCase accepts multiple targets when allowed', () {
    final session = ChallengeSession.start(
      sessionId: 'session_1',
      userId: 'user_1',
      spec: buildIdentifyNodeSpec(
        correctTargetIds: const {'n2', 'n3'},
        allowMultiple: true,
      ),
    );

    final updated = const SubmitIdentifyTargetUseCase()(
      session: session,
      action: const SubmitIdentifyTargetAction(selectedTargetIds: {'n2', 'n3'}),
    );

    final runtimeState = updated.runtimeState as IdentifyTargetRuntimeState;

    expect(runtimeState.selectedTargetIds, {'n2', 'n3'});
    expect(runtimeState.submitted, isTrue);
  });

  test(
    'CheckIdentifyTargetUseCase marks session completed when target is correct',
    () {
      final session = ChallengeSession.start(
        sessionId: 'session_1',
        userId: 'user_1',
        spec: buildIdentifyNodeSpec(),
      );

      final answered = const SubmitIdentifyTargetUseCase()(
        session: session,
        action: SubmitIdentifyTargetAction.single('n2'),
      );

      final checked = const CheckIdentifyTargetUseCase()(answered);

      expect(checked.status, SessionStatus.completed);
    },
  );

  test(
    'CheckIdentifyTargetUseCase keeps session in progress when target is incorrect',
    () {
      final session = ChallengeSession.start(
        sessionId: 'session_1',
        userId: 'user_1',
        spec: buildIdentifyNodeSpec(),
      );

      final answered = const SubmitIdentifyTargetUseCase()(
        session: session,
        action: SubmitIdentifyTargetAction.single('n3'),
      );

      final checked = const CheckIdentifyTargetUseCase()(answered);

      expect(checked.status, SessionStatus.inProgress);
    },
  );

  test(
    'CheckIdentifyTargetUseCase does not change session when target was not submitted',
    () {
      final session = ChallengeSession.start(
        sessionId: 'session_1',
        userId: 'user_1',
        spec: buildIdentifyNodeSpec(),
      );

      final checked = const CheckIdentifyTargetUseCase()(session);

      expect(identical(checked, session), isTrue);
      expect(checked.status, SessionStatus.inProgress);
    },
  );
}
