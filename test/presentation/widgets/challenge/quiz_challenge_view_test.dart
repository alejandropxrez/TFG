import 'package:algoquest/domain/entities/quiz_spec.dart';
import 'package:algoquest/presentation/widgets/challenge/quiz_challenge_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('QuizChallengeView', () {
    testWidgets('renders quiz options with letter badges', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuizChallengeView(
              quizSpec: _singleChoiceQuiz(),
              selectedOptionIds: const {},
              onSelectOption: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('A'), findsOneWidget);
      expect(find.text('B'), findsOneWidget);
      expect(find.text('C'), findsOneWidget);

      expect(find.text('Binary Search Tree'), findsOneWidget);
      expect(find.text('Linked List'), findsOneWidget);
      expect(find.text('Max Heap'), findsOneWidget);
    });

    testWidgets('calls onSelectOption when an option is tapped', (
      tester,
    ) async {
      String? selectedOptionId;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuizChallengeView(
              quizSpec: _singleChoiceQuiz(),
              selectedOptionIds: const {},
              onSelectOption: (optionId) {
                selectedOptionId = optionId;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Max Heap'));
      await tester.pump();

      expect(selectedOptionId, 'max_heap');
    });

    testWidgets('shows selected state for selected option', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuizChallengeView(
              quizSpec: _singleChoiceQuiz(),
              selectedOptionIds: const {'max_heap'},
              onSelectOption: (_) {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
      expect(find.text('Max Heap'), findsOneWidget);
    });

    testWidgets('renders multiple selected options', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuizChallengeView(
              quizSpec: _multipleChoiceQuiz(),
              selectedOptionIds: const {'max_heap', 'binary_search_tree'},
              onSelectOption: (_) {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.check_rounded), findsNWidgets(2));
      expect(find.text('Max Heap'), findsOneWidget);
      expect(find.text('Binary Search Tree'), findsOneWidget);
    });
  });
}

QuizSpec _singleChoiceQuiz() {
  return QuizSpec(
    question:
        'Which data structure always keeps the largest element at the root?',
    options: [
      QuizOption(id: 'binary_search_tree', text: 'Binary Search Tree'),
      QuizOption(id: 'linked_list', text: 'Linked List'),
      QuizOption(id: 'max_heap', text: 'Max Heap'),
    ],
    correctOptionIds: {'max_heap'},
    allowMultiple: false,
  );
}

QuizSpec _multipleChoiceQuiz() {
  return QuizSpec(
    question: 'Select all tree-based structures.',
    options: [
      QuizOption(id: 'binary_search_tree', text: 'Binary Search Tree'),
      QuizOption(id: 'linked_list', text: 'Linked List'),
      QuizOption(id: 'max_heap', text: 'Max Heap'),
    ],
    correctOptionIds: {'binary_search_tree', 'max_heap'},
    allowMultiple: true,
  );
}
