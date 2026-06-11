import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../constants/app_colors.dart';
import '../../models/material_model.dart';
import '../../models/module_model.dart';
import '../../services/api_service.dart';
import '../../services/user_progress_service.dart';

/// Displays learning slides for a submodule.
/// Loads materials dynamically from the API, supports Next/Previous navigation,
/// and automatically tracks slide completion progress.
class MaterialScreen extends StatefulWidget {
  final SubModule subModule;
  final Color moduleColor;

  const MaterialScreen({
    super.key,
    required this.subModule,
    required this.moduleColor,
  });

  @override
  State<MaterialScreen> createState() => _MaterialScreenState();
}

class _MaterialScreenState extends State<MaterialScreen> {
  final ApiService _api = ApiService();
  final _progress = UserProgressService.instance;

  ModuleMaterialsResponse? _data;
  bool _isLoading = true;
  String? _error;

  int _currentIndex = 0;
  Set<int> _viewedIds = {};

  @override
  void initState() {
    super.initState();
    _loadMaterials();
  }

  Future<void> _loadMaterials() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await _api.fetchMaterials(widget.subModule.apiKey);
      final viewed = await _progress.getViewedSlides(widget.subModule.apiKey);
      if (!mounted) return;
      setState(() {
        _data = data;
        _viewedIds = viewed;
        _isLoading = false;
      });
      // Mark first slide as viewed automatically
      if (data.materials.isNotEmpty) {
        _markCurrentSlideViewed();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load materials. Please try again.';
        _isLoading = false;
      });
    }
  }

  Future<void> _markCurrentSlideViewed() async {
    final materials = _data?.materials;
    if (materials == null || _currentIndex >= materials.length) return;
    final slide = materials[_currentIndex];
    if (!_viewedIds.contains(slide.materialId)) {
      await _progress.markSlideViewed(widget.subModule.apiKey, slide.materialId);
      final newViewed = Set<int>.from(_viewedIds)..add(slide.materialId);
      await _progress.updateMaterialProgress(
        widget.subModule.apiKey,
        newViewed.length,
        materials.length,
      );
      if (!mounted) return;
      setState(() => _viewedIds = newViewed);
      // Update subModule progress in memory
      widget.subModule.progress =
          (newViewed.length / materials.length).clamp(0.0, 1.0);
      if (newViewed.length >= materials.length) {
        widget.subModule.isCompleted = true;
      }
    }
  }

  void _goNext() {
    if (_data == null) return;
    if (_currentIndex < _data!.materials.length - 1) {
      setState(() => _currentIndex++);
      _markCurrentSlideViewed();
    }
  }

  void _goPrev() {
    if (_currentIndex > 0) {
      setState(() => _currentIndex--);
      _markCurrentSlideViewed();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final color = widget.moduleColor;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: _buildAppBar(color),
      body: _isLoading
          ? _buildLoading(color)
          : _error != null
              ? _buildError(context)
              : _buildContent(context, color),
    );
  }

  AppBar _buildAppBar(Color color) {
    return AppBar(
      backgroundColor: color,
      elevation: 0,
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
      title: Text(
        widget.subModule.name,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 17,
          fontWeight: FontWeight.w700,
        ),
      ),
      actions: [
        if (_data != null)
          Center(
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${_viewedIds.length}/${_data!.materials.length} viewed',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLoading(Color color) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading materials...',
            style: TextStyle(color: context.colors.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context) {
    final colors = context.colors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_rounded, size: 64, color: colors.textHint),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: TextStyle(color: colors.textSecondary, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _loadMaterials,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, Color color) {
    final colors = context.colors;
    final materials = _data!.materials;
    final slide = materials[_currentIndex];
    final isViewed = _viewedIds.contains(slide.materialId);
    final totalProgress =
        _data!.totalSlide > 0 ? (_currentIndex + 1) / _data!.totalSlide : 0.0;

    return Column(
      children: [
        // ── Header Info ──────────────────────────────────────────────────
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, color.withValues(alpha: 0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Level badge + objectives
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _data!.level.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _data!.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '🎯 ${_data!.tujuanPembelajaran}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              // Overall progress bar
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: totalProgress,
                        backgroundColor: Colors.white.withValues(alpha: 0.3),
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(Colors.white),
                        minHeight: 6,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Slide ${_currentIndex + 1} of ${materials.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // ── Slide Content ────────────────────────────────────────────────
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Slide title + viewed badge
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        slide.title,
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          height: 1.3,
                        ),
                      ),
                    ),
                    if (isViewed)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: colors.successLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle_rounded,
                                color: AppColors.success, size: 12),
                            SizedBox(width: 4),
                            Text(
                              'Viewed',
                              style: TextStyle(
                                  color: AppColors.success,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                // Content
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: colors.cardBg,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Text(
                    slide.content,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 14,
                      height: 1.7,
                    ),
                  ),
                ),

                // Example code block
                if (slide.example != null && slide.example!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildCodeBlock(slide.example!, color),
                ],

                const SizedBox(height: 100),
              ],
            ),
          ),
        ),

        // ── Navigation Buttons ───────────────────────────────────────────
        _buildNavBar(context, color, materials.length),
      ],
    );
  }

  Widget _buildCodeBlock(String code, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: const BoxDecoration(
                color: Color(0xFF1E1E2E),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
              child: const Row(
                children: [
                  Icon(Icons.code_rounded, color: Color(0xFF89DCEB), size: 14),
                  SizedBox(width: 6),
                  Text(
                    'Example Code',
                    style: TextStyle(
                      color: Color(0xFF89DCEB),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: code));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Code copied to clipboard!'),
                    backgroundColor: color,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.copy_rounded, color: color, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      'Copy',
                      style: TextStyle(
                        color: color,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Color(0xFF1E1E2E),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(12),
              bottomRight: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Text(
              code,
              style: const TextStyle(
                color: Color(0xFFCDD6F4),
                fontSize: 12.5,
                fontFamily: 'monospace',
                height: 1.6,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavBar(BuildContext context, Color color, int total) {
    final colors = context.colors;
    final isFirst = _currentIndex == 0;
    final isLast = _currentIndex == total - 1;
    final allViewed = _data != null &&
        _viewedIds.length >= _data!.materials.length;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      decoration: BoxDecoration(
        color: colors.cardBg,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Previous button
          if (!isFirst)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _goPrev,
                icon: const Icon(Icons.arrow_back_rounded, size: 18),
                label: const Text('Previous'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: color,
                  side: BorderSide(color: color.withValues(alpha: 0.4)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          if (!isFirst) const SizedBox(width: 12),

          // Next / Finish button
          Expanded(
            child: ElevatedButton.icon(
              onPressed: isLast
                  ? (allViewed
                      ? () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  const Text('🎉 All materials completed!'),
                              backgroundColor: AppColors.success,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                          );
                        }
                      : null)
                  : _goNext,
              icon: Icon(
                isLast ? Icons.check_circle_rounded : Icons.arrow_forward_rounded,
                size: 18,
              ),
              label: Text(isLast ? 'Finish' : 'Next'),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                disabledBackgroundColor: colors.surface,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
