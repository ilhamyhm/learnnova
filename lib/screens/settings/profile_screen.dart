import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../services/firebase_auth_service.dart';
import '../../services/module_state_service.dart';
import '../../services/streak_service.dart';
import '../../services/app_localizations.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _streak = 0;
  bool _isLoading = true;

  User? get _user => FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    try {
      await ModuleStateService.instance.refreshAll();
      final streak = await StreakService.instance.getStreak();
      if (mounted) {
        setState(() {
          _streak = streak;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _logout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(context.tr('logout_question')),
        content: Text(
          context.tr('logout_confirm'),
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.tr('cancel'), style: const TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.tr('logout'), style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      if (context.mounted) Navigator.of(context).popUntil((r) => r.isFirst);
      await FirebaseAuthService().signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final modules = ModuleStateService.instance.modules;

    // Completed SubModules (Topics) where isCompleted = true
    final completedSubModules = modules.expand((m) => m.subModules).where((s) => s.isCompleted).length;
    final totalSubModules = modules.expand((m) => m.subModules).length;

    // Completed Modules (top-level modules) where all submodules are completed
    final completedModules = modules.where((m) => m.allSubModulesCompleted).length;
    final totalModules = modules.length;

    // Completed lessons (materials) across all modules
    final completedLessons = modules.expand((m) => m.subModules).map((s) => s.completedLessons).fold(0, (a, b) => a + b);
    final totalLessons = modules.expand((m) => m.subModules).map((s) => s.totalLessons).fold(0, (a, b) => a + b);

    // Quiz Stats
    final quizSubmodules = modules.expand((m) => m.subModules).toList();
    final attemptedQuizzes = quizSubmodules.where((s) => s.quizScore > 0.0).toList();
    final avgQuizScore = attemptedQuizzes.isEmpty
        ? 0.0
        : attemptedQuizzes.map((s) => s.quizScore).reduce((a, b) => a + b) / attemptedQuizzes.length;
    final passedQuizzes = quizSubmodules.where((s) => s.isQuizPassed).length;

    return Scaffold(
      backgroundColor: colors.background,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadStats,
              color: AppColors.primary,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  _buildAppBar(context),
                  SliverToBoxAdapter(child: _buildAvatarSection()),
                  SliverToBoxAdapter(
                    child: _buildStatsSection(
                      completedModules: completedModules,
                      totalModules: totalModules,
                      completedLessons: completedLessons,
                      totalLessons: totalLessons,
                      completedSubModules: completedSubModules,
                      totalSubModules: totalSubModules,
                      avgQuizScore: avgQuizScore,
                      passedQuizzes: passedQuizzes,
                    ),
                  ),
                  SliverToBoxAdapter(child: _buildInfoCard()),
                  SliverToBoxAdapter(child: _buildLevelCard(completedSubModules, totalSubModules)),
                  SliverToBoxAdapter(child: _buildActionButtons(context)),
                  const SliverToBoxAdapter(child: SizedBox(height: 40)),
                ],
              ),
            ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      backgroundColor: AppColors.primary,
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
          decoration: const BoxDecoration(gradient: AppColors.heroGradient),
          child: Stack(
            children: [
              Positioned(
                top: -50,
                right: -50,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                bottom: -30,
                left: -30,
                child: Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        children: [
                          Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.5),
                                  blurRadius: 20,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(45),
                              child: _user?.photoURL != null
                                  ? Image.network(
                                      _user!.photoURL!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Image.asset(
                                        'lib/logo/logo.jpeg',
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Image.asset(
                                      'lib/logo/logo.jpeg',
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),
                          Positioned(
                            right: 4,
                            bottom: 4,
                            child: Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: AppColors.success,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _user?.displayName ?? 'LearnNova User',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _user?.email ?? '',
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.workspace_premium_rounded, color: Colors.amber, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('pro_learner'),
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  context.tr('intermediate_level'),
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              '⭐ Level 7',
              style: TextStyle(color: Colors.amber, fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection({
    required int completedModules,
    required int totalModules,
    required int completedLessons,
    required int totalLessons,
    required int completedSubModules,
    required int totalSubModules,
    required double avgQuizScore,
    required int passedQuizzes,
  }) {
    final colors = context.colors;
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.cardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              _profileStat('$completedModules/$totalModules', context.tr('modules'), AppColors.primary),
              _vertDiv(),
              _profileStat('$completedLessons/$totalLessons', context.tr('lessons'), AppColors.success),
              _vertDiv(),
              _profileStat('🔥 $_streak', context.tr('day_streak_title'), AppColors.error),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 16),
          Row(
            children: [
              _profileStat('${avgQuizScore.toInt()}%', context.tr('avg_score_short'), AppColors.accent),
              _vertDiv(),
              _profileStat('$passedQuizzes', context.tr('quizzes_passed'), AppColors.moduleLanguage),
              _vertDiv(),
              _profileStat('$completedSubModules/$totalSubModules', context.tr('topics_done'), AppColors.moduleCodeLab),
            ],
          ),
        ],
      ),
    );
  }

  Widget _profileStat(String value, String label, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 10),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _vertDiv() {
    return Container(width: 1, height: 32, color: AppColors.divider);
  }

  Widget _buildInfoCard() {
    final colors = context.colors;
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.cardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr('personal_information'),
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          _infoRow(Icons.person_rounded, context.tr('full_name'), _user?.displayName ?? 'LearnNova User'),
          const Divider(height: 20, color: AppColors.divider),
          _infoRow(Icons.email_rounded, context.tr('email'), _user?.email ?? '—'),
          const Divider(height: 20, color: AppColors.divider),
          _infoRow(Icons.phone_rounded, context.tr('phone'), '+62 812 3456 7890'),
          const Divider(height: 20, color: AppColors.divider),
          _infoRow(Icons.location_on_rounded, context.tr('location'), 'Jakarta, Indonesia'),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.primarySurface,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 18),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: AppColors.textHint, fontSize: 10),
            ),
            Text(
              value,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLevelCard(int completed, int total) {
    final double levelProgress = total == 0 ? 0.0 : completed / total;
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.accent, AppColors.accentDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🏅', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              Text(
                context.tr('learning_level'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                '${completed} / ${total} ${context.tr('topics_done').toLowerCase()}',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: levelProgress,
              backgroundColor: Colors.white.withValues(alpha: 0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.tr('level_progress_desc').replaceAll('{pct}', '${(levelProgress * 100).toInt()}'),
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        children: [
          ElevatedButton.icon(
            onPressed: () async {
              final updated = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditProfileScreen()),
              );
              if (updated == true) {
                _loadStats();
              }
            },
            icon: const Icon(Icons.edit_rounded, size: 18),
            label: Text(context.tr('edit_profile'), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout_rounded, size: 18, color: AppColors.error),
            label: Text(
              context.tr('logout'),
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.error),
            ),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 52),
              side: BorderSide(color: AppColors.error.withValues(alpha: 0.4), width: 1.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ],
      ),
    );
  }
}
