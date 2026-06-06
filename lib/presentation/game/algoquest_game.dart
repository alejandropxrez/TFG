import 'package:algoquest/domain/entities/challenge_spec.dart';
import 'package:algoquest/domain/entities/game_action.dart';
import 'package:algoquest/domain/entities/structure_state.dart';
import 'package:algoquest/presentation/game/interaction/drop_resolver.dart';
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

  final DropResolver _dropResolver;
  VisualScene? _lastScene;

  void Function(GameAction action)? onActionRequested;

  AlgoQuestGame({
    VisualSceneBuilder sceneBuilder = const VisualSceneBuilder(),
    InteractionStrategyFactory interactionStrategyFactory =
        const InteractionStrategyFactory(),
    DropResolver dropResolver = const DropResolver(),
  }) : _sceneBuilder = sceneBuilder,
       _interactionStrategyFactory = interactionStrategyFactory,
       _dropResolver = dropResolver;

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

  void _rebuildScene() {
    final spec = _spec;
    final state = _state;
    final interactionStrategy = _interactionStrategy;

    if (spec == null || state == null || interactionStrategy == null) return;
    if (size.x == 0 || size.y == 0) return;

    removeAll(children.toList());

    final scene = _sceneBuilder.build(
      spec: spec,
      state: state,
      canvasSize: size,
      interactionStrategy: interactionStrategy,
      onActionRequested: (action) {
        onActionRequested?.call(action);
      },
      onInteractionChanged: _rebuildScene,
      onInventoryDragStart: _handleInventoryDragStart,
      onInventoryDragUpdate: _handleInventoryDragUpdate,
      onInventoryDragEnd: _handleInventoryDragEnd,
    );

    _lastScene = scene;

    addAll(scene.components);
  }

  void clearScene() {
    _spec = null;
    _state = null;
    _interactionStrategy = null;
    removeAll(children.toList());
  }

  void _handleInventoryDragStart(int value, Vector2 position) {
    _interactionStrategy?.handleInventoryTap(value);
  }

  void _handleInventoryDragUpdate(int value, Vector2 position) {
    // Reserved for future hover feedback.
  }

  void _handleInventoryDragEnd(int value, Vector2 position) {
    final slotId = _dropResolver.resolveSlot(
      dropPosition: position,
      slotPositions: _lastScene?.slotPositions ?? const {},
    );

    if (slotId != null) {
      if (_interactionStrategy?.selectedInventoryValue != value) {
        _interactionStrategy?.handleInventoryTap(value);
      }

      final action = _interactionStrategy?.handleNodeTap(slotId);

      if (action != null) {
        onActionRequested?.call(action);
      }
    }
  }
}
