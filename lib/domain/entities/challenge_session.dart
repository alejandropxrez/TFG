import 'package:algoquest/domain/enums/session_status.dart';
import 'challenge_spec.dart';
import 'structure_state.dart';

class ChallengeSession {
  final String sessionId;
  final String userId;
  final ChallengeSpec spec;
  final StructureState currentState;
  final List<StructureState> history;
  final List<StructureState> redoStack;
  final int movesUsed;
  final SessionStatus status;
  final DateTime startedAt;
  final DateTime updatedAt;

  const ChallengeSession({
    required this.sessionId,
    required this.userId,
    required this.spec,
    required this.currentState,
    required this.history,
    required this.redoStack,
    required this.movesUsed,
    required this.status,
    required this.startedAt,
    required this.updatedAt,
  });

  factory ChallengeSession.start({
    required String sessionId,
    required String userId,
    required ChallengeSpec spec,
  }) {
    final now = DateTime.now();

    final initialState = StructureState.fromNodesAndEdges(
      type: spec.engineConfig.structureType,
      nodes: spec.initialState.nodes
          .map((node) => NodeState(id: node.id, value: node.value))
          .toList(growable: false),
      edges: spec.initialState.edges
          .map((edge) => EdgeState(source: edge.source, target: edge.target))
          .toList(growable: false),
      slots: spec.initialState.slots
          .map((slot) => SlotState(id: slot.id, index: slot.index))
          .toList(growable: false),
      inventory: spec.initialState.inventory,
    );

    return ChallengeSession(
      sessionId: sessionId,
      userId: userId,
      spec: spec,
      currentState: initialState,
      history: const [],
      redoStack: const [],
      movesUsed: 0,
      status: SessionStatus.inProgress,
      startedAt: now,
      updatedAt: now,
    );
  }

  ChallengeSession copyWith({
    StructureState? currentState,
    List<StructureState>? history,
    List<StructureState>? redoStack,
    int? movesUsed,
    SessionStatus? status,
    DateTime? updatedAt,
  }) {
    return ChallengeSession(
      sessionId: sessionId,
      userId: userId,
      spec: spec,
      currentState: currentState ?? this.currentState,
      history: history ?? this.history,
      redoStack: redoStack ?? this.redoStack,
      movesUsed: movesUsed ?? this.movesUsed,
      status: status ?? this.status,
      startedAt: startedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
