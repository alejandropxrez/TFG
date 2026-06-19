import 'package:algoquest/domain/entities/quiz_spec.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('QuizSpec', () {
    test('creates a valid single-choice quiz', () {
      final quiz = QuizSpec(
        question: 'Which option is correct?',
        options: const [
          QuizOption(id: 'a', text: 'Option A'),
          QuizOption(id: 'b', text: 'Option B'),
        ],
        correctOptionIds: const {'a'},
      );

      expect(quiz.isSingleChoice, isTrue);
      expect(quiz.correctOptionIds, {'a'});
    });

    test('creates a valid multiple-choice quiz', () {
      final quiz = QuizSpec(
        question: 'Which options are correct?',
        options: const [
          QuizOption(id: 'a', text: 'Option A'),
          QuizOption(id: 'b', text: 'Option B'),
          QuizOption(id: 'c', text: 'Option C'),
        ],
        correctOptionIds: const {'a', 'b'},
        allowMultiple: true,
      );

      expect(quiz.allowMultiple, isTrue);
      expect(quiz.correctOptionIds, {'a', 'b'});
    });

    test('rejects fewer than two options', () {
      expect(
        () => QuizSpec(
          question: 'Question',
          options: const [QuizOption(id: 'a', text: 'Option A')],
          correctOptionIds: const {'a'},
        ),
        throwsArgumentError,
      );
    });

    test('rejects duplicate option IDs', () {
      expect(
        () => QuizSpec(
          question: 'Question',
          options: const [
            QuizOption(id: 'a', text: 'Option A'),
            QuizOption(id: 'a', text: 'Another option'),
          ],
          correctOptionIds: const {'a'},
        ),
        throwsArgumentError,
      );
    });

    test('rejects unknown correct option IDs', () {
      expect(
        () => QuizSpec(
          question: 'Question',
          options: const [
            QuizOption(id: 'a', text: 'Option A'),
            QuizOption(id: 'b', text: 'Option B'),
          ],
          correctOptionIds: const {'missing'},
        ),
        throwsArgumentError,
      );
    });

    test('rejects multiple correct answers in single-choice quiz', () {
      expect(
        () => QuizSpec(
          question: 'Question',
          options: const [
            QuizOption(id: 'a', text: 'Option A'),
            QuizOption(id: 'b', text: 'Option B'),
          ],
          correctOptionIds: const {'a', 'b'},
        ),
        throwsArgumentError,
      );
    });

    test('rejects an empty question', () {
      expect(
        () => QuizSpec(
          question: '   ',
          options: const [
            QuizOption(id: 'a', text: 'Option A'),
            QuizOption(id: 'b', text: 'Option B'),
          ],
          correctOptionIds: const {'a'},
        ),
        throwsArgumentError,
      );
    });

    test('rejects empty option IDs', () {
      expect(
        () => QuizSpec(
          question: 'Question',
          options: const [
            QuizOption(id: '', text: 'Option A'),
            QuizOption(id: 'b', text: 'Option B'),
          ],
          correctOptionIds: const {'b'},
        ),
        throwsArgumentError,
      );
    });

    test('rejects empty option text', () {
      expect(
        () => QuizSpec(
          question: 'Question',
          options: const [
            QuizOption(id: 'a', text: '   '),
            QuizOption(id: 'b', text: 'Option B'),
          ],
          correctOptionIds: const {'b'},
        ),
        throwsArgumentError,
      );
    });

    test('exposes immutable options and correct IDs', () {
      final quiz = QuizSpec(
        question: 'Question',
        options: const [
          QuizOption(id: 'a', text: 'Option A'),
          QuizOption(id: 'b', text: 'Option B'),
        ],
        correctOptionIds: const {'a'},
      );

      expect(
        () => quiz.options.add(const QuizOption(id: 'c', text: 'Option C')),
        throwsUnsupportedError,
      );

      expect(() => quiz.correctOptionIds.add('b'), throwsUnsupportedError);
    });
  });
}
