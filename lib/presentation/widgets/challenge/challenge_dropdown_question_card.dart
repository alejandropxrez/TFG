import 'package:algoquest/presentation/widgets/challenge/challenge_select_box.dart';
import 'package:flutter/material.dart';

class ChallengeDropdownOption {
  final String id;
  final String label;

  const ChallengeDropdownOption({required this.id, required this.label});
}

class ChallengeDropdownQuestionCard extends StatelessWidget {
  final int questionNumber;
  final String leadingText;
  final String trailingText;
  final String? selectedOptionId;
  final List<ChallengeDropdownOption> options;
  final ValueChanged<String> onChanged;

  const ChallengeDropdownQuestionCard({
    super.key,
    required this.questionNumber,
    required this.leadingText,
    required this.trailingText,
    required this.selectedOptionId,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final hasTrailingText = trailingText.trim().isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8E4F2), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 8,
        runSpacing: 10,
        children: [
          Text(
            '$questionNumber.',
            style: const TextStyle(
              color: Color(0xFF6B3DEB),
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            leadingText,
            style: const TextStyle(
              color: Color(0xFF101235),
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
              height: 1.25,
            ),
          ),
          ChallengeSelectBox(
            selectedOptionId: selectedOptionId,
            options: options
                .map(
                  (option) =>
                      ChallengeSelectOption(id: option.id, label: option.label),
                )
                .toList(growable: false),
            placeholder: 'Selecciona una opción',
            width: 430,
            height: 50,
            onChanged: onChanged,
          ),
          if (hasTrailingText)
            Text(
              trailingText,
              style: const TextStyle(
                color: Color(0xFF101235),
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
                height: 1.25,
              ),
            ),
        ],
      ),
    );
  }
}
