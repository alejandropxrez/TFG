import 'package:algoquest/domain/entities/categorize_spec.dart';
import 'package:algoquest/presentation/widgets/challenge/categorize_challenge_body.dart';
import 'package:algoquest/presentation/widgets/challenge/components/challenge_select_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CategorizeChallengeBody', () {
    testWidgets('renders items and custom select boxes', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 500,
              child: CategorizeChallengeBody(
                categorizeSpec: _categorizeSpec(),
                selectedCategoryByItemId: const {},
                onCategorySelected:
                    ({required String itemId, required String categoryId}) {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('Acceder a un array por índice'), findsOneWidget);
      expect(find.text('Insertar un elemento en una pila'), findsOneWidget);
      expect(find.byType(ChallengeSelectBox), findsNWidgets(4));
    });

    testWidgets('calls onCategorySelected when choosing a category', (
      tester,
    ) async {
      String? selectedItemId;
      String? selectedCategoryId;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 500,
              child: CategorizeChallengeBody(
                categorizeSpec: _categorizeSpec(),
                selectedCategoryByItemId: const {},
                onCategorySelected:
                    ({required String itemId, required String categoryId}) {
                      selectedItemId = itemId;
                      selectedCategoryId = categoryId;
                    },
              ),
            ),
          ),
        ),
      );

      final firstSelectPlaceholder = find
          .text('Selecciona una categoría')
          .first;

      expect(firstSelectPlaceholder, findsOneWidget);

      await tester.tap(firstSelectPlaceholder);
      await tester.pumpAndSettle();

      final option = find.text('O(1)').last;

      expect(option, findsOneWidget);

      await tester.tap(option);
      await tester.pumpAndSettle();

      expect(selectedItemId, 'array_access');
      expect(selectedCategoryId, 'o1');
    });

    testWidgets(
      'list scrolls inside the challenge body when content overflows',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                height: 220,
                child: CategorizeChallengeBody(
                  categorizeSpec: _categorizeSpec(),
                  selectedCategoryByItemId: const {},
                  onCategorySelected:
                      ({required String itemId, required String categoryId}) {},
                ),
              ),
            ),
          ),
        );

        expect(find.text('Acceder a un array por índice'), findsOneWidget);

        await tester.drag(find.byType(ListView), const Offset(0, -260));
        await tester.pumpAndSettle();

        expect(
          find.text('Recorrer e imprimir todos los elementos'),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      },
    );
  });
}

CategorizeSpec _categorizeSpec() {
  return const CategorizeSpec(
    prompt: 'Clasifica cada operación según su complejidad temporal.',
    categories: [
      CategorizeCategory(id: 'o1', label: 'O(1)'),
      CategorizeCategory(id: 'on', label: 'O(n)'),
    ],
    items: [
      CategorizeItem(id: 'array_access', text: 'Acceder a un array por índice'),
      CategorizeItem(
        id: 'stack_push',
        text: 'Insertar un elemento en una pila',
      ),
      CategorizeItem(
        id: 'linear_search',
        text: 'Buscar secuencialmente en una lista',
      ),
      CategorizeItem(
        id: 'print_all_items',
        text: 'Recorrer e imprimir todos los elementos',
      ),
    ],
    correctCategoryByItemId: {
      'array_access': 'o1',
      'stack_push': 'o1',
      'linear_search': 'on',
      'print_all_items': 'on',
    },
  );
}
