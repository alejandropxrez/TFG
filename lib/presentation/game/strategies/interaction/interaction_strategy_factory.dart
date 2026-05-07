import 'package:algoquest/domain/entities/challenge_spec.dart';

import 'interaction_strategy.dart';
import 'swap_interaction_strategy.dart';

class InteractionStrategyFactory {
  const InteractionStrategyFactory();

  InteractionStrategy create(InteractionModeType type) {
    switch (type) {
      case InteractionModeType.swap:
        return SwapInteractionStrategy();

      case InteractionModeType.drag:
      case InteractionModeType.setValue:
        return SwapInteractionStrategy();
    }
  }
}
