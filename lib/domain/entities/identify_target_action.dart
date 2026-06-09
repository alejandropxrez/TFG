class SubmitIdentifyTargetAction {
  final Set<String> selectedTargetIds;

  const SubmitIdentifyTargetAction({required this.selectedTargetIds});

  factory SubmitIdentifyTargetAction.single(String targetId) {
    return SubmitIdentifyTargetAction(selectedTargetIds: {targetId});
  }
}
