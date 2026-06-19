import 'package:algoquest/domain/entities/level_syllabus.dart';
import 'package:algoquest/presentation/theme/app_assets.dart';
import 'package:algoquest/presentation/widgets/level_intro/key_concept_card.dart';
import 'package:algoquest/presentation/widgets/shared/app_back_button.dart';
import 'package:algoquest/presentation/widgets/shared/mascot_message_card.dart';
import 'package:flutter/material.dart';

class LevelIntroView extends StatelessWidget {
  final LevelSyllabus syllabus;
  final VoidCallback onBack;
  final VoidCallback onStartPractice;

  const LevelIntroView({
    super.key,
    required this.syllabus,
    required this.onBack,
    required this.onStartPractice,
  });

  @override
  Widget build(BuildContext context) {
    final theory = syllabus.theory;

    final normalizedKeyPoints = _normalizeKeyPoints(
      theory?.keyPoints ?? const [],
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(26),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - 34,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppBackButton(
                          onPressed: onBack,
                          backgroundColor: const Color(0xFF6B3DEB),
                        ),
                        const SizedBox(height: 10),
                        _IntroHero(title: theory?.title ?? syllabus.title),
                        const SizedBox(height: 10),
                        _TopicChip(topicLabel: syllabus.title),
                        const SizedBox(height: 14),
                        _SpeechBubble(
                          content:
                              theory?.content ??
                              'Repasa el concepto principal antes de empezar la práctica.',
                        ),
                        if (normalizedKeyPoints.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          const _SectionTitle(title: 'Ideas clave'),
                          const SizedBox(height: 12),
                          _KeyConceptGrid(keyPoints: normalizedKeyPoints),
                        ],
                        const SizedBox(height: 14),
                        MascotMessageCard(
                          imageAssetPath: AppAssets.happyDinosaur,
                          title: '¡Tú puedes!',
                          message:
                              '¡Tienes ${syllabus.challenges.length} desafíos por delante para mejorar tus habilidades!',
                        ),
                        const SizedBox(height: 18),
                        _StartButton(onPressed: onStartPractice),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  List<_KeyConceptData> _normalizeKeyPoints(List<String> keyPoints) {
    final styles = [
      const _KeyConceptStyle(
        icon: Icons.account_tree_rounded,
        backgroundColor: Color(0xFFF5EDFF),
        borderColor: Color(0xFFD9C4FF),
        iconColor: Color(0xFF6B3DEB),
      ),
      const _KeyConceptStyle(
        icon: Icons.arrow_upward_rounded,
        backgroundColor: Color(0xFFEFF8FF),
        borderColor: Color(0xFFB8E2FF),
        iconColor: Color(0xFF39A7F2),
      ),
      const _KeyConceptStyle(
        icon: Icons.eco_rounded,
        backgroundColor: Color(0xFFFFF8E9),
        borderColor: Color(0xFFFFD996),
        iconColor: Color(0xFF43A047),
      ),
      const _KeyConceptStyle(
        icon: Icons.spa_rounded,
        backgroundColor: Color(0xFFF1FFF0),
        borderColor: Color(0xFFC7EEC2),
        iconColor: Color(0xFF43A047),
      ),
    ];

    return List.generate(keyPoints.length, (index) {
      final style = styles[index % styles.length];

      return _KeyConceptData(
        title: keyPoints[index],
        icon: style.icon,
        backgroundColor: style.backgroundColor,
        borderColor: style.borderColor,
        iconColor: style.iconColor,
      );
    });
  }
}

class _IntroHero extends StatelessWidget {
  static const String _subtitle = "¡Construyamos unas bases sólidas!";

  final String title;

  const _IntroHero({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF101235),
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    height: 0.96,
                    letterSpacing: -0.8,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  _subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Color(0xFF292B4A),
                    fontSize: 14,
                    fontWeight: FontWeight(350),
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 106,
          height: 106,
          child: Transform.translate(
            offset: const Offset(-35, 0),
            child: Transform.scale(
              scale: 3.5,
              child: Image.asset(AppAssets.wizard, fit: BoxFit.contain),
            ),
          ),
        ),
      ],
    );
  }
}

class _TopicChip extends StatelessWidget {
  final String topicLabel;

  const _TopicChip({required this.topicLabel});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFF0E7FF),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        'Tema: $topicLabel',
        style: const TextStyle(
          color: Color(0xFF6B3DEB),
          fontSize: 15.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _SpeechBubble extends StatelessWidget {
  final String content;

  const _SpeechBubble({required this.content});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SpeechBubbleTailPainter(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE0E4F0), width: 1.5),
        ),
        child: Text(
          content,
          style: const TextStyle(
            color: Color(0xFF101235),
            fontSize: 16,
            fontWeight: FontWeight.w600,
            height: 1.35,
          ),
        ),
      ),
    );
  }
}

class _SpeechBubbleTailPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = const Color(0xFFE0E4F0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final path = Path()
      ..moveTo(28, size.height - 1)
      ..lineTo(22, size.height + 14)
      ..lineTo(44, size.height - 1)
      ..close();

    canvas.drawPath(path, paint);
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    var star = Transform.scale(
      scale: 3,
      child: Image.asset(AppAssets.goldStars, width: 18, height: 18),
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        star,
        const SizedBox(width: 8),
        Transform.translate(
          offset: Offset(0, -2.5),
          child: Text(
            title,
            style: const TextStyle(
              color: Color(0xFF101235),
              fontSize: 18,
              fontWeight: FontWeight(635),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Transform.scale(scaleX: -1, child: star),
      ],
    );
  }
}

class _KeyConceptGrid extends StatelessWidget {
  final List<_KeyConceptData> keyPoints;

  const _KeyConceptGrid({required this.keyPoints});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: keyPoints.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: keyPoints.length == 1 ? 1 : 2,
        mainAxisExtent: 128,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemBuilder: (context, index) {
        final keyPoint = keyPoints[index];

        return KeyConceptCard(
          title: keyPoint.title,
          icon: keyPoint.icon,
          backgroundColor: keyPoint.backgroundColor,
          borderColor: keyPoint.borderColor,
          iconColor: keyPoint.iconColor,
        );
      },
    );
  }
}

class _StartButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _StartButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF6B3DEB),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 8,
          shadowColor: const Color(0xFF6B3DEB).withValues(alpha: 0.35),
        ),
        child: const FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '¡Vamos allá!',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
              ),
              SizedBox(width: 12),
              Icon(Icons.arrow_forward_rounded, size: 26),
            ],
          ),
        ),
      ),
    );
  }
}

class _KeyConceptData {
  final String title;
  final IconData icon;
  final Color backgroundColor;
  final Color borderColor;
  final Color iconColor;

  const _KeyConceptData({
    required this.title,
    required this.icon,
    required this.backgroundColor,
    required this.borderColor,
    required this.iconColor,
  });
}

class _KeyConceptStyle {
  final IconData icon;
  final Color backgroundColor;
  final Color borderColor;
  final Color iconColor;

  const _KeyConceptStyle({
    required this.icon,
    required this.backgroundColor,
    required this.borderColor,
    required this.iconColor,
  });
}
