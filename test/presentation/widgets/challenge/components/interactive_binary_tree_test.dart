import 'package:algoquest/domain/entities/identify_target_spec.dart';
import 'package:algoquest/presentation/widgets/challenge/components/interactive_binary_tree.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('InteractiveBinaryTree', () {
    testWidgets('renders all tree node values', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InteractiveBinaryTree(
              root: _tree(),
              targetType: IdentifyTargetType.node,
              selectedTargetIds: const {},
              allowMultiple: false,
              onSelectionChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('90'), findsOneWidget);
      expect(find.text('70'), findsOneWidget);
      expect(find.text('60'), findsOneWidget);
      expect(find.text('40'), findsOneWidget);
      expect(find.text('65'), findsOneWidget);
    });

    testWidgets('selects one node when target type is node', (tester) async {
      Set<String>? nextSelection;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InteractiveBinaryTree(
              root: _tree(),
              targetType: IdentifyTargetType.node,
              selectedTargetIds: const {},
              allowMultiple: false,
              onSelectionChanged: (selection) {
                nextSelection = selection;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('65'));
      await tester.pump();

      expect(nextSelection, {'65'});
    });

    testWidgets('toggles nodes when multiple selection is enabled', (
      tester,
    ) async {
      var selectedTargetIds = <String>{};

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return InteractiveBinaryTree(
                  root: _tree(),
                  targetType: IdentifyTargetType.node,
                  selectedTargetIds: selectedTargetIds,
                  allowMultiple: true,
                  onSelectionChanged: (selection) {
                    setState(() {
                      selectedTargetIds = selection;
                    });
                  },
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('70'));
      await tester.pump();

      expect(selectedTargetIds, {'70'});

      await tester.tap(find.text('65'));
      await tester.pump();

      expect(selectedTargetIds, {'70', '65'});

      await tester.tap(find.text('70'));
      await tester.pump();

      expect(selectedTargetIds, {'65'});
    });

    testWidgets('does not select nodes when target type is edge', (
      tester,
    ) async {
      Set<String>? nextSelection;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InteractiveBinaryTree(
              root: _tree(),
              targetType: IdentifyTargetType.edge,
              selectedTargetIds: const {},
              allowMultiple: false,
              onSelectionChanged: (selection) {
                nextSelection = selection;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('65'));
      await tester.pump();

      expect(nextSelection, isNull);
    });

    testWidgets('selects an edge when target type is edge', (tester) async {
      Set<String>? selectedTargetIds;

      const root = InteractiveBinaryTreeNode(
        id: '90',
        value: '90',
        left: InteractiveBinaryTreeNode(id: '60', value: '60'),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InteractiveBinaryTree(
              root: root,
              targetType: IdentifyTargetType.edge,
              selectedTargetIds: const {},
              allowMultiple: false,
              onSelectionChanged: (selection) {
                selectedTargetIds = selection;
              },
            ),
          ),
        ),
      );

      await tester.tap(
        find.byKey(const ValueKey('edge_90->60')),
        warnIfMissed: false,
      );
      await tester.pump();

      expect(selectedTargetIds, {'90->60'});
    });

    testWidgets('does not select edges when target type is node', (
      tester,
    ) async {
      Set<String>? nextSelection;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InteractiveBinaryTree(
              root: _tree(),
              targetType: IdentifyTargetType.node,
              selectedTargetIds: const {},
              allowMultiple: false,
              onSelectionChanged: (selection) {
                nextSelection = selection;
              },
            ),
          ),
        ),
      );

      await tester.tapAt(const Offset(245, 85));
      await tester.pump();

      expect(nextSelection, isNull);
    });
  });
}

InteractiveBinaryTreeNode _tree() {
  return const InteractiveBinaryTreeNode(
    id: '90',
    value: '90',
    left: InteractiveBinaryTreeNode(
      id: '70',
      value: '70',
      left: InteractiveBinaryTreeNode(id: '40', value: '40'),
    ),
    right: InteractiveBinaryTreeNode(
      id: '60',
      value: '60',
      right: InteractiveBinaryTreeNode(id: '65', value: '65'),
    ),
  );
}
