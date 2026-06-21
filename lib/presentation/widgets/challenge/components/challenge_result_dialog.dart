import 'dart:async';

import 'package:algoquest/domain/entities/challenge_spec.dart';
import 'package:algoquest/presentation/copy/challenge_result_copy.dart';
import 'package:algoquest/presentation/theme/app_assets.dart';
import 'package:algoquest/presentation/widgets/challenge/components/challenge_action_button.dart';
import 'package:algoquest/presentation/widgets/challenge/components/challenge_hearts_indicator.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/foundation.dart';
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
  final bool canUsePrimaryAction;
  final bool canUseSecondaryAction;
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
    this.canUsePrimaryAction = true,
    this.canUseSecondaryAction = false,
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
    required bool canTryAgain,
    required bool canRevealAnswer,
    VoidCallback? onShowAnswer,
    int? attemptsRemaining,
  }) {
    final copy = ChallengeResultDialogCopy.fromChallengeSpec(
      spec: spec,
      solved: solved,
      theoryMessage: theoryMessage,
      canTryAgain: canTryAgain,
      canRevealAnswer: canRevealAnswer,
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
      canUsePrimaryAction: solved || canTryAgain,
      canUseSecondaryAction: !solved && canRevealAnswer,
      onPrimaryAction: solved ? onContinue : onTryAgain,
      onSecondaryAction: !solved && canRevealAnswer ? onShowAnswer : null,
    );
  }

  bool get isSuccess => type == ChallengeResultDialogType.success;

  bool get shouldShowHearts {
    return !isSuccess && heartsLeft != null && maxHearts != null;
  }

  bool get shouldShowSecondaryAction {
    return canUseSecondaryAction &&
        secondaryActionLabel != null &&
        onSecondaryAction != null;
  }

  @override
  State<ChallengeResultDialog> createState() => _ChallengeResultDialogState();
}

class _ChallengeResultDialogState extends State<ChallengeResultDialog> {
  late final ConfettiController _confettiController;
  Animation<double>? _routeAnimation;
  Timer? _confettiStartTimer;
  bool _confettiStartRequested = false;

  @override
  void initState() {
    super.initState();

    _confettiController = ConfettiController(
      duration: defaultTargetPlatform == TargetPlatform.android
          ? const Duration(milliseconds: 2200)
          : const Duration(milliseconds: 1600),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!widget.isSuccess || _confettiStartRequested) return;

    _confettiStartRequested = true;
    final routeAnimation = ModalRoute.of(context)?.animation;

    if (routeAnimation == null ||
        routeAnimation.status == AnimationStatus.completed) {
      _playConfettiAfterFrame();
      return;
    }

    _routeAnimation = routeAnimation;
    _routeAnimation!.addStatusListener(_onRouteAnimationStatusChanged);
  }

  void _onRouteAnimationStatusChanged(AnimationStatus status) {
    if (status != AnimationStatus.completed) return;

    _routeAnimation?.removeStatusListener(_onRouteAnimationStatusChanged);
    _routeAnimation = null;
    _playConfettiAfterFrame();
  }

  void _playConfettiAfterFrame() {
    final startDelay = Theme.of(context).platform == TargetPlatform.android
        ? const Duration(milliseconds: 350)
        : Duration.zero;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (startDelay > Duration.zero) {
        _confettiStartTimer = Timer(startDelay, () {
          if (mounted) _confettiController.play();
        });
        return;
      }

      if (mounted) _confettiController.play();
    });
  }

  @override
  void dispose() {
    _routeAnimation?.removeStatusListener(_onRouteAnimationStatusChanged);
    _confettiStartTimer?.cancel();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = _ChallengeResultDialogTheme.fromType(widget.type);
    final isAndroid = Theme.of(context).platform == TargetPlatform.android;

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
                  emissionFrequency: isAndroid ? 0.12 : 0.06,
                  numberOfParticles: isAndroid ? 22 : 24,
                  maxBlastForce: isAndroid ? 55 : 400,
                  minBlastForce: isAndroid ? 32 : 300,
                  gravity: isAndroid ? 0.14 : 0.18,
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
                  iconAssetPath: theme.helperIconAsset,
                  title: widget.helperTitle,
                  message: widget.helperMessage,
                  backgroundColor: theme.helperBackgroundColor,
                  borderColor: theme.helperBorderColor,
                  titleColor: theme.helperTitleColor,
                ),
                if (widget.shouldShowHearts) ...[
                  const SizedBox(height: 14),
                  ChallengeHeartsIndicator(
                    label: widget.heartsLabel,
                    heartsLeft: widget.heartsLeft!,
                    maxHearts: widget.maxHearts!,
                    heartSize: 22,
                    heartScale: 3,
                    spacing: 8,
                    labelSpacing: 8,
                    emptyOpacity: 0.25,
                  ),
                ],
                const SizedBox(height: 18),
                _DialogActions(
                  isSuccess: widget.isSuccess,
                  primaryActionLabel: widget.primaryActionLabel,
                  secondaryActionLabel: widget.secondaryActionLabel,
                  canUsePrimaryAction: widget.canUsePrimaryAction,
                  canUseSecondaryAction: widget.shouldShowSecondaryAction,
                  primaryColor: theme.primaryColor,
                  onPrimaryAction: widget.onPrimaryAction,
                  onSecondaryAction: widget.onSecondaryAction,
                ),
              ],
            ),
          ),
          Positioned(top: 0, child: _MascotImage(type: widget.type)),
        ],
      ),
    );
  }
}

class _DialogActions extends StatelessWidget {
  final bool isSuccess;
  final String primaryActionLabel;
  final String? secondaryActionLabel;
  final bool canUsePrimaryAction;
  final bool canUseSecondaryAction;
  final Color primaryColor;
  final VoidCallback onPrimaryAction;
  final VoidCallback? onSecondaryAction;

  const _DialogActions({
    required this.isSuccess,
    required this.primaryActionLabel,
    required this.secondaryActionLabel,
    required this.canUsePrimaryAction,
    required this.canUseSecondaryAction,
    required this.primaryColor,
    required this.onPrimaryAction,
    required this.onSecondaryAction,
  });

  @override
  Widget build(BuildContext context) {
    if (isSuccess) {
      return SizedBox(
        width: double.infinity,
        child: ChallengePrimaryActionButton(
          label: primaryActionLabel,
          icon: Icons.arrow_forward_rounded,
          backgroundColor: primaryColor,
          onPressed: onPrimaryAction,
        ),
      );
    }

    final primaryButton = canUsePrimaryAction
        ? ChallengeOutlinedActionButton(
            label: primaryActionLabel,
            iconAssetPath: AppAssets.retry,
            color: primaryColor,
            onPressed: onPrimaryAction,
          )
        : null;

    final secondaryButton =
        canUseSecondaryAction && secondaryActionLabel != null
        ? ChallengeOutlinedActionButton(
            label: secondaryActionLabel!,
            iconAssetPath: AppAssets.eyes,
            color: const Color(0xFF6B3DEB),
            onPressed: onSecondaryAction,
          )
        : null;

    if (primaryButton == null && secondaryButton == null) {
      return const SizedBox.shrink();
    }

    if (primaryButton != null && secondaryButton == null) {
      return SizedBox(width: double.infinity, child: primaryButton);
    }

    if (primaryButton == null && secondaryButton != null) {
      return SizedBox(width: double.infinity, child: secondaryButton);
    }

    return Row(
      children: [
        Expanded(child: primaryButton!),
        const SizedBox(width: 10),
        Expanded(child: secondaryButton!),
      ],
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
