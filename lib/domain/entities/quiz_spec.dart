class QuizSpec {
  final String question;
  final List<QuizOption> options;
  final Set<String> correctOptionIds;
  final bool allowMultiple;

  QuizSpec({
    required this.question,
    required List<QuizOption> options,
    required Set<String> correctOptionIds,
    this.allowMultiple = false,
  }) : options = List.unmodifiable(options),
       correctOptionIds = Set.unmodifiable(correctOptionIds) {
    _validate();
  }

  bool get isSingleChoice => !allowMultiple;

  void _validate() {
    if (question.trim().isEmpty) {
      throw ArgumentError.value(
        question,
        'question',
        'A quiz question cannot be empty',
      );
    }

    if (options.length < 2) {
      throw ArgumentError.value(
        options,
        'options',
        'A quiz needs at least two options',
      );
    }

    final optionIds = options.map((option) => option.id).toList();
    final uniqueOptionIds = optionIds.toSet();

    if (uniqueOptionIds.length != optionIds.length) {
      throw ArgumentError.value(
        options,
        'options',
        'Quiz option IDs must be unique',
      );
    }

    if (options.any((option) => option.id.trim().isEmpty)) {
      throw ArgumentError.value(
        options,
        'options',
        'Quiz option IDs cannot be empty',
      );
    }

    if (options.any((option) => option.text.trim().isEmpty)) {
      throw ArgumentError.value(
        options,
        'options',
        'Quiz option text cannot be empty',
      );
    }

    if (correctOptionIds.isEmpty) {
      throw ArgumentError.value(
        correctOptionIds,
        'correctOptionIds',
        'A quiz needs at least one correct answer',
      );
    }

    if (!uniqueOptionIds.containsAll(correctOptionIds)) {
      throw ArgumentError.value(
        correctOptionIds,
        'correctOptionIds',
        'Every correct option ID must reference an existing option',
      );
    }

    if (isSingleChoice && correctOptionIds.length != 1) {
      throw ArgumentError.value(
        correctOptionIds,
        'correctOptionIds',
        'A single-choice quiz must have exactly one correct answer',
      );
    }
  }
}

class QuizOption {
  final String id;
  final String text;

  const QuizOption({required this.id, required this.text});
}
