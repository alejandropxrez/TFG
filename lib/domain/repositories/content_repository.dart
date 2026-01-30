import 'package:algoquest/domain/entities/challenge_definition.dart';
import 'package:algoquest/domain/entities/level_syllabus.dart';

abstract class ContentRepository {
  Future<LevelSyllabus> getLevelSyllabus(String levelId);
  Future<ChallengeDefinition> getChallenge(String challengeId);
}
