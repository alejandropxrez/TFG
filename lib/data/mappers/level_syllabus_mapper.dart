import 'package:algoquest/domain/entities/level_syllabus.dart' as domain;

import 'package:algoquest/data/models/level_syllabus_model.dart' as model;

class LevelSyllabusMapper {
  static domain.LevelSyllabus toDomain(model.LevelSyllabusModel modelData) {
    return domain.LevelSyllabus(
      id: modelData.id,
      title: modelData.title,
      topic: _mapTopic(modelData.topic),
      challenges: modelData.challenges,
      rewards: domain.LevelRewards(
        xp: modelData.rewards.xp,
        stars: modelData.rewards.stars,
        lives: modelData.rewards.lives,
      ),
    );
  }

  static domain.LevelTopic _mapTopic(model.LevelTopic topic) {
    switch (topic) {
      case model.LevelTopic.heaps:
        return domain.LevelTopic.heaps;
      case model.LevelTopic.lists:
        return domain.LevelTopic.lists;
      case model.LevelTopic.bst:
        return domain.LevelTopic.bst;
      case model.LevelTopic.mixed:
        return domain.LevelTopic.mixed;
    }
  }
}
