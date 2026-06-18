import 'package:algoquest/presentation/widgets/challenge/components/binary_tree_swap_challenge_body.dart';
import 'package:algoquest/presentation/widgets/challenge/components/interactive_binary_tree.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BinaryTreeSwapChallengeBody', () {
    testWidgets('emits swap when two nodes are selected', (tester) async {
      String? capturedFirstNodeId;
      String? capturedSecondNodeId;

      const root = InteractiveBinaryTreeNode(
        id: 'n1',
        value: '10',
        left: InteractiveBinaryTreeNode(id: 'n2', value: '20'),
        right: InteractiveBinaryTreeNode(id: 'n3', value: '5'),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BinaryTreeSwapChallengeBody(
              root: root,
              onSwapNodes:
                  ({
                    required String firstNodeId,
                    required String secondNodeId,
                  }) {
                    capturedFirstNodeId = firstNodeId;
                    capturedSecondNodeId = secondNodeId;
                  },
            ),
          ),
        ),
      );

      await tester.tap(find.text('10'));
      await tester.pump();

      await tester.tap(find.text('20'));
      await tester.pump();

      expect(capturedFirstNodeId, 'n1');
      expect(capturedSecondNodeId, 'n2');
    });

    testWidgets('does not emit swap after selecting only one node', (
      tester,
    ) async {
      var swaps = 0;

      const root = InteractiveBinaryTreeNode(
        id: 'n1',
        value: '10',
        left: InteractiveBinaryTreeNode(id: 'n2', value: '20'),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BinaryTreeSwapChallengeBody(
              root: root,
              onSwapNodes:
                  ({
                    required String firstNodeId,
                    required String secondNodeId,
                  }) {
                    swaps++;
                  },
            ),
          ),
        ),
      );

      await tester.tap(find.text('10'));
      await tester.pump();

      expect(swaps, 0);
    });
  });
}
