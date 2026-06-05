import 'package:algoquest/domain/entities/challenge_spec.dart';
import 'package:algoquest/presentation/game/strategies/connection/connection_strategy.dart';
import 'package:algoquest/presentation/game/strategies/connection/explicit_connection_strategy.dart';
import 'package:algoquest/presentation/game/strategies/connection/implicit_connection_strategy.dart';
import 'package:algoquest/presentation/game/strategies/connection/no_connection_strategy.dart';

class ConnectionStrategyFactory {
  const ConnectionStrategyFactory();

  ConnectionStrategy create(ConnectionType type) {
    switch (type) {
      case ConnectionType.explicit:
        return const ExplicitConnectionStrategy();
      case ConnectionType.implicit:
        return const ImplicitConnectionStrategy();
      case ConnectionType.none:
        return const NoConnectionStrategy();
    }
  }
}
