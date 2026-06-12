import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../models/module_model.dart';
import '../../services/user_progress_service.dart';
import '../material/material_screen.dart';
import '../quiz/quiz_screen.dart';

/// Shows details about a specific submodule (topic) and lets the user
/// open the MaterialScreen to read learning slides.
class SubDetailPage extends StatefulWidget {
  final SubModule subModule;
  final Color moduleColor;

  const SubDetailPage({
    super.key,
    required this.subModule,
    required this.moduleColor,
  });

  @override
  State<SubDetailPage> createState() => _SubDetailPageState();
}

class _SubDetailPageState extends State<SubDetailPage> {
  final _progress = UserProgressService.instance;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final progress = await _progress.getMaterialProgress(widget.subModule.apiKey);
    final passed = await _progress.isQuizPassed(widget.subModule.apiKey);
    final score = await _progress.getQuizScore(widget.subModule.apiKey) ?? 0.0;
    if (mounted) {
      setState(() {
        widget.subModule.progress = progress;
        widget.subModule.isQuizPassed = passed;
        widget.subModule.quizScore = score;
        widget.subModule.isCompleted =
            widget.subModule.allMaterialsCompleted && widget.subModule.isQuizPassed;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final color = widget.moduleColor;
    final sub = widget.subModule;

    return Scaffold(
      backgroundColor: colors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(context, color, sub),
          SliverToBoxAdapter(child: _buildHeroSection(color, sub)),
          SliverToBoxAdapter(child: _buildProgressSection(context, color, sub)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Learning Path',
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    '${sub.completedLessons}/${sub.totalLessons} done',
                    style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) => _buildLessonItem(context, i, color, sub),
                childCount: sub.totalLessons,
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(context, color, sub),
    );
  }

  Widget _buildAppBar(BuildContext context, Color color, SubModule sub) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: color,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.arrow_back_rounded, color: Colors.white),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: IconButton(
            icon: const Icon(Icons.bookmark_border_rounded,
                color: Colors.white, size: 20),
            onPressed: () {},
            padding: EdgeInsets.zero,
          ),
        ),
      ],
      title: Text(
        sub.name,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildHeroSection(Color color, SubModule sub) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withValues(alpha: 0.75)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(sub.icon, style: const TextStyle(fontSize: 40)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sub.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.menu_book_rounded,
                                color: Colors.white70, size: 13),
                            const SizedBox(width: 4),
                            Text(
                              '${sub.totalLessons} lessons',
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                sub.description,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _heroChip('⭐ 4.9'),
                  const SizedBox(width: 8),
                  _heroChip('🏆 Certificate'),
                  const SizedBox(width: 8),
                  _heroChip('🔰 Beginner'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: const TextStyle(
            color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildProgressSection(BuildContext context, Color color, SubModule sub) {
    final colors = context.colors;
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.cardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Your Progress',
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                sub.progress == 0.0
                    ? 'Not Started'
                    : '${(sub.progress * 100).toInt()}%',
                style: TextStyle(
                  color: sub.progress == 0.0 ? colors.textHint : color,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: sub.progress,
              backgroundColor: colors.surface,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${sub.completedLessons} of ${sub.totalLessons} lessons completed',
                style: TextStyle(color: colors.textSecondary, fontSize: 12),
              ),
              if (sub.isCompleted)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: colors.successLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '🏆 Topic Completed!',
                    style: TextStyle(
                        color: AppColors.success,
                        fontSize: 11,
                        fontWeight: FontWeight.w700),
                  ),
                )
              else if (sub.allMaterialsCompleted)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: colors.accentLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '📖 Materials Completed',
                    style: TextStyle(
                        color: AppColors.accent,
                        fontSize: 11,
                        fontWeight: FontWeight.w700),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLessonItem(BuildContext context, int index, Color color, SubModule sub) {
    final colors = context.colors;
    final isDone = index < sub.completedLessons;
    final lessonNum = index + 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDone ? color.withValues(alpha: 0.06) : colors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDone ? color.withValues(alpha: 0.3) : colors.divider,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isDone ? color : colors.surface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: isDone
                  ? const Icon(Icons.check_rounded,
                      color: Colors.white, size: 18)
                  : Text(
                      '$lessonNum',
                      style: TextStyle(
                        color: color,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lesson $lessonNum',
                  style: TextStyle(
                    color: isDone
                        ? colors.textSecondary
                        : colors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    decoration:
                        isDone ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isDone ? 'Completed ✓' : '~15 min',
                  style: TextStyle(
                    color:
                        isDone ? AppColors.success : colors.textHint,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            isDone
                ? Icons.replay_rounded
                : Icons.play_circle_filled_rounded,
            color: isDone ? colors.textHint : color,
            size: 26,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(
      BuildContext context, Color color, SubModule sub) {
    final colors = context.colors;
    final allMaterialsDone = sub.allMaterialsCompleted;
    final quizPassed = sub.isQuizPassed;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
      decoration: BoxDecoration(
        color: colors.cardBg,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (quizPassed)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.successLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.success.withValues(alpha: 0.4)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.emoji_events_rounded, color: AppColors.success, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Quiz Passed: ${(sub.quizScore * 100).toInt()}%',
                    style: const TextStyle(
                      color: AppColors.success,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MaterialScreen(
                          subModule: sub,
                          moduleColor: color,
                        ),
                      ),
                    );
                    _loadProgress();
                  },
                  icon: Icon(
                    allMaterialsDone
                        ? Icons.menu_book_rounded
                        : Icons.play_arrow_rounded,
                    size: 20,
                  ),
                  label: Text(
                    allMaterialsDone ? 'Review Materials' : 'Start Learning',
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.surface,
                    foregroundColor: color,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: allMaterialsDone
                      ? () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => QuizScreen(
                                module: null,
                                subModule: sub,
                                moduleColor: color,
                              ),
                            ),
                          );
                          _loadProgress();
                        }
                      : null,
                  icon: Icon(
                    allMaterialsDone ? Icons.quiz_rounded : Icons.lock_outline_rounded,
                    size: 20,
                  ),
                  label: Text(
                    quizPassed ? 'Retake Quiz' : 'Take Quiz',
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: colors.surface,
                    disabledForegroundColor: colors.textHint,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
