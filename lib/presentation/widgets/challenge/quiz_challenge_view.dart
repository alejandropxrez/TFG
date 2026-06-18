import 'package:algoquest/domain/entities/quiz_spec.dart';
import 'package:flutter/material.dart';

class QuizChallengeView extends StatelessWidget {
  final QuizSpec quizSpec;
  final Set<String> selectedOptionIds;
  final ValueChanged<String> onSelectOption;

  const QuizChallengeView({
    super.key,
    required this.quizSpec,
    required this.selectedOptionIds,
    required this.onSelectOption,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 12),
      itemCount: quizSpec.options.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final option = quizSpec.options[index];
        final selected = selectedOptionIds.contains(option.id);

        return _QuizOptionCard(
          label: _labelForIndex(index),
          text: option.text,
          selected: selected,
          allowMultiple: quizSpec.allowMultiple,
          onTap: () => onSelectOption(option.id),
        );
      },
    );
  }

  String _labelForIndex(int index) {
    const labels = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

    if (index >= 0 && index < labels.length) {
      return labels[index];
    }

    return '${index + 1}';
  }
}

class _QuizOptionCard extends StatelessWidget {
  final String label;
  final String text;
  final bool selected;
  final bool allowMultiple;
  final VoidCallback onTap;

  const _QuizOptionCard({
    required this.label,
    required this.text,
    required this.selected,
    required this.allowMultiple,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = selected
        ? const Color(0xFF7C4DFF)
        : const Color(0xFFEAE3FF);

    final backgroundColor = selected ? const Color(0xFFF5EFFF) : Colors.white;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOut,
          width: double.infinity,
          height: 58,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: selected ? 1.8 : 1.1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.035),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              _OptionBadge(
                label: label,
                selected: selected,
                allowMultiple: allowMultiple,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    color: selected
                        ? const Color(0xFF6B3DEB)
                        : const Color(0xFF101235),
                    fontSize: 13,
                    height: 1.25,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                  ),
                ),
              ),
              if (selected) ...[
                const SizedBox(width: 10),
                const _SelectedCheck(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _OptionBadge extends StatelessWidget {
  final String label;
  final bool selected;
  final bool allowMultiple;

  const _OptionBadge({
    required this.label,
    required this.selected,
    required this.allowMultiple,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? const Color(0xFF6B3DEB) : const Color(0xFF7C4DFF);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 140),
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: color,
        shape: allowMultiple ? BoxShape.rectangle : BoxShape.circle,
        borderRadius: allowMultiple ? BorderRadius.circular(10) : null,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: selected ? 0.24 : 0.14),
            blurRadius: selected ? 10 : 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Transform.translate(
        offset: Offset(0, -2),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _SelectedCheck extends StatelessWidget {
  const _SelectedCheck();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 22,
      height: 22,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Color(0xFF6B3DEB),
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.check_rounded, color: Colors.white, size: 15),
      ),
    );
  }
}
