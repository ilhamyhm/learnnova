import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../services/app_localizations.dart';

class PrivacySettingsScreen extends StatefulWidget {
  const PrivacySettingsScreen({super.key});

  @override
  State<PrivacySettingsScreen> createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen>
    with SingleTickerProviderStateMixin {
  // ── Data & Analytics ───────────────────────────────────────────────────────
  bool _analyticsData = true;
  bool _crashReports = true;
  bool _personalisedAds = false;
  bool _usageStatistics = true;

  // ── Profile Visibility ─────────────────────────────────────────────────────
  String _profileVisibility = 'Friends';
  bool _showProgress = true;
  bool _showBadges = true;
  bool _showInLeaderboard = true;

  // ── Security ───────────────────────────────────────────────────────────────
  bool _twoFactorAuth = false;
  bool _loginAlerts = true;
  bool _sessionManagement = false;

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildAppBar(context),
            SliverToBoxAdapter(child: _buildPrivacyBanner(context)),
            SliverToBoxAdapter(
                child: _buildSection(
                    '📊 ${context.tr('data_analytics')}', _dataItems(context), AppColors.moduleCodeLab)),
            SliverToBoxAdapter(
                child: _buildSection(
                    '👤 ${context.tr('profile_visibility')}', _visibilityItems(context), AppColors.moduleCreative)),
            SliverToBoxAdapter(
                child: _buildSection(
                    '🔐 ${context.tr('security')}', _securityItems(context), AppColors.success)),
            SliverToBoxAdapter(child: _buildDataActions(context)),
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 160,
      backgroundColor: AppColors.moduleAnimation,
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
        TextButton(
          onPressed: _savePrivacy,
          child: Text(context.tr('save'),
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 15)),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1A1D3A), Color(0xFF3A1A2E)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${context.tr('privacy_settings')} 🔒',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text(context.tr('you_control_data'),
                      style: const TextStyle(color: Colors.white70, fontSize: 13)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPrivacyBanner(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.success.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Text('🛡️', style: TextStyle(fontSize: 32)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('privacy_matters'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  context.tr('privacy_banner_desc'),
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 11, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> items, Color accentColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
          child: Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: items.asMap().entries.map((e) {
              return Column(
                children: [
                  e.value,
                  if (e.key < items.length - 1)
                    const Divider(
                        height: 1,
                        indent: 56,
                        endIndent: 16,
                        color: AppColors.divider),
                ],
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  List<Widget> _dataItems(BuildContext context) => [
        _privacyTile(
          emoji: '📈',
          title: context.tr('analytics_insights'),
          subtitle: context.tr('analytics_desc'),
          value: _analyticsData,
          onChanged: (v) => setState(() => _analyticsData = v),
        ),
        _privacyTile(
          emoji: '🐞',
          title: context.tr('crash_reports'),
          subtitle: context.tr('crash_desc'),
          value: _crashReports,
          onChanged: (v) => setState(() => _crashReports = v),
        ),
        _privacyTile(
          emoji: '🎯',
          title: context.tr('personalised_ads'),
          subtitle: context.tr('ads_desc'),
          value: _personalisedAds,
          onChanged: (v) => setState(() => _personalisedAds = v),
        ),
        _privacyTile(
          emoji: '📊',
          title: context.tr('usage_statistics'),
          subtitle: context.tr('usage_desc'),
          value: _usageStatistics,
          onChanged: (v) => setState(() => _usageStatistics = v),
        ),
      ];

  List<Widget> _visibilityItems(BuildContext context) => [
        _privacyTileWithDropdown(
          context: context,
          emoji: '🌐',
          title: context.tr('profile_visibility'),
          subtitle: context.tr('visibility_desc'),
          value: _profileVisibility,
          options: const ['Everyone', 'Friends', 'Only Me'],
          onChanged: (v) => setState(() => _profileVisibility = v!),
        ),
        _privacyTile(
          emoji: '📚',
          title: context.tr('show_progress'),
          subtitle: context.tr('show_progress_desc'),
          value: _showProgress,
          onChanged: (v) => setState(() => _showProgress = v),
        ),
        _privacyTile(
          emoji: '🏅',
          title: context.tr('show_badges'),
          subtitle: context.tr('show_badges_desc'),
          value: _showBadges,
          onChanged: (v) => setState(() => _showBadges = v),
        ),
        _privacyTile(
          emoji: '🏆',
          title: context.tr('appear_leaderboard'),
          subtitle: context.tr('leaderboard_desc'),
          value: _showInLeaderboard,
          onChanged: (v) => setState(() => _showInLeaderboard = v),
        ),
      ];

  List<Widget> _securityItems(BuildContext context) => [
        _privacyTile(
          emoji: '🔑',
          title: context.tr('two_factor'),
          subtitle: context.tr('two_factor_desc'),
          value: _twoFactorAuth,
          onChanged: (v) {
            setState(() => _twoFactorAuth = v);
            if (v) _show2FADialog();
          },
        ),
        _privacyTile(
          emoji: '🔔',
          title: context.tr('login_alerts'),
          subtitle: context.tr('login_alerts_desc'),
          value: _loginAlerts,
          onChanged: (v) => setState(() => _loginAlerts = v),
        ),
        _privacyTile(
          emoji: '📱',
          title: context.tr('active_sessions'),
          subtitle: context.tr('sessions_desc'),
          value: _sessionManagement,
          onChanged: (v) => setState(() => _sessionManagement = v),
        ),
      ];

  Widget _privacyTile({
    required String emoji,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool>? onChanged,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(emoji, style: const TextStyle(fontSize: 20)),
        ),
      ),
      title: Text(title,
          style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle,
          style:
              const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeThumbColor: AppColors.primary,
        activeTrackColor: AppColors.primaryLight,
      ),
    );
  }

  Widget _privacyTileWithDropdown({
    required BuildContext context,
    required String emoji,
    required String title,
    required String subtitle,
    required String value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(emoji, style: const TextStyle(fontSize: 20)),
        ),
      ),
      title: Text(title,
          style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle,
          style:
              const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
      trailing: DropdownButton<String>(
        value: value,
        underline: const SizedBox(),
        icon: const Icon(Icons.expand_more_rounded,
            color: AppColors.textHint, size: 18),
        style: const TextStyle(
            color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600),
        items: options
            .map((o) => DropdownMenuItem(
                  value: o,
                  child: Text(o == 'Everyone'
                      ? context.tr('everyone')
                      : o == 'Friends'
                          ? context.tr('friends')
                          : context.tr('only_me')),
                ))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildDataActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              context.tr('data_actions').toUpperCase(),
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                _actionTile(
                  icon: Icons.download_rounded,
                  color: AppColors.primary,
                  title: context.tr('download_data'),
                  subtitle: context.tr('download_data_desc'),
                  onTap: () => _showComingSoon(context.tr('data_export_coming')),
                ),
                const Divider(
                    height: 1, indent: 56, endIndent: 16, color: AppColors.divider),
                _actionTile(
                  icon: Icons.cleaning_services_rounded,
                  color: AppColors.accent,
                  title: context.tr('clear_history'),
                  subtitle: context.tr('clear_history_desc'),
                  onTap: () => _showClearDialog(),
                ),
                const Divider(
                    height: 1, indent: 56, endIndent: 16, color: AppColors.divider),
                _actionTile(
                  icon: Icons.delete_forever_rounded,
                  color: AppColors.error,
                  title: context.tr('delete_account'),
                  subtitle: context.tr('delete_account_desc'),
                  onTap: () => _showDeleteDialog(),
                  isDestructive: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionTile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(title,
          style: TextStyle(
              color: isDestructive ? AppColors.error : AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle,
          style:
              const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
      trailing: const Icon(Icons.chevron_right_rounded,
          color: AppColors.textHint, size: 20),
    );
  }

  void _show2FADialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Text('🔑 ', style: TextStyle(fontSize: 22)),
            Text(context.tr('enable_2fa')),
          ],
        ),
        content: Text(
          context.tr('two_factor_dialog_desc'),
          style: const TextStyle(color: AppColors.textSecondary, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _twoFactorAuth = false);
            },
            child: Text(context.tr('cancel'),
                style: const TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK',
                style: TextStyle(
                    color: AppColors.primary, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _showClearDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(context.tr('clear_history_confirm')),
        content: Text(
          context.tr('clear_history_warning'),
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.tr('cancel'),
                style: const TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(context.tr('history_cleared')),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
            child: Text(context.tr('clear'),
                style: const TextStyle(
                    color: AppColors.error, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Text('⚠️ ', style: TextStyle(fontSize: 22)),
            Text(context.tr('delete_account_confirm')),
          ],
        ),
        content: Text(
          context.tr('delete_account_warning'),
          style: const TextStyle(color: AppColors.textSecondary, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.tr('cancel'),
                style: const TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showComingSoon(context.tr('account_deletion_coming'));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(context.tr('delete'),
                style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🚧 $msg'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _savePrivacy() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(context.tr('privacy_saved')),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
    Navigator.pop(context);
  }
}
