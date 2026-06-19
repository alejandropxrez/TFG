import 'package:algoquest/domain/entities/level_syllabus.dart';
import 'package:algoquest/presentation/widgets/level_intro/level_intro_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildSubject({
    required LevelSyllabus syllabus,
    VoidCallback? onBack,
    VoidCallback? onStartPractice,
  }) {
    return MaterialApp(
      home: LevelIntroView(
        syllabus: syllabus,
        onBack: onBack ?? () {},
        onStartPractice: onStartPractice ?? () {},
      ),
    );
  }

  LevelSyllabus buildSyllabus({
    LevelTheory? theory,
    List<String> challenges = const [
      'challenge_1',
      'challenge_2',
      'challenge_3',
    ],
  }) {
    return LevelSyllabus(
      id: 'level_lists_intro',
      title: 'Introducción a Listas',
      topic: LevelTopic.lists,
      theory: theory,
      challenges: challenges,
      rewards: const LevelRewards(xp: 100, stars: 3),
    );
  }

  const theory = LevelTheory(
    id: "test",
    title: '¿Qué es una Lista?',
    content:
        'Una lista es una estructura de datos lineal que almacena una colección de elementos en un orden específico.',
    keyPoints: [
      'Las listas mantienen el orden de inserción.',
      'Se puede acceder a elementos por su posición o índice.',
      'Las listas permiten inserción, eliminación y modificación de elementos.',
    ],
  );

  Future<void> setTestSurfaceSize(
    WidgetTester tester, {
    Size size = const Size(390, 844),
  }) async {
    await tester.binding.setSurfaceSize(size);
    addTearDown(() => tester.binding.setSurfaceSize(null));
  }

  testWidgets('shows theory content from syllabus', (tester) async {
    await setTestSurfaceSize(tester);
    await tester.pumpWidget(
      buildSubject(syllabus: buildSyllabus(theory: theory)),
    );

    expect(find.text('¿Qué es una Lista?'), findsOneWidget);
    expect(find.text('¡Construyamos unas bases sólidas!'), findsOneWidget);
    expect(find.text('Tema: Introducción a Listas'), findsOneWidget);
    expect(
      find.textContaining('Una lista es una estructura de datos lineal'),
      findsOneWidget,
    );
    expect(find.text('Ideas clave'), findsOneWidget);
  });

  testWidgets('shows all theory key points', (tester) async {
    await setTestSurfaceSize(tester);
    await tester.pumpWidget(
      buildSubject(syllabus: buildSyllabus(theory: theory)),
    );

    expect(
      find.text('Las listas mantienen el orden de inserción.'),
      findsOneWidget,
    );
    expect(
      find.text('Se puede acceder a elementos por su posición o índice.'),
      findsOneWidget,
    );
    expect(
      find.text(
        'Las listas permiten inserción, eliminación y modificación de elementos.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('shows number of challenges in motivation card', (tester) async {
    await setTestSurfaceSize(tester);
    await tester.pumpWidget(
      buildSubject(
        syllabus: buildSyllabus(
          theory: theory,
          challenges: const ['challenge_1', 'challenge_2', 'challenge_3'],
        ),
      ),
    );

    expect(find.text('¡Tú puedes!'), findsOneWidget);
    expect(
      find.text('¡Tienes 3 desafíos por delante para mejorar tus habilidades!'),
      findsOneWidget,
    );
  });

  testWidgets('calls onBack when back button is tapped', (tester) async {
    await setTestSurfaceSize(tester);
    var called = false;

    await tester.pumpWidget(
      buildSubject(
        syllabus: buildSyllabus(theory: theory),
        onBack: () {
          called = true;
        },
      ),
    );

    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pump();

    expect(called, isTrue);
  });

  testWidgets('calls onStartPractice when start button is tapped', (
    tester,
  ) async {
    await setTestSurfaceSize(tester);
    var called = false;

    await tester.pumpWidget(
      buildSubject(
        syllabus: buildSyllabus(theory: theory),
        onStartPractice: () {
          called = true;
        },
      ),
    );

    await tester.ensureVisible(find.text('¡Vamos allá!'));
    await tester.tap(find.text('¡Vamos allá!'));
    await tester.pump();

    expect(called, isTrue);
  });

  testWidgets('shows fallback content when theory is missing', (tester) async {
    await setTestSurfaceSize(tester);
    await tester.pumpWidget(
      buildSubject(syllabus: buildSyllabus(theory: null)),
    );

    expect(find.text('Introducción a Listas'), findsOneWidget);
    expect(
      find.text('Repasa el concepto principal antes de empezar la práctica.'),
      findsOneWidget,
    );
    expect(find.text('Ideas clave'), findsNothing);
  });
}
