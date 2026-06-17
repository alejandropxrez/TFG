import 'package:algoquest/domain/entities/challenge_spec.dart';
import 'package:algoquest/domain/entities/quiz_spec.dart';
import 'package:algoquest/presentation/copy/challenge_result_copy.dart';
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

  group('ChallengeResultDialogCopy', () {
    test('builds success copy from challenge spec and theory message', () {
      final spec = buildSpec();

      final copy = ChallengeResultDialogCopy.fromChallengeSpec(
        spec: spec,
        solved: true,
        theoryMessage:
            'O(1) representa tiempo constante y O(n) representa tiempo lineal.',
      );

      expect(copy.title, ChallengeResultCopy.successTitle);
      expect(copy.subtitle, 'Clasifica la complejidad');
      expect(copy.message, 'Asigna cada operación a su complejidad temporal');
      expect(copy.helperTitle, ChallengeResultCopy.theoryTipTitle);
      expect(
        copy.helperMessage,
        'O(1) representa tiempo constante y O(n) representa tiempo lineal.',
      );
      expect(copy.primaryActionLabel, ChallengeResultCopy.continueLabel);
      expect(copy.secondaryActionLabel, isNull);
      expect(copy.heartsLabel, ChallengeResultCopy.heartsLeftLabel);
    });

    test('builds failure copy from challenge spec and theory message', () {
      final spec = buildSpec();

      final copy = ChallengeResultDialogCopy.fromChallengeSpec(
        spec: spec,
        solved: false,
        theoryMessage:
            'Revisa qué operaciones recorren la colección y cuáles acceden directamente.',
      );

      expect(copy.title, ChallengeResultCopy.failureTitle);
      expect(copy.subtitle, 'Clasifica la complejidad');
      expect(copy.message, 'Asigna cada operación a su complejidad temporal');
      expect(copy.helperTitle, ChallengeResultCopy.hintTitle);
      expect(
        copy.helperMessage,
        'Revisa qué operaciones recorren la colección y cuáles acceden directamente.',
      );
      expect(copy.primaryActionLabel, ChallengeResultCopy.tryAgainLabel);
      expect(copy.secondaryActionLabel, ChallengeResultCopy.showAnswerLabel);
      expect(copy.heartsLabel, ChallengeResultCopy.heartsLeftLabel);
    });

    test('uses fallback theory message when theory message is missing', () {
      final spec = buildSpec(theoryRef: null);

      final copy = ChallengeResultDialogCopy.fromChallengeSpec(
        spec: spec,
        solved: false,
        theoryMessage: null,
      );

      expect(copy.helperMessage, ChallengeResultCopy.fallbackTheoryMessage);
    });
  });
}
