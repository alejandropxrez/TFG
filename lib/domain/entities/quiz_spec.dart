class QuizSpec {
  final String question;
  final List<QuizOption> options;
  final Set<String> correctOptionIds;
  final bool allowMultiple;

  const QuizSpec({
    required this.question,
    required this.options,
    required this.correctOptionIds,
    this.allowMultiple = false,
  }) : assert(options.length >= 2, 'A quiz needs at least two options'),
       assert(correctOptionIds.length >= 1, 'A quiz needs a correct answer');

  bool get isSingleChoice => !allowMultiple;
}

class QuizOption {
  final String id;
  final String text;

  const QuizOption({required this.id, required this.text});
}
