import 'package:algoquest/domain/entities/categorize_spec.dart';
import 'package:flutter/material.dart';

class CategorizeChallengeView extends StatelessWidget {
  final CategorizeSpec categorizeSpec;
  final Map<String, String> selectedCategoryByItemId;
  final void Function({required String itemId, required String categoryId})
  onCategorySelected;

  const CategorizeChallengeView({
    super.key,
    required this.categorizeSpec,
    required this.selectedCategoryByItemId,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          categorizeSpec.prompt,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        for (final item in categorizeSpec.items)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _CategorizeItemCard(
              item: item,
              categories: categorizeSpec.categories,
              selectedCategoryId: selectedCategoryByItemId[item.id],
              onChanged: (categoryId) {
                if (categoryId == null) return;

                onCategorySelected(itemId: item.id, categoryId: categoryId);
              },
            ),
          ),
      ],
    );
  }
}

class _CategorizeItemCard extends StatelessWidget {
  final CategorizeItem item;
  final List<CategorizeCategory> categories;
  final String? selectedCategoryId;
  final ValueChanged<String?> onChanged;

  const _CategorizeItemCard({
    required this.item,
    required this.categories,
    required this.selectedCategoryId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.text, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: selectedCategoryId,
              decoration: const InputDecoration(
                labelText: 'Categoría',
                border: OutlineInputBorder(),
              ),
              items: [
                for (final category in categories)
                  DropdownMenuItem(
                    value: category.id,
                    child: Text(category.label),
                  ),
              ],
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}
