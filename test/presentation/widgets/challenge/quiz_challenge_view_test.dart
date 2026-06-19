import 'dart:ui';

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

    testWidgets('shows quiz question', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 400,
              child: QuizChallengeView(
                quizSpec: _singleChoiceQuiz(),
                selectedOptionIds: const {},
                onSelectOption: (_) {},
              ),
            ),
          ),
        ),
      );

      expect(
        find.text(
          'Which data structure always keeps the largest element at the root?',
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders long option text without overflow', (tester) async {
      final quiz = QuizSpec(
        question: 'Choose the correct statement.',
        options: [
          QuizOption(
            id: 'long',
            text:
                'This is a very long option that should wrap onto multiple lines without overflowing the card.',
          ),
          QuizOption(id: 'short', text: 'Short option'),
        ],
        correctOptionIds: {'long'},
        allowMultiple: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 280,
              height: 300,
              child: QuizChallengeView(
                quizSpec: quiz,
                selectedOptionIds: const {},
                onSelectOption: (_) {},
              ),
            ),
          ),
        ),
      );

      expect(
        find.text(
          'This is a very long option that should wrap onto multiple lines without overflowing the card.',
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('exposes selected single-choice option semantics', (
      tester,
    ) async {
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

      final semantics = tester.getSemantics(
        find.bySemanticsLabel('C. Max Heap'),
      );

      expect(semantics.flagsCollection.isButton, isTrue);
      expect(semantics.flagsCollection.isSelected, Tristate.isTrue);
      expect(semantics.flagsCollection.isInMutuallyExclusiveGroup, isTrue);
      expect(semantics.hint, 'Toca para seleccionar');
    });

    testWidgets('exposes multiple-choice option semantics', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuizChallengeView(
              quizSpec: _multipleChoiceQuiz(),
              selectedOptionIds: const {'max_heap'},
              onSelectOption: (_) {},
            ),
          ),
        ),
      );

      final semantics = tester.getSemantics(
        find.bySemanticsLabel('C. Max Heap'),
      );

      expect(semantics.flagsCollection.isButton, isTrue);
      expect(semantics.flagsCollection.isSelected, Tristate.isTrue);
      expect(semantics.flagsCollection.isInMutuallyExclusiveGroup, isFalse);
      expect(semantics.hint, 'Toca para desmarcar');
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
