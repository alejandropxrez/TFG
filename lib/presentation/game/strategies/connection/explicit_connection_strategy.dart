import 'package:algoquest/domain/entities/structure_state.dart';
import 'package:algoquest/presentation/game/strategies/connection/connection_strategy.dart';

class ExplicitConnectionStrategy implements ConnectionStrategy {
  const ExplicitConnectionStrategy();

  @override
  List<EdgeState> buildConnections(StructureState state) {
    return state.edges;
  }
}
