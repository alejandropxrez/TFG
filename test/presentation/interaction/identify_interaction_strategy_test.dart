import 'package:algoquest/presentation/game/strategies/interaction/identify_interaction_strategy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('IdentifyInteractionStrategy', () {
    test('selects node id when node is tapped in single selection mode', () {
      Set<String>? selectedTargetIds;

      final strategy = IdentifyInteractionStrategy(
        selectedTargetIds: const {},
        allowMultiple: false,
        onSelectionChanged: (nextSelection) {
          selectedTargetIds = nextSelection;
        },
      );

      final action = strategy.handleNodeTap('n2');

      expect(action, isNull);
      expect(selectedTargetIds, {'n2'});
    });

    test(
      'replaces selected node when another node is tapped in single selection mode',
      () {
        Set<String>? selectedTargetIds;

        final strategy = IdentifyInteractionStrategy(
          selectedTargetIds: const {'n1'},
          allowMultiple: false,
          onSelectionChanged: (nextSelection) {
            selectedTargetIds = nextSelection;
          },
        );

        final action = strategy.handleNodeTap('n2');

        expect(action, isNull);
        expect(selectedTargetIds, {'n2'});
      },
    );

    test('adds node id when node is tapped in multiple selection mode', () {
      Set<String>? selectedTargetIds;

      final strategy = IdentifyInteractionStrategy(
        selectedTargetIds: const {'n1'},
        allowMultiple: true,
        onSelectionChanged: (nextSelection) {
          selectedTargetIds = nextSelection;
        },
      );

      final action = strategy.handleNodeTap('n2');

      expect(action, isNull);
      expect(selectedTargetIds, {'n1', 'n2'});
    });

    test(
      'removes node id when selected node is tapped in multiple selection mode',
      () {
        Set<String>? selectedTargetIds;

        final strategy = IdentifyInteractionStrategy(
          selectedTargetIds: const {'n1', 'n2'},
          allowMultiple: true,
          onSelectionChanged: (nextSelection) {
            selectedTargetIds = nextSelection;
          },
        );

        final action = strategy.handleNodeTap('n2');

        expect(action, isNull);
        expect(selectedTargetIds, {'n1'});
      },
    );

    test('selects edge id when edge is tapped in single selection mode', () {
      Set<String>? selectedTargetIds;

      final strategy = IdentifyInteractionStrategy(
        selectedTargetIds: const {},
        allowMultiple: false,
        onSelectionChanged: (nextSelection) {
          selectedTargetIds = nextSelection;
        },
      );

      final action = strategy.handleEdgeTap('n1', 'n3');

      expect(action, isNull);
      expect(selectedTargetIds, {'n1->n3'});
    });

    test(
      'replaces selected edge when another edge is tapped in single selection mode',
      () {
        Set<String>? selectedTargetIds;

        final strategy = IdentifyInteractionStrategy(
          selectedTargetIds: const {'n1->n2'},
          allowMultiple: false,
          onSelectionChanged: (nextSelection) {
            selectedTargetIds = nextSelection;
          },
        );

        final action = strategy.handleEdgeTap('n1', 'n3');

        expect(action, isNull);
        expect(selectedTargetIds, {'n1->n3'});
      },
    );

    test('adds edge id when edge is tapped in multiple selection mode', () {
      Set<String>? selectedTargetIds;

      final strategy = IdentifyInteractionStrategy(
        selectedTargetIds: const {'n1->n2'},
        allowMultiple: true,
        onSelectionChanged: (nextSelection) {
          selectedTargetIds = nextSelection;
        },
      );

      final action = strategy.handleEdgeTap('n1', 'n3');

      expect(action, isNull);
      expect(selectedTargetIds, {'n1->n2', 'n1->n3'});
    });

    test(
      'removes edge id when selected edge is tapped in multiple selection mode',
      () {
        Set<String>? selectedTargetIds;

        final strategy = IdentifyInteractionStrategy(
          selectedTargetIds: const {'n1->n2', 'n1->n3'},
          allowMultiple: true,
          onSelectionChanged: (nextSelection) {
            selectedTargetIds = nextSelection;
          },
        );

        final action = strategy.handleEdgeTap('n1', 'n3');

        expect(action, isNull);
        expect(selectedTargetIds, {'n1->n2'});
      },
    );

    test('does not select inventory values', () {
      Set<String>? selectedTargetIds;

      final strategy = IdentifyInteractionStrategy(
        selectedTargetIds: const {},
        allowMultiple: false,
        onSelectionChanged: (nextSelection) {
          selectedTargetIds = nextSelection;
        },
      );

      final action = strategy.handleInventoryTap(42);

      expect(action, isNull);
      expect(selectedTargetIds, isNull);
    });

    test('clearSelection does not clear identify answers', () {
      Set<String>? selectedTargetIds;

      final strategy = IdentifyInteractionStrategy(
        selectedTargetIds: const {'n1'},
        allowMultiple: false,
        onSelectionChanged: (nextSelection) {
          selectedTargetIds = nextSelection;
        },
      );

      strategy.clearSelection();

      expect(selectedTargetIds, isNull);
      expect(strategy.selectedNodeIds, {'n1'});
    });
  });
}
