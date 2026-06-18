class LearningPathSyllabus {
  final String title;
  final List<LearningPathSyllabusPhase> phases;

  const LearningPathSyllabus({required this.title, required this.phases});
}

class LearningPathSyllabusPhase {
  final String id;
  final String title;
  final List<LearningPathSyllabusLevelRef> levels;

  const LearningPathSyllabusPhase({
    required this.id,
    required this.title,
    required this.levels,
  });
}

class LearningPathSyllabusLevelRef {
  final String id;

  const LearningPathSyllabusLevelRef({required this.id});
}
