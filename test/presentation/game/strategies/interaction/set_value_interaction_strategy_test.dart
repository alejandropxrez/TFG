import 'package:algoquest/domain/entities/game_action.dart';
import 'package:algoquest/presentation/game/strategies/interaction/set_value_interaction_strategy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('selects inventory value without creating an action', () {
    final strategy = SetValueInteractionStrategy();

    final action = strategy.handleInventoryTap(42);

    expect(action, isNull);
    expect(strategy.selectedInventoryValue, 42);
  });

  test('toggles selected inventory value when tapped again', () {
    final strategy = SetValueInteractionStrategy();

    strategy.handleInventoryTap(42);
    final action = strategy.handleInventoryTap(42);

    expect(action, isNull);
    expect(strategy.selectedInventoryValue, isNull);
  });

  test(
    'creates SetValueAction after selecting value and tapping node slot',
    () {
      final strategy = SetValueInteractionStrategy();

      strategy.handleInventoryTap(42);
      final action = strategy.handleNodeTap('s1');

      expect(action, isA<SetValueAction>());

      final setValueAction = action as SetValueAction;

      expect(setValueAction.slotId, 's1');
      expect(setValueAction.value, 42);
      expect(strategy.selectedInventoryValue, isNull);
      expect(strategy.selectedNodeIds, isEmpty);
    },
  );

  test('does not create action when slot is tapped before inventory value', () {
    final strategy = SetValueInteractionStrategy();

    final action = strategy.handleNodeTap('s1');

    expect(action, isNull);
    expect(strategy.selectedNodeIds, contains('s1'));
  });
}
