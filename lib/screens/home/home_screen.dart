import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../models/module_model.dart';
import '../../services/module_state_service.dart';
import '../../services/streak_service.dart';
import '../../widgets/category_item.dart';
import '../home/category_detail_page.dart';
import '../settings/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _streak = 0;

  List<Module> get _modules => ModuleStateService.instance.modules;

  List<Module> get _filteredModules {
    if (_searchQuery.isEmpty) return _modules;
    return _modules
        .where(
          (m) =>
              m.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              m.category.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();
  }

  List<Module> get _continueModules => _modules
      .where((m) => m.overallProgress > 0 && m.overallProgress < 1)
      .take(4)
      .toList();

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    await ModuleStateService.instance.refreshAll();
    final streak = await StreakService.instance.getStreak();
    if (mounted) setState(() => _streak = streak);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.background,
      body: RefreshIndicator(
        onRefresh: _loadProgress,
        color: AppColors.primary,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildHeader(context),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildSearchBar(context),
              ),
            ),
            SliverToBoxAdapter(child: _buildStatsRow()),
            if (_continueModules.isNotEmpty)
              SliverToBoxAdapter(child: _buildContinueLearning(context)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'All Modules',
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '${_modules.length} courses',
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final module = _filteredModules[index];
                    return CategoryItem(
                      module: module,
                      onTap: () => _openModule(context, module),
                    );
                  },
                  childCount: _filteredModules.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 180,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.primary,
      elevation: 0,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(gradient: AppColors.heroGradient),
          child: Stack(
            children: [
              Positioned(
                top: -30,
                right: -30,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                bottom: -20,
                left: -20,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [AppColors.primary, AppColors.accent],
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Center(
                                  child: Text('📚', style: TextStyle(fontSize: 18)),
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                'LearnNova',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const ProfileScreen()),
                            ),
                            child: Stack(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [AppColors.primary, AppColors.primaryDark],
                                    ),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2),
                                  ),
                                  child: const Center(
                                    child: Text('👤', style: TextStyle(fontSize: 20)),
                                  ),
                                ),
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: AppColors.success,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: Colors.white, width: 1.5),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Good Morning! 👋',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Learn Smarter, Grow Faster',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
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

  Widget _buildSearchBar(BuildContext context) {
    final colors = context.colors;
    return Container(
      margin: const EdgeInsets.only(top: 16, bottom: 8),
      decoration: BoxDecoration(
        color: colors.cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (v) => setState(() => _searchQuery = v),
        style: TextStyle(color: colors.textPrimary, fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Search modules, courses...',
          hintStyle: TextStyle(color: colors.textHint, fontSize: 14),
          prefixIcon: const Icon(Icons.search_rounded,
              color: AppColors.primary, size: 22),
          suffixIcon: _searchQuery.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                  child: Icon(Icons.close_rounded,
                      color: colors.textSecondary, size: 20),
                )
              : null,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    final colors = context.colors;
    final totalCompleted = _modules
        .expand((m) => m.subModules)
        .where((s) => s.isCompleted)
        .length;
    final totalSubModules = _modules.expand((m) => m.subModules).length;
    final completedModules = _modules
        .where((m) => m.allSubModulesCompleted)
        .length;
    final totalModules = _modules.length;
    final overallProgress = _modules.isEmpty
        ? 0.0
        : _modules
                .map((m) => m.overallProgress)
                .reduce((a, b) => a + b) /
            _modules.length;
    final progressPct = (overallProgress * 100).toInt();

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: colors.cardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 18,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          _statRow(
            context: context,
            icon: Icons.donut_large_rounded,
            iconColor: AppColors.primary,
            label: 'Overall Progress',
            value: '$progressPct%',
            extra: _progressBar(progressPct / 100, AppColors.primary, colors),
          ),
          _statDivider(colors),
          _statRow(
            context: context,
            icon: Icons.menu_book_rounded,
            iconColor: AppColors.moduleLanguage,
            label: 'Lessons Completed',
            value: '$totalCompleted of $totalSubModules',
          ),
          _statDivider(colors),
          _statRow(
            context: context,
            icon: Icons.layers_rounded,
            iconColor: AppColors.accent,
            label: 'Modules Completed',
            value: '$completedModules of $totalModules',
          ),
          _statDivider(colors),
          _statRow(
            context: context,
            icon: Icons.local_fire_department_rounded,
            iconColor: const Color(0xFFFF6B35),
            label: 'Learning Streak',
            value: '$_streak ${_streak == 1 ? 'Day' : 'Days'}${_streak > 0 ? ' 🔥' : ''}',
          ),
        ],
      ),
    );
  }

  Widget _statRow({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    Widget? extra,
  }) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          if (extra != null) ...[const SizedBox(height: 8), extra],
        ],
      ),
    );
  }

  Widget _progressBar(double value, Color color, dynamic colors) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: LinearProgressIndicator(
        value: value,
        minHeight: 5,
        backgroundColor: colors.surface as Color,
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }

  Widget _statDivider(dynamic colors) => Divider(
        height: 1,
        color: (colors.divider as Color).withValues(alpha: 0.6),
      );

  Widget _buildContinueLearning(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 14),
          child: Text(
            'Continue Learning 🔥',
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        SizedBox(
          height: 130,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _continueModules.length,
            itemBuilder: (context, index) {
              final module = _continueModules[index];
              final color = Color(module.colorValue);
              return GestureDetector(
                onTap: () => _openModule(context, module),
                child: Container(
                  width: 220,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colors.cardBg,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.12),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  color,
                                  color.withValues(alpha: 0.7)
                                ],
                              ),
                              borderRadius: BorderRadius.circular(11),
                            ),
                            child: Center(
                              child: Text(module.icon,
                                  style: const TextStyle(fontSize: 18)),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  module.name,
                                  style: TextStyle(
                                    color: colors.textPrimary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  module.category,
                                  style: TextStyle(
                                    color: colors.textSecondary,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${(module.overallProgress * 100).toInt()}% done',
                            style: TextStyle(
                              color: color,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            '${module.completedSubModules}/${module.subModules.length}',
                            style: TextStyle(
                              color: colors.textSecondary,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: module.overallProgress,
                          backgroundColor: colors.surface,
                          valueColor: AlwaysStoppedAnimation<Color>(color),
                          minHeight: 5,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _openModule(BuildContext context, Module module) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => CategoryDetailPage(module: module)),
    );
    _loadProgress();
  }
}
