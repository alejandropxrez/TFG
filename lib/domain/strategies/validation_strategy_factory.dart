import 'package:algoquest/domain/strategies/bst_validation_strategy.dart';

import 'package:algoquest/domain/entities/challenge_spec.dart';

import 'validation_strategy.dart';
import 'max_heap_validation_strategy.dart';
import 'min_heap_validation_strategy.dart';

class ValidationStrategyFactory {
  const ValidationStrategyFactory();

  ValidationStrategy create(ValidationStrategyType type) {
    switch (type) {
      case ValidationStrategyType.maxHeap:
        return MaxHeapValidationStrategy();
      case ValidationStrategyType.minHeap:
        return MinHeapValidationStrategy();
      case ValidationStrategyType.bst:
        return BstValidationStrategy();
    }
  }
}
