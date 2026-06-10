class CategorizeSpec {
  final String prompt;
  final List<CategorizeCategory> categories;
  final List<CategorizeItem> items;
  final Map<String, String> correctCategoryByItemId;

  const CategorizeSpec({
    required this.prompt,
    required this.categories,
    required this.items,
    required this.correctCategoryByItemId,
  });
}

class CategorizeCategory {
  final String id;
  final String label;

  const CategorizeCategory({required this.id, required this.label});
}

class CategorizeItem {
  final String id;
  final String text;

  const CategorizeItem({required this.id, required this.text});
}
