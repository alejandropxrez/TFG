enum LevelTopic { heaps, lists, bst, mixed }

class LevelRewards {
  final int xp;
  final int stars;
  final int lives;

  const LevelRewards({required this.xp, required this.stars, this.lives = 0});
}

class LevelSyllabus {
  final String id;
  final String title;
  final String subtitle;
  final LevelTopic topic;
  final List<String> challenges;
  final LevelRewards rewards;
  final LevelTheory? theory;

  const LevelSyllabus({
    required this.id,
    required this.title,
    this.subtitle = '',
    required this.topic,
    required this.challenges,
    required this.rewards,
    this.theory,
  });
}

class LevelTheory {
  final String id;
  final String title;
  final String content;
  final List<String> keyPoints;

  const LevelTheory({
    required this.id,
    required this.title,
    required this.content,
    this.keyPoints = const [],
  });
}
