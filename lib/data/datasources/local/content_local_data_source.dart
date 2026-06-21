import 'package:algoquest/data/models/challenge_model.dart';
import 'package:algoquest/data/models/level_syllabus_model.dart';
import 'package:algoquest/data/models/syllabus_model.dart';

/// Local data source contract for static educational content.
///
/// Implementations are responsible for reading and deserializing the JSON
/// assets that define the learning path, level syllabi, and challenges.
///
/// Invalid, missing, or malformed assets are expected to be reported through
/// the corresponding data-layer exception.
abstract class ContentLocalDataSource {
  /// Loads the syllabus definition associated with [levelId].
  ///
  /// The returned model contains the level metadata, theory content,
  /// challenge references, and rewards.
  Future<LevelSyllabusModel> getLevelSyllabus(String levelId);

  /// Loads the challenge definition associated with [challengeId].
  ///
  /// The concrete challenge configuration is represented by
  /// [ChallengeModel] and later converted into a domain entity by the
  /// repository layer.
  Future<ChallengeModel> getChallenge(String challengeId);

  /// Loads the global syllabus used to build the complete learning path.
  ///
  /// The returned model defines the available phases and the levels assigned
  /// to each phase.
  Future<SyllabusModel> getSyllabus();
}
