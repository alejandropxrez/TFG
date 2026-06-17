import 'package:algoquest/presentation/widgets/learning_path/learning_path_bottom_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildSubject({
    LearningPathBottomNavItem selectedItem = LearningPathBottomNavItem.map,
    ValueChanged<LearningPathBottomNavItem>? onItemSelected,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: LearningPathBottomNav(
          selectedItem: selectedItem,
          onItemSelected: onItemSelected,
        ),
      ),
    );
  }

  testWidgets('shows all navigation items', (tester) async {
    await tester.pumpWidget(buildSubject());

    expect(find.text('Mapa'), findsOneWidget);
    expect(find.text('Progreso'), findsOneWidget);
    expect(find.text('Clasificatoria'), findsOneWidget);
    expect(find.text('Perfil'), findsOneWidget);
  });

  testWidgets('notifies selected item when tapped', (tester) async {
    LearningPathBottomNavItem? selected;

    await tester.pumpWidget(
      buildSubject(
        onItemSelected: (item) {
          selected = item;
        },
      ),
    );

    await tester.tap(find.text('Progreso'));
    await tester.pump();

    expect(selected, LearningPathBottomNavItem.progress);
  });

  testWidgets('uses bold text for selected item', (tester) async {
    await tester.pumpWidget(
      buildSubject(selectedItem: LearningPathBottomNavItem.profile),
    );

    final selectedText = tester.widget<Text>(find.text('Perfil'));
    final unselectedText = tester.widget<Text>(find.text('Mapa'));

    expect(selectedText.style?.fontWeight, FontWeight.w900);
    expect(unselectedText.style?.fontWeight, FontWeight.w700);
  });
}
