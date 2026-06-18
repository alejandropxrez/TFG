import 'package:algoquest/domain/enums/session_status.dart';
import 'challenge_spec.dart';
import 'structure_state.dart';

import 'package:algoquest/domain/entities/challenge_runtime_state.dart';

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

  bool get hasAttemptLimit => attemptsRemaining != null;

  bool get hasAttemptsRemaining {
    final remaining = attemptsRemaining;
    return remaining == null || remaining > 0;
  }

  bool get hasNoAttemptsRemaining {
    final remaining = attemptsRemaining;
    return remaining != null && remaining <= 0;
  }

  bool get canInteract {
    return status == SessionStatus.inProgress && hasAttemptsRemaining;
  }

  bool get canTryAgain {
    return hasAttemptsRemaining;
  }

  bool get canRevealAnswer {
    return status == SessionStatus.failed && hasNoAttemptsRemaining;
  }

  bool get canUndo {
    final runtime = runtimeState;
    return canInteract &&
        runtime is StructureRuntimeState &&
        runtime.history.isNotEmpty;
  }

  bool get canRedo {
    final runtime = runtimeState;
    return canInteract &&
        runtime is StructureRuntimeState &&
        runtime.redoStack.isNotEmpty;
  }

  static ChallengeRuntimeState _initialRuntimeStateFromSpec(
    ChallengeSpec spec,
  ) {
    StructureState structureStateFromContent(
      StructureChallengeContent content,
    ) {
      final engineConfig = content.engineConfig;
      final initialState = content.initialState;

      return StructureState.fromNodesAndEdges(
        type: engineConfig.structureType,
        nodes: initialState.nodes
            .map((node) => NodeState(id: node.id, value: node.value))
            .toList(growable: false),
        edges: initialState.edges
            .map((edge) => EdgeState(source: edge.source, target: edge.target))
            .toList(growable: false),
        slots: initialState.slots
            .map((slot) => SlotState(id: slot.id, index: slot.index))
            .toList(growable: false),
        inventory: initialState.inventory,
      );
    }

    return switch (spec.content) {
      StructureChallengeContent() => StructureRuntimeState(
        structure: structureStateFromContent(spec.structureContent),
      ),

      QuizChallengeContent() => const QuizRuntimeState(),

      IdentifyTargetChallengeContent(:final visualStructure) =>
        IdentifyTargetRuntimeState(
          visualState: structureStateFromContent(visualStructure),
        ),

      CategorizeChallengeContent() => const CategorizeRuntimeState(),
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
