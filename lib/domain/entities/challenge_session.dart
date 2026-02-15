import 'package:algoquest/domain/entities/challenge_spec.dart';

/// Runtime state of a challenge playthrough (mutable through copies/updates)
class ChallengeSession {
  final String sessionId;
  final String userId;
  final ChallengeSpec spec;

  /// Current state
  final List<ChallengeNodeState> nodes;
  final List<ChallengeEdgeState> edges;
  final List<ChallengeSlotState> slots;

  /// Progress tracking
  final int movesUsed;
  final bool isCompleted;

  const ChallengeSession({
    required this.sessionId,
    required this.userId,
    required this.spec,
    required this.nodes,
    required this.edges,
    required this.slots,
    required this.movesUsed,
    required this.isCompleted,
  });

  /// Factory to start a new session from a spec (initial snapshot)
  factory ChallengeSession.start({
    required String sessionId,
    required String userId,
    required ChallengeSpec spec,
  }) {
    return ChallengeSession(
      sessionId: sessionId,
      userId: userId,
      spec: spec,
      nodes: spec.initialState.nodes
          .map((n) => ChallengeNodeState(id: n.id, value: n.value))
          .toList(growable: false),
      edges: spec.initialState.edges
          .map((e) => ChallengeEdgeState(source: e.source, target: e.target))
          .toList(growable: false),
      slots: spec.initialState.slots
          .map(
            (s) => ChallengeSlotState(
              id: s.id,
              index: s.index,
              filledNodeId: null,
            ),
          )
          .toList(growable: false),
      movesUsed: 0,
      isCompleted: false,
    );
  }

  ChallengeSession copyWith({
    List<ChallengeNodeState>? nodes,
    List<ChallengeEdgeState>? edges,
    List<ChallengeSlotState>? slots,
    int? movesUsed,
    bool? isCompleted,
  }) {
    return ChallengeSession(
      sessionId: sessionId,
      userId: userId,
      spec: spec,
      nodes: nodes ?? this.nodes,
      edges: edges ?? this.edges,
      slots: slots ?? this.slots,
      movesUsed: movesUsed ?? this.movesUsed,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

/// Runtime nodes may carry extra flags (selected/locked/etc.)
class ChallengeNodeState {
  final String id;
  final int value;

  const ChallengeNodeState({required this.id, required this.value});

  ChallengeNodeState copyWith({int? value}) =>
      ChallengeNodeState(id: id, value: value ?? this.value);
}

class ChallengeEdgeState {
  final String source;
  final String target;
  const ChallengeEdgeState({required this.source, required this.target});
}

class ChallengeSlotState {
  final String id;
  final int? index;

  /// For fill-in-the-blanks: which node is currently placed here (if any)
  final String? filledNodeId;

  const ChallengeSlotState({
    required this.id,
    required this.index,
    required this.filledNodeId,
  });

  ChallengeSlotState copyWith({String? filledNodeId}) =>
      ChallengeSlotState(id: id, index: index, filledNodeId: filledNodeId);
}
