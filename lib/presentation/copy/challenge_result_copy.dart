import 'package:algoquest/domain/entities/challenge_spec.dart';

abstract final class ChallengeResultCopy {
  static const successTitle = '¡Lo clavaste!';
  static const failureTitle = '¡Casi!';

  static const theoryTipTitle = 'Consejo teórico';
  static const hintTitle = 'Pista';

  static const continueLabel = 'Continuar';
  static const tryAgainLabel = 'Intentar de nuevo';
  static const showAnswerLabel = 'Ver respuesta';
  static const heartsLeftLabel = 'Vidas restantes:';

  static const fallbackTheoryMessage =
      'Revisa la teoría de este reto antes de continuar.';
}

class ChallengeResultDialogCopy {
  final String title;
  final String subtitle;
  final String message;
  final String helperTitle;
  final String helperMessage;
  final String primaryActionLabel;
  final String? secondaryActionLabel;
  final String heartsLabel;

  const ChallengeResultDialogCopy({
    required this.title,
    required this.subtitle,
    required this.message,
    required this.helperTitle,
    required this.helperMessage,
    required this.primaryActionLabel,
    this.secondaryActionLabel,
    required this.heartsLabel,
  });

  factory ChallengeResultDialogCopy.fromChallengeSpec({
    required ChallengeSpec spec,
    required bool solved,
    required String? theoryMessage,
    required bool canTryAgain,
    required bool canRevealAnswer,
  }) {
    return ChallengeResultDialogCopy(
      title: solved
          ? ChallengeResultCopy.successTitle
          : ChallengeResultCopy.failureTitle,
      subtitle: spec.title,
      message: spec.instruction,
      helperTitle: solved
          ? ChallengeResultCopy.theoryTipTitle
          : ChallengeResultCopy.hintTitle,
      helperMessage: theoryMessage ?? ChallengeResultCopy.fallbackTheoryMessage,

      primaryActionLabel: solved
          ? ChallengeResultCopy.continueLabel
          : ChallengeResultCopy.tryAgainLabel,

      secondaryActionLabel: !solved && canRevealAnswer
          ? ChallengeResultCopy.showAnswerLabel
          : null,

      heartsLabel: ChallengeResultCopy.heartsLeftLabel,
    );
  }
}
