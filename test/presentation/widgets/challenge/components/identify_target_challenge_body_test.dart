import 'package:algoquest/domain/entities/identify_target_spec.dart';
import 'package:algoquest/presentation/widgets/challenge/components/interactive_binary_tree.dart';
import 'package:algoquest/presentation/widgets/challenge/identify_target_challenge_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('IdentifyTargetChallengeBody', () {
    testWidgets('renders the interactive binary tree', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IdentifyTargetChallengeBody(
              root: _tree(),
              targetType: IdentifyTargetType.node,
              selectedTargetIds: const {},
              allowMultiple: false,
              onSelectionChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.byType(InteractiveBinaryTree), findsOneWidget);
      expect(find.text('90'), findsOneWidget);
      expect(find.text('70'), findsOneWidget);
      expect(find.text('60'), findsOneWidget);
    });

    testWidgets('passes node selections to onSelectionChanged', (tester) async {
      Set<String>? nextSelection;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IdentifyTargetChallengeBody(
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

      await tester.tap(find.text('70'));
      await tester.pump();

      expect(nextSelection, {'70'});
    });

    testWidgets('passes edge selections to onSelectionChanged', (tester) async {
      Set<String>? selectedTargetIds;

      const root = InteractiveBinaryTreeNode(
        id: '90',
        value: '90',
        left: InteractiveBinaryTreeNode(id: '60', value: '60'),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IdentifyTargetChallengeBody(
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
  });
}

InteractiveBinaryTreeNode _tree() {
  return const InteractiveBinaryTreeNode(
    id: '90',
    value: '90',
    left: InteractiveBinaryTreeNode(id: '70', value: '70'),
    right: InteractiveBinaryTreeNode(id: '60', value: '60'),
  );
}
