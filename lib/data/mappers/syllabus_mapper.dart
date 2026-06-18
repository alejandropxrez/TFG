import 'package:algoquest/data/models/syllabus_model.dart' as model;
import 'package:algoquest/domain/entities/learning_path_syllabus.dart'
    as domain;

class SyllabusMapper {
  static domain.LearningPathSyllabus toDomain(model.SyllabusModel modelData) {
    return domain.LearningPathSyllabus(
      title: modelData.title,
      phases: modelData.phases
          .map(
            (phase) => domain.LearningPathSyllabusPhase(
              id: phase.id,
              title: phase.title,
              levels: phase.levels
                  .map(
                    (level) =>
                        domain.LearningPathSyllabusLevelRef(id: level.id),
                  )
                  .toList(),
            ),
          )
          .toList(),
    );
  }
}
