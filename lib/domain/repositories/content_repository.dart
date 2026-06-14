import 'package:algoquest/domain/entities/challenge_spec.dart';
import 'package:algoquest/domain/entities/level_syllabus.dart';

abstract class ContentRepository {
  /// Fetches the syllabus for a specific level by its ID.
  Future<LevelSyllabus> getLevelSyllabus(String levelId);

  /// Fetches the definition of a specific challenge by its ID.
  Future<ChallengeSpec> getChallenge(String challengeId);

  /// Fetches the next level id from the current one.
  Future<String?> getNextLevelId(String currentLevelId);
}
