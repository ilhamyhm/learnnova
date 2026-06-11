import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

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
            SliverToBoxAdapter(child: _buildPrivacyBanner()),
            SliverToBoxAdapter(
                child: _buildSection(
                    '📊 Data & Analytics', _dataItems(), AppColors.moduleCodeLab)),
            SliverToBoxAdapter(
                child: _buildSection(
                    '👤 Profile Visibility', _visibilityItems(), AppColors.moduleCreative)),
            SliverToBoxAdapter(
                child: _buildSection(
                    '🔐 Security', _securityItems(), AppColors.success)),
            SliverToBoxAdapter(child: _buildDataActions()),
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
          child: const Text('Save',
              style: TextStyle(
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
          child: const Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Privacy Settings 🔒',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w800)),
                  SizedBox(height: 4),
                  Text('You control your data',
                      style: TextStyle(color: Colors.white70, fontSize: 13)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPrivacyBanner() {
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
      child: const Row(
        children: [
          Text('🛡️', style: TextStyle(fontSize: 32)),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Privacy Matters',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'We never sell your personal data. These settings control how your information is used within LearnNova.',
                  style: TextStyle(
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

  List<Widget> _dataItems() => [
        _privacyTile(
          emoji: '📈',
          title: 'Analytics & Insights',
          subtitle: 'Help improve the app with anonymised usage data',
          value: _analyticsData,
          onChanged: (v) => setState(() => _analyticsData = v),
        ),
        _privacyTile(
          emoji: '🐞',
          title: 'Crash Reports',
          subtitle: 'Automatically send crash reports to fix bugs',
          value: _crashReports,
          onChanged: (v) => setState(() => _crashReports = v),
        ),
        _privacyTile(
          emoji: '🎯',
          title: 'Personalised Ads',
          subtitle: 'Show relevant ads based on your learning',
          value: _personalisedAds,
          onChanged: (v) => setState(() => _personalisedAds = v),
        ),
        _privacyTile(
          emoji: '📊',
          title: 'Usage Statistics',
          subtitle: 'Track study time and session data',
          value: _usageStatistics,
          onChanged: (v) => setState(() => _usageStatistics = v),
        ),
      ];

  List<Widget> _visibilityItems() => [
        _privacyTileWithDropdown(
          emoji: '🌐',
          title: 'Profile Visibility',
          subtitle: 'Who can see your profile',
          value: _profileVisibility,
          options: const ['Everyone', 'Friends', 'Only Me'],
          onChanged: (v) => setState(() => _profileVisibility = v!),
        ),
        _privacyTile(
          emoji: '📚',
          title: 'Show Learning Progress',
          subtitle: 'Display course completion on profile',
          value: _showProgress,
          onChanged: (v) => setState(() => _showProgress = v),
        ),
        _privacyTile(
          emoji: '🏅',
          title: 'Show Badges & Achievements',
          subtitle: 'Display earned badges publicly',
          value: _showBadges,
          onChanged: (v) => setState(() => _showBadges = v),
        ),
        _privacyTile(
          emoji: '🏆',
          title: 'Appear in Leaderboard',
          subtitle: 'Let others see your ranking',
          value: _showInLeaderboard,
          onChanged: (v) => setState(() => _showInLeaderboard = v),
        ),
      ];

  List<Widget> _securityItems() => [
        _privacyTile(
          emoji: '🔑',
          title: 'Two-Factor Authentication',
          subtitle: 'Extra security layer with SMS/email code',
          value: _twoFactorAuth,
          onChanged: (v) {
            setState(() => _twoFactorAuth = v);
            if (v) _show2FADialog();
          },
        ),
        _privacyTile(
          emoji: '🔔',
          title: 'Login Alerts',
          subtitle: 'Get notified of new sign-ins',
          value: _loginAlerts,
          onChanged: (v) => setState(() => _loginAlerts = v),
        ),
        _privacyTile(
          emoji: '📱',
          title: 'Active Sessions',
          subtitle: 'Manage where you\'re logged in',
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
            .map((o) => DropdownMenuItem(value: o, child: Text(o)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildDataActions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text(
              'DATA ACTIONS',
              style: TextStyle(
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
                  title: 'Download My Data',
                  subtitle: 'Get a copy of all your data',
                  onTap: () => _showComingSoon('Data export coming soon'),
                ),
                const Divider(
                    height: 1, indent: 56, endIndent: 16, color: AppColors.divider),
                _actionTile(
                  icon: Icons.cleaning_services_rounded,
                  color: AppColors.accent,
                  title: 'Clear Activity History',
                  subtitle: 'Delete browsing & search history',
                  onTap: () => _showClearDialog(),
                ),
                const Divider(
                    height: 1, indent: 56, endIndent: 16, color: AppColors.divider),
                _actionTile(
                  icon: Icons.delete_forever_rounded,
                  color: AppColors.error,
                  title: 'Delete Account',
                  subtitle: 'Permanently remove your account and data',
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
        title: const Row(
          children: [
            Text('🔑 ', style: TextStyle(fontSize: 22)),
            Text('Enable 2FA'),
          ],
        ),
        content: const Text(
          'Two-Factor Authentication adds an extra layer of security. You\'ll be prompted for a code when signing in on new devices.\n\nFull setup coming soon!',
          style: TextStyle(color: AppColors.textSecondary, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _twoFactorAuth = false);
            },
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textSecondary)),
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
        title: const Text('Clear Activity History?'),
        content: const Text(
          'This will delete your browsing and search history. This action cannot be undone.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Activity history cleared!'),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
            child: const Text('Clear',
                style: TextStyle(
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
        title: const Row(
          children: [
            Text('⚠️ ', style: TextStyle(fontSize: 22)),
            Text('Delete Account?'),
          ],
        ),
        content: const Text(
          'This is permanent. All your progress, certificates, and data will be deleted and CANNOT be recovered.',
          style: TextStyle(color: AppColors.textSecondary, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showComingSoon('Account deletion coming soon');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Delete',
                style: TextStyle(fontWeight: FontWeight.w700)),
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
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text('Privacy settings saved!'),
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
