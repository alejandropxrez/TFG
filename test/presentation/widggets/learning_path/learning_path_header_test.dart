import 'package:algoquest/presentation/widgets/learning_path/learning_path_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildSubject({String title = 'AlgoQuest', int xp = 1253}) {
    return MaterialApp(
      home: Scaffold(
        body: LearningPathHeader(title: title, xp: xp),
      ),
    );
  }

  testWidgets('shows title and formatted xp', (tester) async {
    await tester.pumpWidget(buildSubject());

    expect(find.text('AlgoQuest'), findsOneWidget);
    expect(find.text('1,253 XP'), findsOneWidget);
  });

  testWidgets('formats large xp values with comma separators', (tester) async {
    await tester.pumpWidget(buildSubject(xp: 1250000));

    expect(find.text('1,250,000 XP'), findsOneWidget);
  });

  testWidgets('keeps long title in a single rendered text widget', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildSubject(title: 'AlgoQuest Learning Path With A Very Long Title'),
    );

    expect(
      find.text('AlgoQuest Learning Path With A Very Long Title'),
      findsOneWidget,
    );
  });
}
