import 'package:algoquest/domain/entities/challenge_spec.dart';
import 'package:algoquest/domain/entities/game_action.dart';
import 'package:algoquest/domain/entities/structure_state.dart';
import 'package:algoquest/presentation/game/strategies/interaction/interaction_strategy.dart';
import 'package:algoquest/presentation/game/strategies/interaction/interaction_strategy_factory.dart';
import 'package:algoquest/presentation/game/visual_scene_builder.dart';
import 'package:flame/game.dart';

class AlgoQuestGame extends FlameGame {
  final VisualSceneBuilder _sceneBuilder;
  final InteractionStrategyFactory _interactionStrategyFactory;

  ChallengeSpec? _spec;
  StructureState? _state;
  InteractionStrategy? _interactionStrategy;

  void Function(GameAction action)? onActionRequested;

  AlgoQuestGame({
    VisualSceneBuilder sceneBuilder = const VisualSceneBuilder(),
    InteractionStrategyFactory interactionStrategyFactory =
        const InteractionStrategyFactory(),
  }) : _sceneBuilder = sceneBuilder,
       _interactionStrategyFactory = interactionStrategyFactory;

  void updateScene({
    required ChallengeSpec spec,
    required StructureState state,
  }) {
    final shouldResetInteraction =
        _spec?.engineConfig.interactionMode !=
        spec.engineConfig.interactionMode;

    _spec = spec;
    _state = state;

    if (_interactionStrategy == null || shouldResetInteraction) {
      _interactionStrategy = _interactionStrategyFactory.create(
        spec.engineConfig.interactionMode,
      );
    }

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
    final action = _interactionStrategy?.handleNodeTap(nodeId);

    if (action != null) {
      onActionRequested?.call(action);
    }

    _rebuildScene();
  }

  void _rebuildScene() {
    if (_spec == null || _state == null) return;
    if (size.x == 0 || size.y == 0) return;

    removeAll(children.toList());

    final scene = _sceneBuilder.build(
      spec: _spec!,
      state: _state!,
      canvasSize: size,
      selectedNodeId: _interactionStrategy?.selectedNodeId,
      onTapNode: _handleNodeTap,
    );

    addAll(scene.components);
  }

  void clearScene() {
    _spec = null;
    _state = null;
    _interactionStrategy = null;
    removeAll(children.toList());
  }
}
