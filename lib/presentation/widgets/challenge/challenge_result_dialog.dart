import 'package:algoquest/domain/entities/challenge_spec.dart';
import 'package:algoquest/presentation/copy/challenge_result_copy.dart';
import 'package:algoquest/presentation/theme/app_assets.dart';
import 'package:algoquest/presentation/widgets/challenge/challenge_action_button.dart';
import 'package:algoquest/presentation/widgets/challenge/challenge_hearts_indicator.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

enum ChallengeResultDialogType { success, failure }

class ChallengeResultDialog extends StatefulWidget {
  final ChallengeResultDialogType type;
  final String title;
  final String subtitle;
  final String message;
  final String helperTitle;
  final String helperMessage;
  final String primaryActionLabel;
  final String? secondaryActionLabel;
  final String heartsLabel;
  final int? heartsLeft;
  final int? maxHearts;
  final VoidCallback onPrimaryAction;
  final VoidCallback? onSecondaryAction;
  final VoidCallback? onClose;

  const ChallengeResultDialog({
    super.key,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.message,
    required this.helperTitle,
    required this.helperMessage,
    required this.primaryActionLabel,
    this.secondaryActionLabel,
    this.heartsLabel = ChallengeResultCopy.heartsLeftLabel,
    this.heartsLeft,
    this.maxHearts,
    required this.onPrimaryAction,
    this.onSecondaryAction,
    this.onClose,
  });

  factory ChallengeResultDialog.fromChallengeSpec({
    required ChallengeSpec spec,
    required bool solved,
    required VoidCallback onContinue,
    required VoidCallback onTryAgain,
    required String? theoryMessage,
    VoidCallback? onShowAnswer,
    int? attemptsRemaining,
  }) {
    final copy = ChallengeResultDialogCopy.fromChallengeSpec(
      spec: spec,
      solved: solved,
      theoryMessage: theoryMessage,
    );

    return ChallengeResultDialog(
      type: solved
          ? ChallengeResultDialogType.success
          : ChallengeResultDialogType.failure,
      title: copy.title,
      subtitle: copy.subtitle,
      message: copy.message,
      helperTitle: copy.helperTitle,
      helperMessage: copy.helperMessage,
      primaryActionLabel: copy.primaryActionLabel,
      secondaryActionLabel: copy.secondaryActionLabel,
      heartsLabel: copy.heartsLabel,
      heartsLeft: solved ? null : attemptsRemaining,
      maxHearts: solved ? null : spec.maxAttempts,
      onPrimaryAction: solved ? onContinue : onTryAgain,
      onSecondaryAction: solved ? null : onShowAnswer,
    );
  }

  bool get isSuccess => type == ChallengeResultDialogType.success;

  @override
  State<ChallengeResultDialog> createState() => _ChallengeResultDialogState();
}

class _ChallengeResultDialogState extends State<ChallengeResultDialog> {
  late final ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();

    _confettiController = ConfettiController(
      duration: const Duration(milliseconds: 800),
    );

    if (widget.isSuccess) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _confettiController.play();
        }
      });
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = _ChallengeResultDialogTheme.fromType(widget.type);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          if (widget.isSuccess)
            Positioned(
              top: -20,
              child: IgnorePointer(
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirectionality: BlastDirectionality.explosive,
                  emissionFrequency: 0.06,
                  numberOfParticles: 24,
                  maxBlastForce: 400,
                  minBlastForce: 300,
                  gravity: 0.28,
                  shouldLoop: false,
                ),
              ),
            ),
          Container(
            margin: const EdgeInsets.only(top: 52),
            padding: const EdgeInsets.fromLTRB(22, 72, 22, 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.16),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: theme.titleColor,
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    height: 0.95,
                    letterSpacing: -0.7,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF1E2442),
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF1E2442),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 16),
                _HelperBox(
                  iconAssetPath: AppAssets.lightBulb,
                  title: widget.helperTitle,
                  message: widget.helperMessage,
                  backgroundColor: theme.helperBackgroundColor,
                  borderColor: theme.helperBorderColor,
                  titleColor: theme.helperTitleColor,
                ),
                if (!widget.isSuccess && widget.heartsLeft != null) ...[
                  const SizedBox(height: 14),
                  ChallengeHeartsIndicator(
                    label: widget.heartsLabel,
                    heartsLeft: widget.heartsLeft!,
                    maxHearts: 3,
                    heartSize: 22,
                    heartScale: 3,
                    spacing: 8,
                    labelSpacing: 8,
                    emptyOpacity: 0.25,
                  ),
                ],
                const SizedBox(height: 18),
                if (widget.isSuccess)
                  ChallengePrimaryActionButton(
                    label: widget.primaryActionLabel,
                    icon: Icons.arrow_forward_rounded,
                    backgroundColor: theme.primaryColor,
                    onPressed: widget.onPrimaryAction,
                  )
                else
                  Row(
                    children: [
                      Expanded(
                        child: ChallengeOutlinedActionButton(
                          label: widget.primaryActionLabel,
                          iconAssetPath: AppAssets.retry,
                          color: theme.primaryColor,
                          onPressed: widget.onPrimaryAction,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ChallengeOutlinedActionButton(
                          label: widget.secondaryActionLabel ?? '',
                          iconAssetPath: AppAssets.eyes,
                          color: const Color(0xFF6B3DEB),
                          onPressed: widget.onSecondaryAction,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          Positioned(top: 0, child: _MascotImage(type: widget.type)),
          Positioned(
            top: 62,
            right: 16,
            child: _CloseButton(
              onPressed: widget.onClose ?? () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}

class _MascotImage extends StatelessWidget {
  final ChallengeResultDialogType type;

  const _MascotImage({required this.type});

  @override
  Widget build(BuildContext context) {
    final isSuccess = type == ChallengeResultDialogType.success;

    return SizedBox(
      width: 124,
      height: 124,
      child: Transform.translate(
        offset: Offset(0, isSuccess ? -38 : 0),
        child: Transform.scale(
          scale: 2.4,
          child: Image.asset(
            isSuccess ? AppAssets.happyDinosaurStar : AppAssets.worriedFox,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

class _CloseButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _CloseButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 34,
      height: 34,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF9AA0B4),
          padding: EdgeInsets.zero,
          shape: const CircleBorder(),
        ),
        child: const Icon(Icons.close_rounded, color: Colors.white, size: 22),
      ),
    );
  }
}

class _HelperBox extends StatelessWidget {
  final String iconAssetPath;
  final String title;
  final String message;
  final Color backgroundColor;
  final Color borderColor;
  final Color titleColor;

  const _HelperBox({
    required this.iconAssetPath,
    required this.title,
    required this.message,
    required this.backgroundColor,
    required this.borderColor,
    required this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.4),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: Transform.scale(
              scale: 4,
              child: Image.asset(iconAssetPath, fit: BoxFit.contain),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: titleColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: const TextStyle(
                    color: Color(0xFF1E2442),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChallengeResultDialogTheme {
  final Color titleColor;
  final Color primaryColor;
  final Color helperBackgroundColor;
  final Color helperBorderColor;
  final Color helperTitleColor;
  final String helperIconAsset;

  const _ChallengeResultDialogTheme({
    required this.titleColor,
    required this.primaryColor,
    required this.helperBackgroundColor,
    required this.helperBorderColor,
    required this.helperTitleColor,
    required this.helperIconAsset,
  });

  factory _ChallengeResultDialogTheme.fromType(ChallengeResultDialogType type) {
    switch (type) {
      case ChallengeResultDialogType.success:
        return const _ChallengeResultDialogTheme(
          titleColor: Color(0xFF36A852),
          primaryColor: Color(0xFF36A852),
          helperBackgroundColor: Color(0xFFEAF7EE),
          helperBorderColor: Color(0xFFBFE8C9),
          helperTitleColor: Color(0xFF24863F),
          helperIconAsset: AppAssets.graduationCap,
        );
      case ChallengeResultDialogType.failure:
        return const _ChallengeResultDialogTheme(
          titleColor: Color(0xFFE84842),
          primaryColor: Color(0xFFE84842),
          helperBackgroundColor: Color(0xFFFFF1F1),
          helperBorderColor: Color(0xFFF3C6C6),
          helperTitleColor: Color(0xFFE84842),
          helperIconAsset: AppAssets.lightBulb,
        );
    }
  }
}
