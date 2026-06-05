import 'package:algoquest/domain/entities/challenge_spec.dart';
import 'package:algoquest/presentation/game/strategies/interaction/link_interaction_strategy.dart';
import 'package:algoquest/presentation/game/strategies/interaction/drag_interaction_strategy.dart';
import 'package:algoquest/presentation/game/strategies/interaction/set_value_interaction_strategy.dart';

import 'interaction_strategy.dart';
import 'swap_interaction_strategy.dart';

class InteractionStrategyFactory {
  const InteractionStrategyFactory();

  InteractionStrategy create(InteractionModeType type) {
    switch (type) {
      case InteractionModeType.swap:
        return SwapInteractionStrategy();

      case InteractionModeType.drag:
        return DragInteractionStrategy();

      case InteractionModeType.setValue:
        return SetValueInteractionStrategy();
      case InteractionModeType.link:
        return LinkInteractionStrategy();
    }
  }
}
