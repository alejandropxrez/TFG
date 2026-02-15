import '../entities/challenge_session.dart';

abstract class ValidationStrategy {
  bool isSolved(ChallengeSession session);
}
