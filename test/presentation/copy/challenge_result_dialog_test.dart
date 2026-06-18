import 'package:algoquest/domain/entities/challenge_spec.dart';
import 'package:algoquest/domain/entities/quiz_spec.dart';
import 'package:algoquest/presentation/copy/challenge_result_copy.dart';
import 'package:algoquest/presentation/widgets/challenge/challenge_result_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  ChallengeSpec buildSpec({
    String title = 'Clasifica la complejidad',
    String instruction = 'Asigna cada operación a su complejidad temporal',
    String? theoryRef = 'complexity_basics',
  }) {
    return ChallengeSpec(
      id: 'categorize_complexity',
      title: title,
      instruction: instruction,
      theoryRef: theoryRef,
      constraints: const [],
      content: QuizChallengeContent(
        quizSpec: QuizSpec(
          question: 'Pregunta de prueba',
          options: const [
            QuizOption(id: 'a', text: 'O(1)'),
            QuizOption(id: 'b', text: 'O(n)'),
          ],
          correctOptionIds: const {'a'},
          allowMultiple: false,
        ),
      ),
    );
  }

  Widget buildSubject({
    required bool solved,
    int? attemptsRemaining,
    String? theoryMessage =
        'O(1) representa tiempo constante y O(n) representa tiempo lineal.',
    VoidCallback? onContinue,
    VoidCallback? onTryAgain,
    VoidCallback? onShowAnswer,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: ChallengeResultDialog.fromChallengeSpec(
            spec: buildSpec(),
            solved: solved,
            theoryMessage: theoryMessage,
            attemptsRemaining: attemptsRemaining,
            onContinue: onContinue ?? () {},
            onTryAgain: onTryAgain ?? () {},
            onShowAnswer: onShowAnswer,
          ),
        ),
      ),
    );
  }

  group('ChallengeResultDialog', () {
    testWidgets('shows success state with challenge copy', (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      addTearDown(() async {
        await tester.binding.setSurfaceSize(null);
      });

      await tester.pumpWidget(buildSubject(solved: true));

      expect(find.text(ChallengeResultCopy.successTitle), findsOneWidget);
      expect(find.text('Clasifica la complejidad'), findsOneWidget);
      expect(
        find.text('Asigna cada operación a su complejidad temporal'),
        findsOneWidget,
      );
      expect(find.text(ChallengeResultCopy.theoryTipTitle), findsOneWidget);
      expect(
        find.text(
          'O(1) representa tiempo constante y O(n) representa tiempo lineal.',
        ),
        findsOneWidget,
      );
      expect(find.text(ChallengeResultCopy.continueLabel), findsOneWidget);
      expect(find.text(ChallengeResultCopy.tryAgainLabel), findsNothing);
      expect(find.text(ChallengeResultCopy.showAnswerLabel), findsNothing);
      expect(find.text(ChallengeResultCopy.heartsLeftLabel), findsNothing);
    });

    testWidgets('shows failure state with retry, answer and hearts', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      addTearDown(() async {
        await tester.binding.setSurfaceSize(null);
      });

      await tester.pumpWidget(
        buildSubject(
          solved: false,
          attemptsRemaining: 2,
          theoryMessage:
              'Revisa qué operaciones recorren la colección y cuáles acceden directamente.',
          onShowAnswer: () {},
        ),
      );

      expect(find.text(ChallengeResultCopy.failureTitle), findsOneWidget);
      expect(find.text('Clasifica la complejidad'), findsOneWidget);
      expect(
        find.text('Asigna cada operación a su complejidad temporal'),
        findsOneWidget,
      );
      expect(find.text(ChallengeResultCopy.hintTitle), findsOneWidget);
      expect(
        find.text(
          'Revisa qué operaciones recorren la colección y cuáles acceden directamente.',
        ),
        findsOneWidget,
      );
      expect(find.text(ChallengeResultCopy.heartsLeftLabel), findsOneWidget);
      expect(find.text(ChallengeResultCopy.tryAgainLabel), findsOneWidget);
      expect(find.text(ChallengeResultCopy.showAnswerLabel), findsOneWidget);
      expect(find.text(ChallengeResultCopy.continueLabel), findsNothing);
    });

    testWidgets('calls onContinue in success state', (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      addTearDown(() async {
        await tester.binding.setSurfaceSize(null);
      });

      var called = false;

      await tester.pumpWidget(
        buildSubject(
          solved: true,
          onContinue: () {
            called = true;
          },
        ),
      );

      await tester.tap(find.text(ChallengeResultCopy.continueLabel));
      await tester.pump();

      expect(called, isTrue);
    });

    testWidgets('calls onTryAgain in failure state', (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      addTearDown(() async {
        await tester.binding.setSurfaceSize(null);
      });

      var called = false;

      await tester.pumpWidget(
        buildSubject(
          solved: false,
          attemptsRemaining: 2,
          onTryAgain: () {
            called = true;
          },
          onShowAnswer: () {},
        ),
      );

      await tester.tap(find.text(ChallengeResultCopy.tryAgainLabel));
      await tester.pump();

      expect(called, isTrue);
    });

    testWidgets('calls onShowAnswer in failure state', (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      addTearDown(() async {
        await tester.binding.setSurfaceSize(null);
      });

      var called = false;

      await tester.pumpWidget(
        buildSubject(
          solved: false,
          attemptsRemaining: 2,
          onShowAnswer: () {
            called = true;
          },
        ),
      );

      await tester.tap(find.text(ChallengeResultCopy.showAnswerLabel));
      await tester.pump();

      expect(called, isTrue);
    });

    testWidgets('uses fallback theory message when none is provided', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      addTearDown(() async {
        await tester.binding.setSurfaceSize(null);
      });

      await tester.pumpWidget(
        buildSubject(
          solved: false,
          attemptsRemaining: 2,
          theoryMessage: null,
          onShowAnswer: () {},
        ),
      );

      expect(
        find.text(ChallengeResultCopy.fallbackTheoryMessage),
        findsOneWidget,
      );
    });
  });
}
