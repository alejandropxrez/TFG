import 'package:algoquest/domain/enums/session_status.dart';
import 'challenge_spec.dart';
import 'structure_state.dart';

import 'package:algoquest/domain/entities/challenge_runtime_state.dart';
import 'package:algoquest/domain/enums/session_status.dart';

import 'challenge_spec.dart';
import 'structure_state.dart';

class ChallengeSession {
  final String sessionId;
  final String userId;
  final ChallengeSpec spec;
  final ChallengeRuntimeState runtimeState;
  final SessionStatus status;
  final DateTime startedAt;
  final DateTime updatedAt;
  final int? attemptsRemaining;

  const ChallengeSession({
    required this.sessionId,
    required this.userId,
    required this.spec,
    required this.runtimeState,
    required this.status,
    required this.startedAt,
    required this.updatedAt,
    required this.attemptsRemaining,
  });

  factory ChallengeSession.start({
    required String sessionId,
    required String userId,
    required ChallengeSpec spec,
  }) {
    final now = DateTime.now();

    return ChallengeSession(
      sessionId: sessionId,
      userId: userId,
      spec: spec,
      runtimeState: _initialRuntimeStateFromSpec(spec),
      status: SessionStatus.inProgress,
      startedAt: now,
      updatedAt: now,
      attemptsRemaining: spec.maxAttempts,
    );
  }

  static ChallengeRuntimeState _initialRuntimeStateFromSpec(
    ChallengeSpec spec,
  ) {
    return switch (spec.content) {
      StructureChallengeContent(:final engineConfig, :final initialState) =>
        StructureRuntimeState(
          structure: StructureState.fromNodesAndEdges(
            type: engineConfig.structureType,
            nodes: initialState.nodes
                .map((node) => NodeState(id: node.id, value: node.value))
                .toList(growable: false),
            edges: initialState.edges
                .map(
                  (edge) => EdgeState(source: edge.source, target: edge.target),
                )
                .toList(growable: false),
            slots: initialState.slots
                .map((slot) => SlotState(id: slot.id, index: slot.index))
                .toList(growable: false),
            inventory: initialState.inventory,
          ),
        ),
      QuizChallengeContent() => const QuizRuntimeState(),
    };
  }

  StructureRuntimeState get structureRuntimeState {
    final state = runtimeState;

    if (state is StructureRuntimeState) {
      return state;
    }

    throw StateError('Challenge session does not contain a structure state.');
  }

  ChallengeSession copyWith({
    ChallengeRuntimeState? runtimeState,
    SessionStatus? status,
    DateTime? updatedAt,
    int? attemptsRemaining,
  }) {
    return ChallengeSession(
      sessionId: sessionId,
      userId: userId,
      spec: spec,
      runtimeState: runtimeState ?? this.runtimeState,
      status: status ?? this.status,
      startedAt: startedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      attemptsRemaining: attemptsRemaining ?? this.attemptsRemaining,
    );
  }
}
