import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../models/module_model.dart';
import '../../services/module_state_service.dart';
import '../home/category_detail_page.dart';
import '../home/sub_detail_page.dart';
import '../../services/app_localizations.dart';

class ExplorerScreen extends StatefulWidget {
  const ExplorerScreen({super.key});

  @override
  State<ExplorerScreen> createState() => _ExplorerScreenState();
}

class _ExplorerScreenState extends State<ExplorerScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'All';
  String _selectedDifficulty = 'All';

  final List<String> _categories = [
    'All', 'Programming', 'Design', 'Animation', 'Business', 'Languages', 'Academic', 'Creative', 'Sports & Fitness',
  ];

  final List<String> _difficulties = [
    'All', 'Beginner', 'Intermediate', 'Advanced',
  ];

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    await ModuleStateService.instance.refreshAll();
    if (mounted) setState(() {});
  }

  // Returns matching modules
  List<Module> get _filteredModules {
    final modules = ModuleStateService.instance.modules;
    return modules.where((m) {
      final matchesSearch = _searchQuery.isEmpty ||
          m.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          m.subModules.any(
            (s) => s.name.toLowerCase().contains(_searchQuery.toLowerCase()),
          );
      final matchesCategory = _selectedCategory == 'All' || m.category == _selectedCategory;
      // Difficulty filter is mostly for topics, but if it is selected,
      // we check if the module contains any submodules matching the difficulty.
      final matchesDifficulty = _selectedDifficulty == 'All' ||
          m.subModules.any((s) => s.difficulty.toLowerCase() == _selectedDifficulty.toLowerCase());

      return matchesSearch && matchesCategory && matchesDifficulty;
    }).toList();
  }

  // Returns matching topics (submodules) grouped with their parent module color
  List<({SubModule sub, Module parent})> get _filteredSubModules {
    final modules = ModuleStateService.instance.modules;
    final List<({SubModule sub, Module parent})> results = [];

    for (final m in modules) {
      // Category filter
      if (_selectedCategory != 'All' && m.category != _selectedCategory) {
        continue;
      }

      for (final s in m.subModules) {
        // Difficulty filter
        if (_selectedDifficulty != 'All' &&
            s.difficulty.toLowerCase() != _selectedDifficulty.toLowerCase()) {
          continue;
        }

        // Search query filter
        final matchesSearch = _searchQuery.isEmpty ||
            s.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            s.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            m.name.toLowerCase().contains(_searchQuery.toLowerCase());

        if (matchesSearch) {
          results.add((sub: s, parent: m));
        }
      }
    }
    return results;
  }

  List<SubModule> get _trendingSubModules {
    return ModuleStateService.instance.modules
        .expand((m) => m.subModules)
        .take(5)
        .toList();
  }

  bool get _isFiltering =>
      _searchQuery.isNotEmpty || _selectedCategory != 'All' || _selectedDifficulty != 'All';

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
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            _buildHeader(),
            SliverToBoxAdapter(child: _buildSearchBar()),
            SliverToBoxAdapter(child: _buildFiltersSection()),
            
            if (!_isFiltering) ...[
              SliverToBoxAdapter(
                child: _buildSectionTitle('⭐ ${context.tr('featured_courses')}', context.tr('editors_picks')),
              ),
              SliverToBoxAdapter(child: _buildFeaturedCourses()),
              SliverToBoxAdapter(child: _buildTrending()),
              SliverToBoxAdapter(
                child: _buildSectionTitle(context.tr('all_courses'), '${_filteredModules.length} ${context.tr('found')}'),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final module = _filteredModules[index];
                      return _buildModuleListCard(module);
                    },
                    childCount: _filteredModules.length,
                  ),
                ),
              ),
            ] else ...[
              // Active search/filter results view
              SliverToBoxAdapter(
                child: _buildSectionTitle(context.tr('matching_topics'), '${_filteredSubModules.length} ${context.tr('found')}'),
              ),
              if (_filteredSubModules.isEmpty)
                SliverToBoxAdapter(child: _buildEmptyState())
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final item = _filteredSubModules[index];
                        return _buildTopicListCard(item.sub, item.parent);
                      },
                      childCount: _filteredSubModules.length,
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 16,
          left: 20,
          right: 20,
          bottom: 16,
        ),
        decoration: const BoxDecoration(
          gradient: AppColors.heroGradient,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.tr('explorer_title'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '🔥 ${context.tr('trending')}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              context.tr('discover_next_adventure'),
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
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
            hintText: context.tr('search_modules_topics'),
            hintStyle: TextStyle(color: colors.textHint),
            prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.close_rounded, color: colors.textSecondary),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildFiltersSection() {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category filters
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Text(
            context.tr('category_filter').toUpperCase(),
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
          ),
        ),
        SizedBox(
          height: 38,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final cat = _categories[index];
              final isSelected = cat == _selectedCategory;
              return GestureDetector(
                onTap: () => setState(() => _selectedCategory = cat),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : colors.cardBg,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : colors.divider,
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      cat == 'All'
                          ? context.tr('all')
                          : context.tr('category_${cat.toLowerCase().replaceAll(' & ', '_').replaceAll(' ', '_')}'),
                      style: TextStyle(
                        color: isSelected ? Colors.white : colors.textSecondary,
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // Difficulty filters
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
          child: Text(
            context.tr('difficulty_filter').toUpperCase(),
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
          ),
        ),
        SizedBox(
          height: 38,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _difficulties.length,
            itemBuilder: (context, index) {
              final diff = _difficulties[index];
              final isSelected = diff == _selectedDifficulty;
              return GestureDetector(
                onTap: () => setState(() => _selectedDifficulty = diff),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.accent : colors.cardBg,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isSelected ? AppColors.accent : colors.divider,
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      diff == 'All'
                          ? context.tr('all')
                          : context.tr(diff.toLowerCase()),
                      style: TextStyle(
                        color: isSelected ? Colors.white : colors.textSecondary,
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedCourses() {
    final featured = ModuleStateService.instance.modules.take(3).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title built in the CustomScrollView list directly now
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: featured.length,
            itemBuilder: (context, index) {
              final module = featured[index];
              final color = Color(module.colorValue);
              return GestureDetector(
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => CategoryDetailPage(module: module)),
                  );
                  _loadProgress();
                },
                child: Container(
                  width: 260,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color, color.withValues(alpha: 0.7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.35),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -20,
                        bottom: -20,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(module.icon, style: const TextStyle(fontSize: 32)),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.25),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    context.tr('category_${module.category.toLowerCase().replaceAll(' & ', '_').replaceAll(' ', '_')}'),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Text(
                              module.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${module.subModules.length} ${context.tr('topics_count').toLowerCase()} • ⭐ 4.8',
                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                            const SizedBox(height: 10),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: module.overallProgress,
                                backgroundColor: Colors.white.withValues(alpha: 0.3),
                                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                minHeight: 5,
                              ),
                            ),
                          ],
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

  Widget _buildTrending() {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('🔥 ${context.tr('trending_now')}', context.tr('most_popular')),
        SizedBox(
          height: 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _trendingSubModules.length,
            itemBuilder: (context, index) {
              final sub = _trendingSubModules[index];
              return Container(
                width: 160,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: colors.cardBg,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(sub.icon, style: const TextStyle(fontSize: 22)),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: colors.accentLight,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '🔥 ${context.tr('hot')}',
                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.accentDark),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      sub.name,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${sub.totalLessons} ${context.tr('lessons')}',
                      style: TextStyle(color: colors.textSecondary, fontSize: 10),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildModuleListCard(Module module) {
    final colors = context.colors;
    final color = Color(module.colorValue);
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => CategoryDetailPage(module: module)),
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
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withValues(alpha: 0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(module.icon, style: const TextStyle(fontSize: 26)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        module.name,
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '⭐ 4.8',
                        style: TextStyle(
                          color: AppColors.accent,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${module.subModules.length} ${context.tr('topics_count').toLowerCase()} • ${context.tr('category_${module.category.toLowerCase().replaceAll(' & ', '_').replaceAll(' ', '_')}')}',
                    style: TextStyle(color: colors.textSecondary, fontSize: 11),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                           child: LinearProgressIndicator(
                            value: module.overallProgress,
                            backgroundColor: colors.surface,
                            valueColor: AlwaysStoppedAnimation<Color>(color),
                            minHeight: 4,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${(module.overallProgress * 100).toInt()}%',
                        style: TextStyle(
                          color: color,
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
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.arrow_forward_rounded, color: color, size: 18),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopicListCard(SubModule sub, Module parent) {
    final colors = context.colors;
    final parentColor = Color(parent.colorValue);

    // Completion Status text and colors
    String statusText = context.tr('not_started');
    Color statusColor = colors.textHint;
    Color statusBg = colors.surface;

    if (sub.isCompleted) {
      statusText = context.tr('completed');
      statusColor = AppColors.success;
      statusBg = colors.successLight;
    } else if (sub.allMaterialsCompleted) {
      statusText = context.tr('materials_completed');
      statusColor = AppColors.accent;
      statusBg = colors.accentLight;
    } else if (sub.progress > 0.0) {
      statusText = context.tr('in_progress');
      statusColor = AppColors.primary;
      statusBg = colors.primarySurface;
    }

    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SubDetailPage(subModule: sub, moduleColor: parentColor),
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
                  colors: [parentColor, parentColor.withValues(alpha: 0.75)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(sub.icon, style: const TextStyle(fontSize: 24)),
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
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: statusBg,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          statusText,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '${context.tr('course')}: ${parent.name}',
                        style: TextStyle(color: colors.textSecondary, fontSize: 11),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '•',
                        style: TextStyle(color: colors.textHint, fontSize: 11),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: colors.surface,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: colors.divider, width: 0.5),
                        ),
                        child: Text(
                          context.tr(sub.difficulty.toLowerCase()),
                          style: TextStyle(
                            color: sub.difficulty == 'Advanced'
                                ? Colors.red.shade400
                                : sub.difficulty == 'Intermediate'
                                    ? AppColors.primary
                                    : AppColors.success,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
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
                            valueColor: AlwaysStoppedAnimation<Color>(parentColor),
                            minHeight: 4,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${(sub.progress * 100).toInt()}%',
                        style: TextStyle(
                          color: parentColor,
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
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: parentColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.chevron_right_rounded, color: parentColor, size: 18),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.search_off_rounded, size: 60, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            Text(
              context.tr('no_topics_match'),
              style: TextStyle(color: colors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              context.tr('try_adjusting_filters'),
              style: TextStyle(color: colors.textSecondary, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, String subtitle) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (subtitle.isNotEmpty)
            Text(
              subtitle,
              style: TextStyle(color: colors.textSecondary, fontSize: 12),
            ),
        ],
      ),
    );
  }
}
