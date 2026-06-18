import 'package:algoquest/data/mappers/syllabus_mapper.dart';
import 'package:algoquest/data/models/syllabus_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps SyllabusModel to LearningPathSyllabus domain entity', () {
    const model = SyllabusModel(
      title: 'AlgoQuest',
      phases: [
        SyllabusPhaseModel(
          id: 'phase_heaps',
          title: 'Heaps',
          levels: [
            SyllabusLevelRefModel(id: 'level_heap_intro'),
            SyllabusLevelRefModel(id: 'level_heap_advanced'),
          ],
        ),
        SyllabusPhaseModel(
          id: 'phase_trees',
          title: 'Árboles',
          levels: [SyllabusLevelRefModel(id: 'level_bst_intro')],
        ),
      ],
    );

    final domain = SyllabusMapper.toDomain(model);

    expect(domain.title, 'AlgoQuest');
    expect(domain.phases.length, 2);
    expect(domain.phases[0].id, 'phase_heaps');
    expect(domain.phases[0].title, 'Heaps');
    expect(domain.phases[0].levels.map((level) => level.id), [
      'level_heap_intro',
      'level_heap_advanced',
    ]);
    expect(domain.phases[1].id, 'phase_trees');
    expect(domain.phases[1].levels.single.id, 'level_bst_intro');
  });
}
