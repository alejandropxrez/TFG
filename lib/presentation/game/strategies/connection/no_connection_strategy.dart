import 'package:algoquest/domain/entities/structure_state.dart';
import 'package:algoquest/presentation/game/strategies/connection/connection_strategy.dart';

class NoConnectionStrategy implements ConnectionStrategy {
  const NoConnectionStrategy();

  @override
  List<EdgeState> buildConnections(StructureState state) {
    return const [];
  }
}
