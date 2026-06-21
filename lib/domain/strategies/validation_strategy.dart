import 'package:algoquest/domain/entities/challenge_session.dart';

/// Strategy contract for validating whether a challenge session is solved.
///
/// Concrete implementations encapsulate the validation rules associated with
/// a particular challenge type or objective.
abstract class ValidationStrategy {
  /// Returns whether the current state of [session] satisfies the challenge
  /// completion conditions.
  bool isSolved(ChallengeSession session);
}
