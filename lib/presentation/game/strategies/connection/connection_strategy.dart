import 'package:algoquest/domain/entities/structure_state.dart';

abstract class ConnectionStrategy {
  List<EdgeState> buildConnections(StructureState state);
}
