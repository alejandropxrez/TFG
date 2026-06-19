import 'package:algoquest/data/core/composition/app_composition.dart';
import 'package:algoquest/main.dart';
import 'package:algoquest/presentation/application_state/app_providers.dart';
import 'package:algoquest/presentation/application_state/level_state_provider.dart';
import 'package:algoquest/presentation/widgets/challenge/components/challenge_result_dialog.dart';
import 'package:algoquest/presentation/widgets/challenge/components/challenge_select_box.dart';
import 'package:algoquest/presentation/widgets/learning_path/learning_path_level_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('user completes the heap introduction level successfully', (
    tester,
  ) async {
    final composition = await AppComposition.build();

    final container = ProviderContainer(
      overrides: [
        useCasesProvider.overrideWithValue(composition.useCases),
        currentUserIdProvider.overrideWithValue(
          'e2e_${DateTime.now().microsecondsSinceEpoch}',
        ),
      ],
    );

    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const AlgoQuestApp(),
      ),
    );

    await _openFirstLevelAndStartPractice(tester);

    await _pumpUntilChallengeReady(
      tester,
      container,
      expectedChallengeId: 'categorize_complexity_intro',
    );

    await _solveCategorizationChallenge(tester);
    await _checkAnswer(tester);
    await _expectSuccessfulResult(tester);

    await _continueAfterSuccess(tester);

    await _pumpUntilChallengeReady(
      tester,
      container,
      expectedChallengeId: 'identify_edge',
    );

    await _tapKey(tester, const ValueKey('edge_n1->n3'));

    await _checkAnswer(tester);
    await _expectSuccessfulResult(tester);

    await _continueAfterSuccess(tester);

    await _pumpUntilChallengeReady(
      tester,
      container,
      expectedChallengeId: 'fill_missing_value_intro',
    );

    await _dragInventoryValueToSlot(tester, value: 2, slotId: 's1');

    await _dragInventoryValueToSlot(tester, value: 4, slotId: 's2');

    await _dragInventoryValueToSlot(tester, value: 6, slotId: 's3');

    await _checkAnswer(tester);
    await _expectSuccessfulResult(tester);

    await _continueAfterSuccess(tester);

    await _pumpUntilChallengeReady(
      tester,
      container,
      expectedChallengeId: 'list_order_sequence_intro',
    );

    await _dragInventoryValueToSlot(tester, value: 1, slotId: 's1');

    await _dragInventoryValueToSlot(tester, value: 2, slotId: 's2');

    await _dragInventoryValueToSlot(tester, value: 3, slotId: 's3');

    await _checkAnswer(tester);
    await _expectSuccessfulResult(tester);

    await _continueAfterSuccess(tester);

    await _pumpUntilChallengeReady(
      tester,
      container,
      expectedChallengeId: 'quiz_heap_property',
    );

    await _tapText(tester, 'Cada padre debe ser mayor o igual que sus hijos.');

    await _checkAnswer(tester);
    await _expectSuccessfulResult(tester);

    await _continueAfterSuccess(tester);

    await _pumpUntilChallengeReady(
      tester,
      container,
      expectedChallengeId: 'quiz_heap_properties_multiple',
    );

    await _tapText(tester, 'Cada padre es mayor o igual que sus hijos.');

    await _tapText(tester, 'El valor máximo está en la raíz.');

    await _checkAnswer(tester);
    await _expectSuccessfulResult(tester);

    await _continueAfterSuccess(tester);

    await _pumpUntilChallengeReady(
      tester,
      container,
      expectedChallengeId: 'identify_heap_wrong_node',
    );

    await _tapKey(tester, const ValueKey('node_n2'));

    await _checkAnswer(tester);
    await _expectSuccessfulResult(tester);

    await _continueAfterSuccess(tester);

    await _pumpUntilChallengeReady(
      tester,
      container,
      expectedChallengeId: 'heap_repair_intro',
    );

    await _tapKey(tester, const ValueKey('node_n1'));

    await _tapKey(tester, const ValueKey('node_n2'));

    await _checkAnswer(tester);
    await _expectSuccessfulResult(tester);

    await _continueAfterSuccess(tester);

    await _pumpUntilChallengeReady(
      tester,
      container,
      expectedChallengeId: 'heap_repair_swap',
    );

    await _tapKey(tester, const ValueKey('node_n1'));

    await _tapKey(tester, const ValueKey('node_n2'));

    await _checkAnswer(tester);
    await _expectSuccessfulResult(tester);

    await _continueAfterSuccess(tester);

    await _pumpUntilFound(
      tester,
      find.byType(LearningPathLevelCard),
      timeout: const Duration(seconds: 20),
    );

    await tester.fling(
      find.byType(CustomScrollView),
      const Offset(0, 1000),
      1000,
    );
    await tester.pumpAndSettle();

    expect(find.text('AlgoQuest'), findsWidgets);
    expect(find.text('No se pudo cargar el mapa'), findsNothing);
    expect(find.byType(ChallengeResultDialog), findsNothing);
    expect(tester.takeException(), isNull);
  });
}

Future<void> _openFirstLevelAndStartPractice(WidgetTester tester) async {
  await _pumpUntilFound(tester, find.byType(LearningPathLevelCard));

  expect(find.text('AlgoQuest'), findsWidgets);
  expect(find.text('No se pudo cargar el mapa'), findsNothing);

  final firstLevelCard = find.byType(LearningPathLevelCard).first;

  final firstLevelButton = find.descendant(
    of: firstLevelCard,
    matching: find.byType(FilledButton),
  );

  expect(firstLevelButton, findsOneWidget);

  await tester.ensureVisible(firstLevelButton);
  await tester.pump(const Duration(milliseconds: 200));

  expect(
    firstLevelButton.hitTestable(),
    findsOneWidget,
    reason: 'The first level button is not tappable.',
  );

  await tester.tap(firstLevelButton);
  await tester.pump(const Duration(milliseconds: 300));

  final startButton = find.widgetWithText(FilledButton, '¡Vamos allá!');

  await _pumpUntilFound(
    tester,
    startButton,
    timeout: const Duration(seconds: 20),
  );

  expect(find.text('Ideas clave'), findsOneWidget);
  expect(find.text('¡Tú puedes!'), findsOneWidget);

  await tester.ensureVisible(startButton);
  await tester.pump(const Duration(milliseconds: 200));

  expect(
    startButton.hitTestable(),
    findsOneWidget,
    reason: 'The start practice button is not tappable.',
  );

  await tester.tap(startButton);
  await tester.pump(const Duration(milliseconds: 100));
}

Future<void> _solveCategorizationChallenge(WidgetTester tester) async {
  final firstCategoryItem = find.byKey(
    const ValueKey('categorize_item_array_access'),
  );

  await _pumpUntilFound(
    tester,
    firstCategoryItem,
    timeout: const Duration(seconds: 10),
  );

  expect(
    find.text('Asigna cada operación a su complejidad temporal'),
    findsOneWidget,
  );

  await _selectCategory(tester, itemId: 'array_access', categoryLabel: 'O(1)');

  await _selectCategory(tester, itemId: 'stack_push', categoryLabel: 'O(1)');

  await _selectCategory(tester, itemId: 'linear_search', categoryLabel: 'O(n)');

  await _selectCategory(
    tester,
    itemId: 'print_all_items',
    categoryLabel: 'O(n)',
  );
}

Future<void> _pumpUntilChallengeReady(
  WidgetTester tester,
  ProviderContainer container, {
  required String expectedChallengeId,
  Duration timeout = const Duration(seconds: 20),
}) async {
  final deadline = DateTime.now().add(timeout);

  while (DateTime.now().isBefore(deadline)) {
    final state = container.read(levelStateProvider);

    if (state.errorMessage != null) {
      fail('Challenge loading failed: ${state.errorMessage}');
    }

    final spec = state.currentChallengeSpec;
    final session = state.currentSession;

    if (spec != null && session != null) {
      expect(
        spec.id,
        expectedChallengeId,
        reason: 'An unexpected challenge was loaded.',
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      return;
    }

    await tester.pump(const Duration(milliseconds: 100));
  }

  final state = container.read(levelStateProvider);

  fail(
    'The challenge did not load before timeout. '
    'Current challenge: ${state.currentChallengeId}. '
    'Error: ${state.errorMessage}.',
  );
}

Future<void> _selectCategory(
  WidgetTester tester, {
  required String itemId,
  required String categoryLabel,
}) async {
  final itemCard = find.byKey(ValueKey('categorize_item_$itemId'));

  await _pumpUntilFound(tester, itemCard);

  await tester.ensureVisible(itemCard);
  await tester.pump(const Duration(milliseconds: 200));

  expect(
    itemCard.hitTestable(),
    findsOneWidget,
    reason: 'The category item "$itemId" is not visible.',
  );

  final selectBox = find.descendant(
    of: itemCard,
    matching: find.byType(ChallengeSelectBox),
  );

  expect(
    selectBox,
    findsOneWidget,
    reason: 'No category selector was found for item "$itemId".',
  );

  expect(
    selectBox.hitTestable(),
    findsOneWidget,
    reason: 'The category selector for "$itemId" is not tappable.',
  );

  await tester.tap(selectBox);
  await tester.pump(const Duration(milliseconds: 200));

  final option = find.text(categoryLabel);

  await _pumpUntilFound(tester, option);

  final overlayOption = option.last;

  expect(
    overlayOption.hitTestable(),
    findsOneWidget,
    reason: 'The category option "$categoryLabel" is not tappable.',
  );

  await tester.tap(overlayOption);
  await tester.pump(const Duration(milliseconds: 200));
}

Future<void> _tapKey(WidgetTester tester, Key key) async {
  final finder = find.byKey(key);

  await _pumpUntilFound(tester, finder, timeout: const Duration(seconds: 10));

  await tester.ensureVisible(finder);
  await tester.pump(const Duration(milliseconds: 200));

  final tappableFinder = finder.hitTestable();

  expect(
    tappableFinder,
    findsOneWidget,
    reason: 'The widget with key "$key" is not tappable.',
  );

  await tester.tap(tappableFinder);
  await tester.pump(const Duration(milliseconds: 200));
}

Future<void> _checkAnswer(WidgetTester tester) async {
  final checkButton = find.text('Comprobar Respuesta');

  await _pumpUntilFound(tester, checkButton);

  await tester.ensureVisible(checkButton);
  await tester.pump(const Duration(milliseconds: 200));

  expect(
    checkButton.hitTestable(),
    findsOneWidget,
    reason: 'The check answer button is not tappable.',
  );

  await tester.tap(checkButton);
  await tester.pump(const Duration(milliseconds: 300));
}

Future<void> _expectSuccessfulResult(WidgetTester tester) async {
  final dialogFinder = find.byType(ChallengeResultDialog);

  await _pumpUntilFound(
    tester,
    dialogFinder,
    timeout: const Duration(seconds: 10),
  );

  expect(dialogFinder, findsOneWidget);

  final dialog = tester.widget<ChallengeResultDialog>(dialogFinder);

  expect(
    dialog.type,
    ChallengeResultDialogType.success,
    reason: 'The challenge result was expected to be successful.',
  );
}

Future<void> _continueAfterSuccess(WidgetTester tester) async {
  final dialogFinder = find.byType(ChallengeResultDialog);

  await _pumpUntilFound(tester, dialogFinder);

  final dialog = tester.widget<ChallengeResultDialog>(dialogFinder);

  expect(
    dialog.type,
    ChallengeResultDialogType.success,
    reason: 'The challenge result was expected to be successful.',
  );

  final continueButton = find.text(dialog.primaryActionLabel);

  await _pumpUntilFound(tester, continueButton);

  await tester.ensureVisible(continueButton);
  await tester.pump(const Duration(milliseconds: 200));

  expect(
    continueButton.hitTestable(),
    findsOneWidget,
    reason: 'The continue button is not tappable.',
  );

  await tester.tap(continueButton);
  await tester.pump(const Duration(milliseconds: 300));
}

Future<void> _pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 10),
}) async {
  final deadline = DateTime.now().add(timeout);

  while (finder.evaluate().isEmpty && DateTime.now().isBefore(deadline)) {
    await tester.pump(const Duration(milliseconds: 100));
  }

  expect(
    finder,
    findsWidgets,
    reason: 'The expected widget did not appear before the timeout: $finder',
  );
}

Future<void> _dragInventoryValueToSlot(
  WidgetTester tester, {
  required int value,
  required String slotId,
}) async {
  final source = find.byKey(ValueKey('inventory_$value'));

  final target = find.byKey(ValueKey('slot_$slotId'));

  await _pumpUntilFound(
    tester,
    source,
    timeout: const Duration(seconds: 10),
  );

  await _pumpUntilFound(
    tester,
    target,
    timeout: const Duration(seconds: 10),
  );

  await tester.ensureVisible(source);
  await tester.pump(const Duration(milliseconds: 200));

  await tester.ensureVisible(target);
  await tester.pump(const Duration(milliseconds: 200));

  expect(
    source.hitTestable(),
    findsOneWidget,
    reason: 'Inventory value "$value" is not draggable.',
  );

  expect(
    target.hitTestable(),
    findsOneWidget,
    reason: 'Slot "$slotId" is not visible.',
  );

  await tester.timedDragFrom(
    tester.getCenter(source),
    tester.getCenter(target) - tester.getCenter(source),
    const Duration(milliseconds: 500),
  );

  await tester.pump(const Duration(milliseconds: 300));

  expect(
    find.descendant(of: target, matching: find.text(value.toString())),
    findsOneWidget,
    reason: 'Value "$value" was not placed in slot "$slotId".',
  );
}

Future<void> _tapText(WidgetTester tester, String text) async {
  final finder = find.text(text);

  await _pumpUntilFound(
    tester,
    finder,
    timeout: const Duration(seconds: 10),
  );

  await tester.ensureVisible(finder.first);
  await tester.pump(const Duration(milliseconds: 200));

  expect(
    finder.first.hitTestable(),
    findsOneWidget,
    reason: 'The widget with text "$text" is not tappable.',
  );

  await tester.tap(finder.first);
  await tester.pump(const Duration(milliseconds: 200));
}
