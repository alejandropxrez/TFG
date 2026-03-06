import 'package:algoquest/domain/entities/challenge_session.dart';

abstract class ValidationStrategy {
  bool isSolved(ChallengeSession session);
}
