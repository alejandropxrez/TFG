import 'package:algoquest/domain/entities/structure_state.dart';
import 'package:algoquest/presentation/game/strategies/connection/connection_strategy.dart';

class ImplicitConnectionStrategy implements ConnectionStrategy {
  const ImplicitConnectionStrategy();

  @override
  List<EdgeState> buildConnections(StructureState state) {
    // Temporary implementation.
    // Later this can generate edges from structural rules instead of state.edges.
    return state.edges;
  }
}
