import 'package:algoquest/domain/entities/challenge_spec.dart';
import 'package:algoquest/presentation/game/strategies/layout/circular_layout_strategy.dart';
import 'package:algoquest/presentation/game/strategies/layout/free_layout_strategy.dart';
import 'package:algoquest/presentation/game/strategies/layout/layout_strategy.dart';
import 'package:algoquest/presentation/game/strategies/layout/linear_layout_strategy.dart';
import 'package:algoquest/presentation/game/strategies/layout/pyramid_layout_strategy.dart';

class LayoutStrategyFactory {
  const LayoutStrategyFactory();

  LayoutStrategy create(LayoutStrategyType type) {
    return switch (type) {
      LayoutStrategyType.pyramid => const PyramidLayoutStrategy(),
      LayoutStrategyType.linear => const LinearLayoutStrategy(),
      LayoutStrategyType.circular => const CircularLayoutStrategy(),
      LayoutStrategyType.free => const FreeLayoutStrategy(),
    };
  }
}
