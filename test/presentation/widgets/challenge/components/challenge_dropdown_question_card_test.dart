import 'package:algoquest/presentation/widgets/challenge/components/challenge_dropdown_question_card.dart';
import 'package:algoquest/presentation/widgets/challenge/components/challenge_select_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ChallengeDropdownQuestionCard', () {
    testWidgets('renders question text and custom select box', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChallengeDropdownQuestionCard(
              questionNumber: 1,
              leadingText: 'In a max heap, the value of a parent is always',
              trailingText: '',
              selectedOptionId: null,
              options: const [
                ChallengeDropdownOption(
                  id: 'greater_or_equal',
                  label: 'greater than or equal to',
                ),
                ChallengeDropdownOption(
                  id: 'less_or_equal',
                  label: 'less than or equal to',
                ),
              ],
              onChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('1.'), findsOneWidget);
      expect(
        find.text('In a max heap, the value of a parent is always'),
        findsOneWidget,
      );
      expect(find.byType(ChallengeSelectBox), findsOneWidget);
      expect(find.byType(DropdownButtonFormField<String>), findsNothing);
    });

    testWidgets('calls onChanged when selecting an option', (tester) async {
      String? selectedOptionId;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChallengeDropdownQuestionCard(
              questionNumber: 1,
              leadingText: 'In a max heap, the value of a parent is always',
              trailingText: '',
              selectedOptionId: null,
              options: const [
                ChallengeDropdownOption(
                  id: 'greater_or_equal',
                  label: 'greater than or equal to',
                ),
                ChallengeDropdownOption(
                  id: 'less_or_equal',
                  label: 'less than or equal to',
                ),
              ],
              onChanged: (optionId) {
                selectedOptionId = optionId;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Selecciona una opción'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('greater than or equal to'));
      await tester.pumpAndSettle();

      expect(selectedOptionId, 'greater_or_equal');
    });
  });
}
