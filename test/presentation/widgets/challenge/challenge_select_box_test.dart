import 'package:algoquest/presentation/widgets/challenge/challenge_select_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ChallengeSelectBox', () {
    testWidgets('shows placeholder and opens custom menu', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: ChallengeSelectBox(
                selectedOptionId: null,
                options: const [
                  ChallengeSelectOption(id: 'o1', label: 'O(1)'),
                  ChallengeSelectOption(id: 'on', label: 'O(n)'),
                ],
                onChanged: (_) {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('Select an option'), findsOneWidget);
      expect(find.text('O(1)'), findsNothing);
      expect(find.text('O(n)'), findsNothing);

      await tester.tap(find.text('Select an option'));
      await tester.pumpAndSettle();

      expect(find.text('O(1)'), findsOneWidget);
      expect(find.text('O(n)'), findsOneWidget);
    });

    testWidgets('selects an option and closes the menu', (tester) async {
      String? selectedOptionId;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: StatefulBuilder(
                builder: (context, setState) {
                  return ChallengeSelectBox(
                    selectedOptionId: selectedOptionId,
                    options: const [
                      ChallengeSelectOption(id: 'o1', label: 'O(1)'),
                      ChallengeSelectOption(id: 'on', label: 'O(n)'),
                    ],
                    onChanged: (optionId) {
                      setState(() {
                        selectedOptionId = optionId;
                      });
                    },
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Select an option'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('O(n)'));
      await tester.pumpAndSettle();

      expect(selectedOptionId, 'on');
      expect(find.text('O(n)'), findsOneWidget);
      expect(find.text('O(1)'), findsNothing);
    });

    testWidgets('does not open menu when options are empty', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: ChallengeSelectBox(
                selectedOptionId: null,
                options: const [],
                onChanged: (_) {},
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Select an option'));
      await tester.pumpAndSettle();

      expect(find.text('Select an option'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
