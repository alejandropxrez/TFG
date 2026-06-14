class SyllabusModel {
  final String title;
  final List<SyllabusPhaseModel> phases;

  const SyllabusModel({required this.title, required this.phases});

  factory SyllabusModel.fromJson(Map<String, dynamic> json) {
    final phasesJson = json['phases'];

    if (phasesJson is! List) {
      throw const FormatException('Expected "phases" list in syllabus.json.');
    }

    return SyllabusModel(
      title: json['title'] as String? ?? 'AlgoQuest',
      phases: phasesJson
          .map(
            (phaseJson) =>
                SyllabusPhaseModel.fromJson(phaseJson as Map<String, dynamic>),
          )
          .toList(),
    );
  }
}

class SyllabusPhaseModel {
  final String id;
  final String title;
  final List<SyllabusLevelRefModel> levels;

  const SyllabusPhaseModel({
    required this.id,
    required this.title,
    required this.levels,
  });

  factory SyllabusPhaseModel.fromJson(Map<String, dynamic> json) {
    final levelsJson = json['levels'];

    if (levelsJson is! List) {
      throw FormatException(
        'Expected "levels" list in syllabus phase "${json['id']}".',
      );
    }

    return SyllabusPhaseModel(
      id: json['id'] as String,
      title: json['title'] as String,
      levels: levelsJson
          .map(
            (levelJson) => SyllabusLevelRefModel.fromJson(
              levelJson as Map<String, dynamic>,
            ),
          )
          .toList(),
    );
  }
}

class SyllabusLevelRefModel {
  final String id;

  const SyllabusLevelRefModel({required this.id});

  factory SyllabusLevelRefModel.fromJson(Map<String, dynamic> json) {
    return SyllabusLevelRefModel(id: json['id'] as String);
  }
}
