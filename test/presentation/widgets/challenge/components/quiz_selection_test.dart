import 'package:algoquest/presentation/widgets/challenge/challenge_body_factory.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('nextQuizSelection', () {
    test('replaces selection for single-choice quiz', () {
      final result = nextQuizSelection(
        optionId: 'max_heap',
        selectedOptionIds: const {'binary_search_tree'},
        allowMultiple: false,
      );

      expect(result, {'max_heap'});
    });

    test('adds option for multiple-choice quiz', () {
      final result = nextQuizSelection(
        optionId: 'max_heap',
        selectedOptionIds: const {'binary_search_tree'},
        allowMultiple: true,
      );

      expect(result, {'binary_search_tree', 'max_heap'});
    });

    test('removes selected option for multiple-choice quiz', () {
      final result = nextQuizSelection(
        optionId: 'max_heap',
        selectedOptionIds: const {'binary_search_tree', 'max_heap'},
        allowMultiple: true,
      );

      expect(result, {'binary_search_tree'});
    });
  });
}
