import 'package:algoquest/presentation/theme/app_assets.dart';
import 'package:algoquest/presentation/widgets/challenge/challenge_bottom_actions.dart';
import 'package:algoquest/presentation/widgets/challenge/challenge_progress_bar.dart';
import 'package:algoquest/presentation/widgets/challenge/challenge_question_card.dart';
import 'package:algoquest/presentation/widgets/challenge/challenge_top_header.dart';
import 'package:algoquest/presentation/widgets/shared/mascot_message_card.dart';
import 'package:flutter/material.dart';

class ChallengeScreenLayout extends StatelessWidget {
  final int currentChallengeNumber;
  final int totalChallenges;
  final int? heartsRemaining;
  final int? maxHearts;
  final int? movesRemaining;

  final String questionTitle;
  final String instruction;
  final String questionImageAssetPath;

  final Widget challengeBody;

  final String? tipTitle;
  final String? tipMessage;
  final String tipImageAssetPath;

  final VoidCallback onBack;
  final VoidCallback? onReset;
  final VoidCallback? onCheckAnswer;

  const ChallengeScreenLayout({
    super.key,
    required this.currentChallengeNumber,
    required this.totalChallenges,
    required this.instruction,
    required this.questionImageAssetPath,
    required this.challengeBody,
    required this.onBack,
    required this.onReset,
    required this.onCheckAnswer,
    this.heartsRemaining,
    this.maxHearts,
    this.movesRemaining,
    this.questionTitle = 'Pregunta',
    this.tipTitle,
    this.tipMessage,
    this.tipImageAssetPath = AppAssets.happyRaccoon,
  });

  @override
  Widget build(BuildContext context) {
    final hasTip =
        tipTitle != null &&
        tipTitle!.trim().isNotEmpty &&
        tipMessage != null &&
        tipMessage!.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFF6B3DEB),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6B3DEB), Color(0xFF4321A8)],
            begin: Alignment.topLeft,
            end: Alignment.topRight,
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              ChallengeTopHeader(
                currentChallengeNumber: currentChallengeNumber,
                totalChallenges: totalChallenges,
                heartsRemaining: heartsRemaining,
                maxHearts: maxHearts,
                movesRemaining: movesRemaining,
                onBack: onBack,
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F8FC),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 18,
                        offset: const Offset(0, -3),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                      child: Column(
                        children: [
                          ChallengeProgressBar(
                            currentStep: currentChallengeNumber,
                            totalSteps: totalChallenges,
                            height: 28,
                          ),
                          const SizedBox(height: 18),
                          ChallengeQuestionCard(
                            title: questionTitle,
                            instruction: instruction,
                            imageAssetPath: questionImageAssetPath,
                            imageScale: 3.5,
                          ),
                          const SizedBox(height: 24),
                          Expanded(child: challengeBody),
                          const SizedBox(height: 20),
                          _FinalActionsSection(
                            hasTip: hasTip,
                            tipImageAssetPath: tipImageAssetPath,
                            tipTitle: tipTitle,
                            tipMessage: tipMessage,
                            onReset: onReset,
                            onCheckAnswer: onCheckAnswer,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FinalActionsSection extends StatelessWidget {
  final bool hasTip;
  final String tipImageAssetPath;
  final String? tipTitle;
  final String? tipMessage;
  final VoidCallback? onReset;
  final VoidCallback? onCheckAnswer;

  const _FinalActionsSection({
    required this.hasTip,
    required this.tipImageAssetPath,
    required this.tipTitle,
    required this.tipMessage,
    required this.onReset,
    required this.onCheckAnswer,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (hasTip) ...[
          MascotMessageCard(
            imageAssetPath: tipImageAssetPath,
            title: tipTitle!,
            message: tipMessage!,
            imageBoxSize: 58,
            imageScale: 3.1,
            imageOffset: const Offset(-2, 0),
            spacing: 18,
            padding: const EdgeInsets.fromLTRB(10, 8, 14, 8),
            backgroundColor: const Color(0xFFF0E7FF),
            borderColor: const Color(0xFFE1D4FF),
            titleColor: const Color(0xFF101235),
            messageColor: const Color(0xFF101235),
          ),
          const SizedBox(height: 20),
        ],
        ChallengeBottomActions(onReset: onReset, onCheck: onCheckAnswer),
      ],
    );
  }
}
