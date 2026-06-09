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
  final DropResolver _dropResolver;

  StructureChallengeContent? _lastStructureContent;
  StructureState? _state;

  InteractionStrategy? _internalInteractionStrategy;
  InteractionStrategy? _externalInteractionStrategy;

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
    required StructureChallengeContent structureContent,
    required StructureState state,
    InteractionStrategy? interactionStrategy,
  }) {
    final previousInteractionMode =
        _lastStructureContent?.engineConfig.interactionMode;

    final nextInteractionMode = structureContent.engineConfig.interactionMode;

    final shouldResetInternalStrategy =
        interactionStrategy == null &&
        (previousInteractionMode != nextInteractionMode ||
            _internalInteractionStrategy == null);

    _lastStructureContent = structureContent;
    _state = state;
    _externalInteractionStrategy = interactionStrategy;

    if (shouldResetInternalStrategy) {
      _internalInteractionStrategy = _interactionStrategyFactory.create(
        nextInteractionMode,
      );
    }

    _rebuildScene();
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    if (_lastStructureContent != null && _state != null) {
      _rebuildScene();
    }
  }

  void _rebuildScene() {
    final structureContent = _lastStructureContent;
    final state = _state;
    final interactionStrategy = _currentInteractionStrategy;

    if (structureContent == null ||
        state == null ||
        interactionStrategy == null) {
      return;
    }

    if (size.x == 0 || size.y == 0) return;

    removeAll(children.toList());

    final scene = _sceneBuilder.build(
      structureContent: structureContent,
      state: state,
      canvasSize: size,
      interactionStrategy: interactionStrategy,
      onActionRequested: _emitAction,
      onInteractionChanged: _rebuildScene,
      onInventoryDragStart: _handleInventoryDragStart,
      onInventoryDragUpdate: _handleInventoryDragUpdate,
      onInventoryDragEnd: _handleInventoryDragEnd,
    );

    _lastScene = scene;

    addAll(scene.components);
  }

  void clearScene() {
    _lastStructureContent = null;
    _state = null;
    _internalInteractionStrategy = null;
    _externalInteractionStrategy = null;
    _lastScene = null;

    removeAll(children.toList());
  }

  InteractionStrategy? get _currentInteractionStrategy {
    return _externalInteractionStrategy ?? _internalInteractionStrategy;
  }

  void _emitAction(GameAction action) {
    onActionRequested?.call(action);
  }

  void _handleInventoryDragStart(int value, Vector2 position) {
    final strategy = _currentInteractionStrategy;
    if (strategy == null) return;

    strategy.clearSelection();
    strategy.handleInventoryTap(value);
  }

  void _handleInventoryDragUpdate(int value, Vector2 position) {
    // Reserved for future hover feedback.
  }

  void _handleInventoryDragEnd(int value, Vector2 position) {
    final strategy = _currentInteractionStrategy;
    if (strategy == null) return;

    final slotId = _dropResolver.resolveSlot(
      dropPosition: position,
      slotPositions: _lastScene?.slotPositions ?? const {},
    );

    if (slotId == null) {
      strategy.clearSelection();
      return;
    }

    if (strategy.selectedInventoryValue != value) {
      strategy.handleInventoryTap(value);
    }

    final action = strategy.handleNodeTap(slotId);

    if (action != null) {
      _emitAction(action);
    }

    strategy.clearSelection();
  }
}
