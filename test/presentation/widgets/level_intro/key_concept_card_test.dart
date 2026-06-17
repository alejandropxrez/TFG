import 'package:algoquest/presentation/widgets/level_intro/key_concept_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildSubject({
    String title = 'Las listas mantienen el orden de inserción.',
    IconData icon = Icons.account_tree_rounded,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 180,
            height: 140,
            child: KeyConceptCard(
              title: title,
              icon: icon,
              backgroundColor: const Color(0xFFF5EDFF),
              borderColor: const Color(0xFFD9C4FF),
              iconColor: const Color(0xFF6B3DEB),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('shows key concept title and icon', (tester) async {
    await tester.pumpWidget(buildSubject());

    expect(
      find.text('Las listas mantienen el orden de inserción.'),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.account_tree_rounded), findsOneWidget);
  });

  testWidgets('uses configured icon color', (tester) async {
    await tester.pumpWidget(buildSubject());

    final icon = tester.widget<Icon>(find.byIcon(Icons.account_tree_rounded));

    expect(icon.color, const Color(0xFF6B3DEB));
    expect(icon.size, 42);
  });

  testWidgets('renders long title without creating extra text widgets', (
    tester,
  ) async {
    const title =
        'Las listas permiten inserción, eliminación y modificación de elementos.';

    await tester.pumpWidget(buildSubject(title: title));

    expect(find.text(title), findsOneWidget);
  });
}
