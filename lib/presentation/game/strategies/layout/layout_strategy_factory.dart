import 'package:algoquest/domain/entities/challenge_spec.dart';
import 'package:algoquest/presentation/game/strategies/layout/circular_layout_strategy.dart';
import 'package:algoquest/presentation/game/strategies/layout/free_layout_strategy.dart';
import 'package:algoquest/presentation/game/strategies/layout/layout_strategy.dart';
import 'package:algoquest/presentation/game/strategies/layout/linear_layout_strategy.dart';
import 'package:algoquest/presentation/game/strategies/layout/pyramid_layout_strategy.dart';

class LayoutStrategyFactory {
  const LayoutStrategyFactory();

  LayoutStrategy create(LayoutStrategyType type) {
    switch (type) {
      case LayoutStrategyType.pyramid:
        return const PyramidLayoutStrategy();
      case LayoutStrategyType.linear:
        return const LinearLayoutStrategy();
      case LayoutStrategyType.circular:
        return const CircularLayoutStrategy();
      case LayoutStrategyType.free:
        return const FreeLayoutStrategy();
    }
  }
}
