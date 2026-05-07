import '../../../../domain/entities/challenge_spec.dart';
import 'layout_strategy.dart';
import 'linear_layout_strategy.dart';
import 'pyramid_layout_strategy.dart';

class LayoutStrategyFactory {
  const LayoutStrategyFactory();

  LayoutStrategy create(LayoutStrategyType type) {
    switch (type) {
      case LayoutStrategyType.pyramid:
        return const PyramidLayoutStrategy();
      case LayoutStrategyType.linear:
        return const LinearLayoutStrategy();
    }
  }
}
