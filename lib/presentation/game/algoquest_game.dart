import 'package:flame/game.dart';
import 'package:flutter/cupertino.dart';

import 'package:algoquest/domain/entities/challenge_spec.dart';
import 'package:algoquest/domain/entities/structure_state.dart';
import 'visual_scene_builder.dart';

class AlgoQuestGame extends FlameGame {
  final VisualSceneBuilder _sceneBuilder;

  ChallengeSpec? _spec;
  StructureState? _state;

  String? _selectedNodeId;

  void Function(String firstNodeId, String secondNodeId)? onSwapRequested;

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

  void _handleNodeTap(String nodeId) {
    debugPrint('Game received tap: $nodeId');

    if (_selectedNodeId == null) {
      _selectedNodeId = nodeId;
      debugPrint('Selected first node: $nodeId');
      _rebuildScene();
      return;
    }

    if (_selectedNodeId == nodeId) {
      debugPrint('Deselected node: $nodeId');
      _selectedNodeId = null;
      _rebuildScene();
      return;
    }

    final first = _selectedNodeId!;
    final second = nodeId;

    debugPrint('Requesting swap: $first <-> $second');

    _selectedNodeId = null;
    onSwapRequested?.call(first, second);
  }

  void _rebuildScene() {
    if (_spec == null || _state == null) return;
    if (size.x == 0 || size.y == 0) return;

    removeAll(children.toList());

    final scene = _sceneBuilder.build(
      spec: _spec!,
      state: _state!,
      canvasSize: size,
      selectedNodeId: _selectedNodeId,
      onTapNode: _handleNodeTap,
    );

    addAll(scene.components);
  }
}
