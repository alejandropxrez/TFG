import 'package:flutter_test/flutter_test.dart';

import 'package:algoquest/domain/entities/challenge_spec.dart';
import 'package:algoquest/domain/strategies/bst_validation_strategy.dart';
import 'package:algoquest/domain/strategies/max_heap_validation_strategy.dart';
import 'package:algoquest/domain/strategies/min_heap_validation_strategy.dart';
import 'package:algoquest/domain/strategies/validation_strategy_factory.dart';

void main() {
  const factory = ValidationStrategyFactory();

  test('creates MaxHeapValidationStrategy for ValidationType.maxHeap', () {
    final strategy = factory.create(ValidationStrategyType.maxHeap);
    expect(strategy, isA<MaxHeapValidationStrategy>());
  });

  test('creates MinHeapValidationStrategy for ValidationType.minHeap', () {
    final strategy = factory.create(ValidationStrategyType.minHeap);
    expect(strategy, isA<MinHeapValidationStrategy>());
  });

  test('creates BstValidationStrategy for ValidationType.bst', () {
    final strategy = factory.create(ValidationStrategyType.bst);
    expect(strategy, isA<BstValidationStrategy>());
  });
}
