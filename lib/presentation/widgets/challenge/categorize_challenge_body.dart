import 'package:algoquest/domain/entities/categorize_spec.dart';
import 'package:algoquest/presentation/widgets/challenge/components/challenge_select_box.dart';
import 'package:flutter/material.dart';

class CategorizeChallengeBody extends StatelessWidget {
  final CategorizeSpec categorizeSpec;
  final Map<String, String> selectedCategoryByItemId;
  final void Function({required String itemId, required String categoryId})
  onCategorySelected;

  const CategorizeChallengeBody({
    super.key,
    required this.categorizeSpec,
    required this.selectedCategoryByItemId,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final item in categorizeSpec.items) ...[
          _CategorizeItemCard(
            text: item.text,
            selectedCategoryId: selectedCategoryByItemId[item.id],
            categories: categorizeSpec.categories
                .map(
                  (category) => ChallengeSelectOption(
                    id: category.id,
                    label: category.label,
                  ),
                )
                .toList(growable: false),
            onChanged: (categoryId) {
              onCategorySelected(itemId: item.id, categoryId: categoryId);
            },
          ),
          if (item != categorizeSpec.items.last) const SizedBox(height: 14),
        ],
      ],
    );
  }
}

class _CategorizeItemCard extends StatelessWidget {
  final String text;
  final String? selectedCategoryId;
  final List<ChallengeSelectOption> categories;
  final ValueChanged<String> onChanged;

  const _CategorizeItemCard({
    required this.text,
    required this.selectedCategoryId,
    required this.categories,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F4FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8DFFF), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: const TextStyle(
              color: Color(0xFF101235),
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 10),
          ChallengeSelectBox(
            selectedOptionId: selectedCategoryId,
            options: categories,
            placeholder: 'Categoría',
            width: double.infinity,
            height: 44,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
