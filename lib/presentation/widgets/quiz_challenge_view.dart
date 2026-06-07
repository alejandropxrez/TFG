import 'package:algoquest/domain/entities/quiz_spec.dart';
import 'package:flutter/material.dart';

class QuizChallengeView extends StatelessWidget {
  final QuizSpec quizSpec;
  final Set<String> selectedOptionIds;
  final void Function(String optionId) onSelectOption;

  const QuizChallengeView({
    super.key,
    required this.quizSpec,
    required this.selectedOptionIds,
    required this.onSelectOption,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              quizSpec.question,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 20),
            for (final option in quizSpec.options)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: ChoiceChip(
                  label: SizedBox(
                    width: double.infinity,
                    child: Text(option.text, textAlign: TextAlign.center),
                  ),
                  selected: selectedOptionIds.contains(option.id),
                  onSelected: (_) => onSelectOption(option.id),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
