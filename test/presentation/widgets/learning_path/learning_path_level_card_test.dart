import 'package:algoquest/presentation/theme/app_assets.dart';
import 'package:algoquest/presentation/widgets/learning_path/learning_path_level_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildSubject({
    LearningPathLevelCardStatus status = LearningPathLevelCardStatus.available,
    VoidCallback? onPressed,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: LearningPathLevelCard(
            number: 1,
            title: 'Heaps intro',
            subtitle: 'Learn heap basics',
            xp: 100,
            status: status,
            imageAssetPath: AppAssets.tree,
            onPressed: onPressed,
          ),
        ),
      ),
    );
  }

  testWidgets('shows level information', (tester) async {
    await tester.pumpWidget(buildSubject());

    expect(find.text('Heaps intro'), findsOneWidget);
    expect(find.text('Learn heap basics'), findsOneWidget);
    expect(find.text('XP 100'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('shows available action and calls onPressed', (tester) async {
    var pressed = false;

    await tester.pumpWidget(
      buildSubject(
        onPressed: () {
          pressed = true;
        },
      ),
    );

    expect(find.text("¡Vamos!"), findsOneWidget);

    await tester.tap(find.text("¡Vamos!"));
    await tester.pump();

    expect(pressed, isTrue);
  });

  testWidgets('shows locked action and does not call onPressed', (
    tester,
  ) async {
    var pressed = false;

    await tester.pumpWidget(
      buildSubject(
        status: LearningPathLevelCardStatus.locked,
        onPressed: () {
          pressed = true;
        },
      ),
    );

    expect(find.text('Bloqueado'), findsOneWidget);

    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNull);

    expect(pressed, isFalse);
  });

  testWidgets('shows completed action and calls onPressed', (tester) async {
    var pressed = false;

    await tester.pumpWidget(
      buildSubject(
        status: LearningPathLevelCardStatus.completed,
        onPressed: () {
          pressed = true;
        },
      ),
    );

    expect(find.text('Volver a jugar'), findsOneWidget);

    await tester.tap(find.text('Volver a jugar'));
    await tester.pump();

    expect(pressed, isTrue);
  });
}
