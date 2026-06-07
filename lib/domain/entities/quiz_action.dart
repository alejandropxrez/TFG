class SubmitQuizAnswerAction {
  final Set<String> selectedOptionIds;

  const SubmitQuizAnswerAction({required this.selectedOptionIds});

  factory SubmitQuizAnswerAction.single(String optionId) {
    return SubmitQuizAnswerAction(selectedOptionIds: {optionId});
  }
}
