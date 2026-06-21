import 'package:algoquest/domain/entities/challenge_spec.dart';
import 'package:algoquest/domain/entities/level_syllabus.dart';
import 'package:algoquest/domain/entities/learning_path_syllabus.dart';

/// Repository contract for accessing educational content.
///
/// Implementations are responsible for providing level definitions,
/// challenge specifications, and the global learning path without exposing
/// how that content is stored or loaded.
abstract class ContentRepository {
  /// Loads the syllabus associated with [levelId].
  ///
  /// The returned entity contains the level metadata, theory, challenge
  /// sequence, and rewards.
  Future<LevelSyllabus> getLevelSyllabus(String levelId);

  /// Loads the complete learning path definition.
  ///
  /// The returned syllabus contains the available phases and their levels.
  Future<LearningPathSyllabus> getSyllabus();

  /// Loads the challenge specification associated with [challengeId].
  Future<ChallengeSpec> getChallenge(String challengeId);

  /// Returns the identifier of the level that follows [currentLevelId].
  ///
  /// Returns `null` when the current level is the final level in the learning
  /// path or when no subsequent level exists.
  Future<String?> getNextLevelId(String currentLevelId);
}
