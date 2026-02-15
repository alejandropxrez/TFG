enum LevelTopic { heaps, lists, bst, mixed }

class LevelRewards {
  final int xp;
  final int stars;

  const LevelRewards({required this.xp, required this.stars});
}

class LevelSyllabus {
  final String id;
  final String title;
  final LevelTopic topic;
  final List<String> challenges;
  final LevelRewards rewards;

  const LevelSyllabus({
    required this.id,
    required this.title,
    required this.topic,
    required this.challenges,
    required this.rewards,
  });
}
