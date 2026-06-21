import 'package:algoquest/domain/entities/challenge_runtime_state.dart';
import 'package:algoquest/domain/enums/session_status.dart';

import 'challenge_spec.dart';
import 'structure_state.dart';

/// Represents the complete state of an active challenge session.
///
/// A session associates a user with a challenge specification and stores the
/// transient runtime state produced while the challenge is being solved.
///
/// The entity also controls whether the user can interact, retry, reveal the
/// answer, or use undo and redo operations.
class ChallengeSession {
  /// Unique identifier of this challenge attempt.
  final String sessionId;

  /// Identifier of the user solving the challenge.
  final String userId;

  /// Immutable definition of the challenge being executed.
  final ChallengeSpec spec;

  /// Current interaction state associated with the challenge type.
  final ChallengeRuntimeState runtimeState;

  /// Current lifecycle status of the session.
  final SessionStatus status;

  /// Time at which the session was created.
  final DateTime startedAt;

  /// Time of the most recent session update.
  final DateTime updatedAt;

  /// Number of attempts still available.
  ///
  /// A `null` value means that the challenge has no attempt limit.
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

  /// Creates a new session for [spec].
  ///
  /// The initial runtime state is selected according to the concrete challenge
  /// content. The session starts with an `inProgress` status and inherits its
  /// attempt limit from the challenge specification.
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

  /// Whether this challenge defines a finite number of attempts.
  bool get hasAttemptLimit => attemptsRemaining != null;

  /// Whether the user can still submit an answer.
  ///
  /// Challenges without an attempt limit always return `true`.
  bool get hasAttemptsRemaining {
    final remaining = attemptsRemaining;
    return remaining == null || remaining > 0;
  }

  /// Whether the challenge has an attempt limit that has been exhausted.
  bool get hasNoAttemptsRemaining {
    final remaining = attemptsRemaining;
    return remaining != null && remaining <= 0;
  }

  /// Whether the challenge currently accepts user interactions.
  bool get canInteract {
    return status == SessionStatus.inProgress && hasAttemptsRemaining;
  }

  /// Whether the current challenge attempt can be restarted.
  bool get canTryAgain => hasAttemptsRemaining;

  /// Whether the correct answer can be revealed.
  ///
  /// Revealing is allowed only after the session has failed and all available
  /// attempts have been consumed.
  bool get canRevealAnswer {
    return status == SessionStatus.failed && hasNoAttemptsRemaining;
  }

  /// Whether a previous structural state can be restored.
  bool get canUndo {
    final runtime = runtimeState;

    return canInteract &&
        runtime is StructureRuntimeState &&
        runtime.history.isNotEmpty;
  }

  /// Whether a previously undone structural state can be reapplied.
  bool get canRedo {
    final runtime = runtimeState;

    return canInteract &&
        runtime is StructureRuntimeState &&
        runtime.redoStack.isNotEmpty;
  }

  /// Creates the initial runtime state required by [spec].
  ///
  /// Structure challenges receive a mutable structure derived from their
  /// initial JSON configuration. Quiz, identification, and categorization
  /// challenges receive their corresponding empty interaction state.
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

  /// Returns the runtime state as a [StructureRuntimeState].
  ///
  /// Throws a [StateError] when this session belongs to a challenge that does
  /// not manipulate a structure.
  StructureRuntimeState get structureRuntimeState {
    final state = runtimeState;

    if (state is StructureRuntimeState) {
      return state;
    }

    throw StateError('Challenge session does not contain a structure state.');
  }

  /// Creates a new session with selected values replaced.
  ///
  /// Session identity, user, specification, and start time are preserved.
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
      // NOTE: With the current implementation, it is not possible to explicitly set
      // attemptsRemaining to null, because null means “keep the previous value.”
      // This is not an issue if a session never switches between limited and unlimited attempts.
      // If you need to support that behavior, a sentinel value or a wrapper would be required.
      attemptsRemaining: attemptsRemaining ?? this.attemptsRemaining,
    );
  }
}
