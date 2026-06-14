import 'package:algoquest/domain/entities/challenge_runtime_state.dart';
import 'package:algoquest/domain/entities/challenge_session.dart';
import 'package:algoquest/domain/entities/challenge_spec.dart';
import 'package:algoquest/domain/entities/identify_target_action.dart';
import 'package:algoquest/domain/enums/session_status.dart';
import 'package:algoquest/domain/entities/identify_target_spec.dart';

class SubmitIdentifyTargetUseCase {
  const SubmitIdentifyTargetUseCase();

  ChallengeSession call({
    required ChallengeSession session,
    required SubmitIdentifyTargetAction action,
  }) {
    final content = session.spec.content;
    final runtimeState = session.runtimeState;

    if (content is! IdentifyTargetChallengeContent ||
        runtimeState is! IdentifyTargetRuntimeState) {
      return session;
    }

    final selected = action.selectedTargetIds;

    if (selected.isEmpty) {
      return session;
    }

    if (content.identifySpec.isSingleTarget && selected.length != 1) {
      return session;
    }

    final availableTargetIds = _availableTargetIds(content);

    if (!availableTargetIds.containsAll(selected)) {
      return session;
    }

    return session.copyWith(
      runtimeState: runtimeState.copyWith(
        selectedTargetIds: selected,
        submitted: true,
      ),
      status: SessionStatus.inProgress,
      updatedAt: DateTime.now(),
    );
  }

  Set<String> _availableTargetIds(IdentifyTargetChallengeContent content) {
    switch (content.identifySpec.targetType) {
      case IdentifyTargetType.node:
        return content.visualStructure.initialState.nodes
            .map((node) => node.id)
            .toSet();

      case IdentifyTargetType.edge:
        return content.visualStructure.initialState.edges
            .map((edge) => '${edge.source}->${edge.target}')
            .toSet();
    }
  }
}
