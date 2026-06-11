import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen>
    with SingleTickerProviderStateMixin {
  // ── Master toggle ──────────────────────────────────────────────────────────
  bool _allNotifications = true;

  // ── Learning ───────────────────────────────────────────────────────────────
  bool _dailyReminder = true;
  bool _courseUpdates = true;
  bool _streakAlerts = true;
  bool _newContent = false;

  // ── Social ─────────────────────────────────────────────────────────────────
  bool _achievements = true;
  bool _leaderboard = false;
  bool _communityActivity = false;

  // ── Email ──────────────────────────────────────────────────────────────────
  bool _weeklyDigest = true;
  bool _promotionalEmails = false;
  bool _securityAlerts = true;

  // ── Reminder Time ──────────────────────────────────────────────────────────
  String _reminderTime = '08:00 AM';

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

  void _toggleAll(bool v) {
    setState(() {
      _allNotifications = v;
      _dailyReminder = v;
      _courseUpdates = v;
      _streakAlerts = v;
      _achievements = v;
      _leaderboard = false;
      _communityActivity = false;
      _newContent = false;
    });
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
            SliverToBoxAdapter(child: _buildMasterToggle()),
            SliverToBoxAdapter(
                child: _buildSection('🎓 Learning', _learningItems())),
            SliverToBoxAdapter(
                child: _buildSection('🏆 Achievements & Social', _socialItems())),
            SliverToBoxAdapter(
                child: _buildSection('📧 Email Notifications', _emailItems())),
            SliverToBoxAdapter(child: _buildReminderTime()),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 160,
      backgroundColor: AppColors.accent,
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
          onPressed: _saveSettings,
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
              colors: [Color(0xFFFF6B35), Color(0xFFFF9F43)],
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
                  Text('Notifications 🔔',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w800)),
                  SizedBox(height: 4),
                  Text('Customize what you hear from us',
                      style: TextStyle(color: Colors.white70, fontSize: 13)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMasterToggle() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('All Notifications',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700)),
                SizedBox(height: 4),
                Text('Master switch for all alerts',
                    style: TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
          Switch.adaptive(
            value: _allNotifications,
            onChanged: _toggleAll,
            activeThumbColor: Colors.white,
            activeTrackColor: Colors.white.withValues(alpha: 0.4),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> items) {
    return AnimatedOpacity(
      opacity: _allNotifications ? 1.0 : 0.45,
      duration: const Duration(milliseconds: 300),
      child: Column(
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
      ),
    );
  }

  List<Widget> _learningItems() => [
        _notifTile(
          emoji: '⏰',
          title: 'Daily Reminder',
          subtitle: 'Remind me to study each day',
          value: _dailyReminder && _allNotifications,
          onChanged: _allNotifications
              ? (v) => setState(() => _dailyReminder = v)
              : null,
        ),
        _notifTile(
          emoji: '📚',
          title: 'Course Updates',
          subtitle: 'New lessons added to enrolled courses',
          value: _courseUpdates && _allNotifications,
          onChanged: _allNotifications
              ? (v) => setState(() => _courseUpdates = v)
              : null,
        ),
        _notifTile(
          emoji: '🔥',
          title: 'Streak Alerts',
          subtitle: "Don't break your learning streak!",
          value: _streakAlerts && _allNotifications,
          onChanged: _allNotifications
              ? (v) => setState(() => _streakAlerts = v)
              : null,
        ),
        _notifTile(
          emoji: '✨',
          title: 'New Content',
          subtitle: 'Fresh courses & modules',
          value: _newContent && _allNotifications,
          onChanged: _allNotifications
              ? (v) => setState(() => _newContent = v)
              : null,
        ),
      ];

  List<Widget> _socialItems() => [
        _notifTile(
          emoji: '🏅',
          title: 'Achievements',
          subtitle: 'When you earn badges or level up',
          value: _achievements && _allNotifications,
          onChanged: _allNotifications
              ? (v) => setState(() => _achievements = v)
              : null,
        ),
        _notifTile(
          emoji: '🏆',
          title: 'Leaderboard',
          subtitle: 'Ranking changes & milestones',
          value: _leaderboard && _allNotifications,
          onChanged: _allNotifications
              ? (v) => setState(() => _leaderboard = v)
              : null,
        ),
        _notifTile(
          emoji: '👥',
          title: 'Community Activity',
          subtitle: 'Replies, likes & mentions',
          value: _communityActivity && _allNotifications,
          onChanged: _allNotifications
              ? (v) => setState(() => _communityActivity = v)
              : null,
        ),
      ];

  List<Widget> _emailItems() => [
        _notifTile(
          emoji: '📊',
          title: 'Weekly Digest',
          subtitle: 'Your weekly learning summary',
          value: _weeklyDigest && _allNotifications,
          onChanged: _allNotifications
              ? (v) => setState(() => _weeklyDigest = v)
              : null,
        ),
        _notifTile(
          emoji: '🎁',
          title: 'Promotions & Offers',
          subtitle: 'Special deals and new features',
          value: _promotionalEmails && _allNotifications,
          onChanged: _allNotifications
              ? (v) => setState(() => _promotionalEmails = v)
              : null,
        ),
        _notifTile(
          emoji: '🔒',
          title: 'Security Alerts',
          subtitle: 'Login attempts & account changes',
          value: _securityAlerts,
          onChanged: (v) => setState(() => _securityAlerts = v),
          canDisable: false,
        ),
      ];

  Widget _notifTile({
    required String emoji,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool>? onChanged,
    bool canDisable = true,
  }) {
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
      title: Text(
        title,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
      ),
      trailing: canDisable
          ? Switch.adaptive(
              value: value,
              onChanged: onChanged,
              activeThumbColor: AppColors.primary,
              activeTrackColor: AppColors.primaryLight,
            )
          : Tooltip(
              message: 'Security alerts cannot be disabled',
              child: Switch.adaptive(
                value: value,
                onChanged: null,
                activeThumbColor: AppColors.success,
                activeTrackColor: AppColors.successLight,
              ),
            ),
    );
  }

  Widget _buildReminderTime() {
    final times = [
      '06:00 AM', '07:00 AM', '08:00 AM', '09:00 AM',
      '12:00 PM', '06:00 PM', '08:00 PM', '09:00 PM',
    ];
    return AnimatedOpacity(
      opacity: _allNotifications && _dailyReminder ? 1.0 : 0.45,
      duration: const Duration(milliseconds: 300),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 8, 20, 8),
            child: Text(
              '⏰  Daily Reminder Time',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(16),
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
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: times.map((t) {
                final selected = t == _reminderTime;
                return GestureDetector(
                  onTap: () => setState(() => _reminderTime = t),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.primary
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected
                            ? AppColors.primary
                            : AppColors.divider,
                      ),
                    ),
                    child: Text(
                      t,
                      style: TextStyle(
                        color: selected
                            ? Colors.white
                            : AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  void _saveSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text('Notification preferences saved!'),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
    Navigator.pop(context);
  }
}
