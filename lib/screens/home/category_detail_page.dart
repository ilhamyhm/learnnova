import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../models/module_model.dart';
import '../../services/user_progress_service.dart';
import '../quiz/quiz_screen.dart';
import 'sub_detail_page.dart';

/// Shows the list of submodules (topics) inside a module.
/// Displays per-topic progress loaded from persistent storage.
/// Shows a "Take Quiz" button unlocked when all topics are completed.
class CategoryDetailPage extends StatefulWidget {
  final Module module;

  const CategoryDetailPage({super.key, required this.module});

  @override
  State<CategoryDetailPage> createState() => _CategoryDetailPageState();
}

class _CategoryDetailPageState extends State<CategoryDetailPage> {
  final _progress = UserProgressService.instance;
  bool _quizPassed = false;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    for (final sub in widget.module.subModules) {
      final progress = await _progress.getMaterialProgress(sub.apiKey);
      sub.progress = progress;
      sub.isCompleted = progress >= 1.0;
    }
    final passed = await _progress.isQuizPassed(widget.module.apiKey);
    if (mounted) {
      setState(() => _quizPassed = passed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final color = Color(widget.module.colorValue);
    final allCompleted = widget.module.allSubModulesCompleted;

    return Scaffold(
      backgroundColor: colors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(context, color),
          SliverToBoxAdapter(child: _buildModuleInfo(context, color)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Topics',
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${widget.module.subModules.length} topics',
                      style: TextStyle(
                        color: color,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildSubModuleCard(
                  context,
                  widget.module.subModules[index],
                  color,
                  index,
                ),
                childCount: widget.module.subModules.length,
              ),
            ),
          ),
          // Quiz button at the bottom
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
            sliver: SliverToBoxAdapter(
              child: _buildQuizButton(context, color, allCompleted),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, Color color) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      floating: false,
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
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, color.withValues(alpha: 0.7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: -40,
                right: -40,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 80, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        Text(widget.module.icon,
                            style: const TextStyle(fontSize: 36)),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.module.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  widget.module.category,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModuleInfo(BuildContext context, Color color) {
    final colors = context.colors;
    final progress = widget.module.overallProgress;
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.cardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.module.description,
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 13,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _infoChip(
                  '📚 ${widget.module.subModules.length}', 'Topics', color),
              const SizedBox(width: 10),
              _infoChip(
                  '✅ ${widget.module.completedSubModules}',
                  'Done',
                  AppColors.success),
              const SizedBox(width: 10),
              _infoChip('⭐ 4.8', 'Rating', AppColors.accent),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Overall Progress',
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: context.colors.surface,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoChip(String value, String label, Color color) {
    final colors = context.colors;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(color: colors.textSecondary, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubModuleCard(
    BuildContext context,
    SubModule sub,
    Color moduleColor,
    int index,
  ) {
    final colors = context.colors;
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                SubDetailPage(subModule: sub, moduleColor: moduleColor),
          ),
        );
        _loadProgress();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.cardBg,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    moduleColor,
                    moduleColor.withValues(alpha: 0.7)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(sub.icon,
                    style: const TextStyle(fontSize: 24)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          sub.name,
                          style: TextStyle(
                            color: colors.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (sub.isCompleted)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: colors.successLight,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            '✓ Done',
                            style: TextStyle(
                              color: AppColors.success,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${sub.totalLessons} lessons',
                    style: TextStyle(
                        color: colors.textSecondary, fontSize: 11),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: sub.progress,
                            backgroundColor: colors.surface,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                moduleColor),
                            minHeight: 5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${(sub.progress * 100).toInt()}%',
                        style: TextStyle(
                          color: moduleColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: moduleColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.chevron_right_rounded,
                  color: moduleColor, size: 20),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizButton(BuildContext context, Color color, bool allCompleted) {
    final colors = context.colors;
    if (_quizPassed) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.successLight,
          borderRadius: BorderRadius.circular(18),
          border:
              Border.all(color: AppColors.success.withValues(alpha: 0.4)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.emoji_events_rounded,
                color: AppColors.success, size: 22),
            SizedBox(width: 10),
            Text(
              '🏆 Quiz Passed — Module Completed!',
              style: TextStyle(
                color: AppColors.success,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: allCompleted
            ? () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => QuizScreen(
                      module: widget.module,
                      moduleColor: color,
                    ),
                  ),
                );
                _loadProgress();
              }
            : null,
        icon: Icon(
          allCompleted
              ? Icons.quiz_rounded
              : Icons.lock_outline_rounded,
          size: 20,
        ),
        label: Text(
          allCompleted
              ? 'Take Module Quiz'
              : 'Complete all topics to unlock quiz',
          style: const TextStyle(
              fontSize: 15, fontWeight: FontWeight.w700),
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
    );
  }
}
