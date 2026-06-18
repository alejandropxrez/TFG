import 'dart:math' as math;

import 'package:algoquest/domain/entities/level_syllabus.dart';
import 'package:algoquest/presentation/application_state/learning_path_provider.dart';
import 'package:algoquest/presentation/application_state/learning_path_state.dart';
import 'package:algoquest/presentation/router/app_router.dart';
import 'package:algoquest/presentation/theme/app_assets.dart';
import 'package:algoquest/presentation/widgets/learning_path/learning_path_bottom_navigation.dart';
import 'package:algoquest/presentation/widgets/learning_path/learning_path_header.dart';
import 'package:algoquest/presentation/widgets/learning_path/learning_path_level_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LearningPathScreen extends ConsumerStatefulWidget {
  const LearningPathScreen({super.key});

  @override
  ConsumerState<LearningPathScreen> createState() => _LearningPathScreenState();
}

class _LearningPathScreenState extends ConsumerState<LearningPathScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(learningPathProvider.notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(learningPathProvider);

    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: _LearningMapBackground()),
          SafeArea(
            child: switch (state.status) {
              LearningPathStatus.idle ||
              LearningPathStatus.loading => const _LearningPathLoadingView(),

              LearningPathStatus.failed => _LearningPathErrorView(
                message: state.errorMessage ?? 'Error loading learning path',
                onRetry: () => ref.read(learningPathProvider.notifier).load(),
              ),

              LearningPathStatus.loaded => _LearningPathLoadedView(
                state: state,
                onLevelPressed: (levelId) {
                  context.pushNamed(
                    AppRouter.levelName,
                    pathParameters: {'levelId': levelId},
                  );
                },
              ),
            },
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: LearningPathBottomNav(
                selectedItem: LearningPathBottomNavItem.map,
                onItemSelected: (item) {
                  // No navigation yet.
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LearningMapBackground extends StatelessWidget {
  const _LearningMapBackground();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      AppAssets.background,
      fit: BoxFit.fill,
      alignment: Alignment.topCenter,
    );
  }
}

class _LearningPathLoadedView extends StatefulWidget {
  final LearningPathState state;
  final void Function(String levelId) onLevelPressed;

  const _LearningPathLoadedView({
    required this.state,
    required this.onLevelPressed,
  });

  @override
  State<_LearningPathLoadedView> createState() =>
      _LearningPathLoadedViewState();
}

class _LearningPathLoadedViewState extends State<_LearningPathLoadedView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final levels = [for (final phase in widget.state.phases) ...phase.levels];

    return LayoutBuilder(
      builder: (context, constraints) {
        final curveAmplitude = (constraints.maxWidth * 0.08).clamp(16.0, 28.0);

        return RawScrollbar(
          controller: _scrollController,
          thumbVisibility: false,
          thickness: 6,
          radius: const Radius.circular(999),
          thumbColor: Colors.white.withValues(alpha: 0.82),
          minThumbLength: 48,
          fadeDuration: const Duration(milliseconds: 450),
          timeToFade: const Duration(milliseconds: 900),
          interactive: true,
          child: CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
                sliver: SliverToBoxAdapter(
                  child: LearningPathHeader(
                    title: widget.state.title ?? 'AlgoQuest',
                    xp: 1250,
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(18, 42, 18, 32),
                sliver: SliverList.builder(
                  itemCount: levels.length,
                  itemBuilder: (context, index) {
                    final level = levels[index];

                    return LayoutBuilder(
                      builder: (context, itemConstraints) {
                        const edgeGap = 16.0;

                        final rawOffset = _horizontalOffsetForIndex(
                          index,
                          curveAmplitude,
                        );

                        // How sharp the curve is
                        final maxSafeOffset = (itemConstraints.maxWidth * 0.06)
                            .clamp(0.0, 22.0);

                        final safeOffset = rawOffset.clamp(
                          -maxSafeOffset,
                          maxSafeOffset,
                        );

                        return Padding(
                          padding: EdgeInsets.only(
                            left: edgeGap,
                            right: edgeGap,
                            top: index == 0 ? 0 : 12,
                            bottom: 10,
                          ),
                          child: Transform.translate(
                            offset: Offset(safeOffset, 0),
                            child: LearningPathLevelCard(
                              number: index + 1,
                              title: level.title,
                              subtitle: level.subtitle,
                              xp: _levelXp(level),
                              status: level.locked
                                  ? LearningPathLevelCardStatus.locked
                                  : LearningPathLevelCardStatus.available,
                              imageAssetPath: _levelImageForTopic(level.topic),
                              onPressed: level.locked
                                  ? null
                                  : () => widget.onLevelPressed(level.id),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  double _horizontalOffsetForIndex(int index, double amplitude) {
    return math.sin(index * 0.9) * amplitude;
  }

  int _levelXp(LearningPathLevelItem level) {
    return switch (level.topic) {
      LevelTopic.heaps => 100,
      LevelTopic.lists => 120,
      LevelTopic.bst => 150,
      LevelTopic.mixed => 180,
    };
  }

  String _levelImageForTopic(LevelTopic topic) {
    return switch (topic) {
      LevelTopic.heaps => AppAssets.tree,
      LevelTopic.lists => AppAssets.hat,
      LevelTopic.bst => AppAssets.chest,
      LevelTopic.mixed => AppAssets.cave,
    };
  }
}

class _LearningPathLoadingView extends StatelessWidget {
  const _LearningPathLoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: Color(0xFF6B3DEB)),
    );
  }
}

class _LearningPathErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _LearningPathErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 18,
                offset: const Offset(0, 9),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: Color(0xFFE53935),
                size: 44,
              ),
              const SizedBox(height: 12),
              const Text(
                'No se pudo cargar el mapa',
                style: TextStyle(
                  color: Color(0xFF101235),
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF4B4E66), fontSize: 14),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: onRetry,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF6B3DEB),
                ),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
