import '../../domain/entities/level_syllabus.dart';
import '../models/level_syllabus_model.dart';

class LevelSyllabusMapper {
  static LevelSyllabus toDomain(LevelSyllabusModel model) {
    return LevelSyllabus(
      id: model.id,
      title: model.title,
      topic: model.topic,
      challenges: model.challenges,
      rewards: LevelRewards(xp: model.rewards.xp, stars: model.rewards.stars),
    );
  }
}
