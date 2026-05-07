import 'package:flame/game.dart';

import '../../domain/entities/challenge_spec.dart';
import '../../domain/entities/structure_state.dart';
import 'visual_scene_builder.dart';

class AlgoQuestGame extends FlameGame {
  final VisualSceneBuilder _sceneBuilder;

  ChallengeSpec? _spec;
  StructureState? _state;

  AlgoQuestGame({VisualSceneBuilder sceneBuilder = const VisualSceneBuilder()})
    : _sceneBuilder = sceneBuilder;

  void updateScene({
    required ChallengeSpec spec,
    required StructureState state,
  }) {
    _spec = spec;
    _state = state;

    _rebuildScene();
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    if (_spec != null && _state != null) {
      _rebuildScene();
    }
  }

  void _rebuildScene() {
    if (_spec == null || _state == null) return;
    if (size.x == 0 || size.y == 0) return;

    removeAll(children.toList());

    final scene = _sceneBuilder.build(
      spec: _spec!,
      state: _state!,
      canvasSize: size,
    );

    addAll(scene.components);
  }
}
