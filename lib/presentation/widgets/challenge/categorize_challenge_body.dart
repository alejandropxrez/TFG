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
    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 12),
      itemCount: categorizeSpec.items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final item = categorizeSpec.items[index];

        return _CategorizeItemCard(
          itemText: item.text,
          selectedCategoryId: selectedCategoryByItemId[item.id],
          categoryOptions: [
            for (final category in categorizeSpec.categories)
              ChallengeSelectOption(id: category.id, label: category.label),
          ],
          onCategorySelected: (categoryId) {
            onCategorySelected(itemId: item.id, categoryId: categoryId);
          },
        );
      },
    );
  }
}

class _CategorizeItemCard extends StatelessWidget {
  final String itemText;
  final String? selectedCategoryId;
  final List<ChallengeSelectOption> categoryOptions;
  final ValueChanged<String> onCategorySelected;

  const _CategorizeItemCard({
    required this.itemText,
    required this.selectedCategoryId,
    required this.categoryOptions,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFBF8FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8D8FF), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            itemText,
            style: const TextStyle(
              color: Color(0xFF101235),
              fontSize: 14,
              height: 1.2,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          ChallengeSelectBox(
            selectedOptionId: selectedCategoryId,
            options: categoryOptions,
            onChanged: onCategorySelected,
            placeholder: 'Selecciona una categoría',
            height: 44,
          ),
        ],
      ),
    );
  }
}
