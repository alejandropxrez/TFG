import 'package:algoquest/data/models/challenge_model.dart';
import 'package:algoquest/data/models/level_syllabus_model.dart';
import 'package:algoquest/data/models/syllabus_model.dart';

/// Reads static game definitions from local JSON assets.
abstract class ContentLocalDataSource {
  /// Loads the syllabus definition of a level.
  Future<LevelSyllabusModel> getLevelSyllabus(String levelId);

  /// Loads a single challenge definition.
  Future<ChallengeModel> getChallenge(String challengeId);

  /// Loads the global syllabus definition.
  Future<SyllabusModel> getSyllabus();
}
