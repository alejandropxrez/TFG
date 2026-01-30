import 'package:algoquest/domain/entities/challenge_definition.dart';
import 'package:algoquest/domain/entities/level_syllabus.dart';

abstract class ContentRepository {
  /// Fetches the syllabus for a specific level by its ID.
  Future<LevelSyllabus> getLevelSyllabus(String levelId);

  /// Fetches the definition of a specific challenge by its ID.
  Future<ChallengeDefinition> getChallenge(String challengeId);
}
