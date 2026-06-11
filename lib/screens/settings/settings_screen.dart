import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_theme.dart';
import '../../services/firebase_auth_service.dart';
import '../auth/forgot_password_screen.dart';
import 'edit_profile_screen.dart';
import 'help_support_screen.dart';
import 'notification_settings_screen.dart';
import 'privacy_settings_screen.dart';
import 'profile_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = themeNotifier.value == ThemeMode.dark;
  String _selectedLanguage = 'English';

  User? get _user => FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildHeader(context),
          SliverToBoxAdapter(child: _buildProfileTile(context)),
          SliverToBoxAdapter(child: _buildSection('Account', _accountItems(context))),
          SliverToBoxAdapter(child: _buildSection('Preferences', _preferenceItems(context))),
          SliverToBoxAdapter(child: _buildSection('Support', _supportItems(context))),
          SliverToBoxAdapter(child: _buildSection('About', _aboutItems())),
          SliverToBoxAdapter(child: _buildLogout(context)),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 16,
          left: 20,
          right: 20,
          bottom: 20,
        ),
        decoration: const BoxDecoration(gradient: AppColors.heroGradient),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Settings ⚙️',
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Manage your preferences',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileTile(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ProfileScreen()),
      ),
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(16),
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
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Center(
                child: Text('👤', style: TextStyle(fontSize: 28)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _user?.displayName ?? 'LearnNova User',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _user?.email ?? '',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 6),
                  const Row(
                    children: [
                      Icon(Icons.workspace_premium_rounded, color: Colors.amber, size: 14),
                      SizedBox(width: 4),
                      Text(
                        'Pro Learner',
                        style: TextStyle(
                          color: Colors.amber,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.chevron_right_rounded, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
          child: Text(
            title,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
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
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Column(
                children: [
                  item,
                  if (index < items.length - 1)
                    const Divider(
                      height: 1,
                      indent: 56,
                      endIndent: 16,
                      color: AppColors.divider,
                    ),
                ],
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  List<Widget> _accountItems(BuildContext context) => [
    _settingsTile(
      icon: Icons.person_rounded,
      iconColor: AppColors.primary,
      title: 'Edit Profile',
      subtitle: 'Update your personal info',
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const EditProfileScreen()),
      ),
    ),
    _settingsTile(
      icon: Icons.lock_rounded,
      iconColor: AppColors.moduleCodeLab,
      title: 'Change Password',
      subtitle: 'Update your password',
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
      ),
    ),
    _settingsTile(
      icon: Icons.email_rounded,
      iconColor: AppColors.moduleCreative,
      title: 'Email Address',
      subtitle: _user?.email ?? '—',
      onTap: () => _showComingSoon(context),
    ),
  ];

  List<Widget> _preferenceItems(BuildContext context) => [
    _settingsTileWithToggle(
      icon: Icons.notifications_rounded,
      iconColor: AppColors.accent,
      title: 'Notifications',
      subtitle: 'Push, email notifications',
      value: _notificationsEnabled,
      onChanged: (v) {
        setState(() => _notificationsEnabled = v);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NotificationSettingsScreen()),
        );
      },
    ),
    _settingsTileWithToggle(
      icon: Icons.dark_mode_rounded,
      iconColor: AppColors.textPrimary,
      title: 'Dark Mode',
      subtitle: 'Toggle dark appearance',
      value: _darkModeEnabled,
      onChanged: (v) {
        setState(() => _darkModeEnabled = v);
        themeNotifier.value = v ? ThemeMode.dark : ThemeMode.light;
      },
    ),
    _settingsTileWithDropdown(
      icon: Icons.language_rounded,
      iconColor: AppColors.moduleLanguage,
      title: 'Language',
      value: _selectedLanguage,
      options: ['English', 'Indonesian', 'Spanish'],
      onChanged: (v) => setState(() => _selectedLanguage = v!),
    ),
    _settingsTile(
      icon: Icons.privacy_tip_rounded,
      iconColor: AppColors.moduleAnimation,
      title: 'Privacy Settings',
      subtitle: 'Manage data & permissions',
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const PrivacySettingsScreen()),
      ),
    ),
  ];

  List<Widget> _supportItems(BuildContext context) => [
    _settingsTile(
      icon: Icons.help_rounded,
      iconColor: AppColors.primary,
      title: 'Help & Support',
      subtitle: 'FAQs, contact us',
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const HelpSupportScreen()),
      ),
    ),
    _settingsTile(
      icon: Icons.feedback_rounded,
      iconColor: AppColors.moduleAcademy,
      title: 'Send Feedback',
      subtitle: 'Share your thoughts',
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const HelpSupportScreen()),
      ),
    ),
  ];

  List<Widget> _aboutItems() => [
    _settingsTile(
      icon: Icons.info_rounded,
      iconColor: AppColors.moduleCodeLab,
      title: 'About LearnNova',
      subtitle: 'Version 1.0.0',
      onTap: () => _showAboutDialog(context),
    ),
    _settingsTile(
      icon: Icons.star_rounded,
      iconColor: AppColors.accent,
      title: 'Rate Us',
      subtitle: 'Love the app? Leave a review!',
      onTap: () {},
    ),
  ];

  Widget _settingsTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: iconColor, size: 20),
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
      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textHint, size: 20),
    );
  }

  Widget _settingsTileWithToggle({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: iconColor, size: 20),
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
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeThumbColor: AppColors.primary,
        activeTrackColor: AppColors.primaryLight,
      ),
    );
  }

  Widget _settingsTileWithDropdown({
    required IconData icon,
    required Color iconColor,
    required String title,
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
          color: iconColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: DropdownButton<String>(
        value: value,
        underline: const SizedBox(),
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        items: options
            .map((o) => DropdownMenuItem(value: o, child: Text(o)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildLogout(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: GestureDetector(
        onTap: () => _showLogoutDialog(context),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.errorLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.error.withValues(alpha: 0.3), width: 1.5),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout_rounded, color: AppColors.error, size: 20),
              SizedBox(width: 8),
              Text(
                'Log Out',
                style: TextStyle(
                  color: AppColors.error,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('🚧 Coming soon!'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Text('📚', style: TextStyle(fontSize: 28)),
            SizedBox(width: 8),
            Text('LearnNova'),
          ],
        ),
        content: const Text(
          'LearnNova v1.0.0\n\nLearn Smarter, Grow Faster.\n\nA modern educational platform designed to make learning engaging, effective, and fun.',
          style: TextStyle(color: AppColors.textSecondary, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Log Out?'),
        content: const Text(
          'Are you sure you want to log out of LearnNova?',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              // Only sign out — AuthWrapper's stream listener will
              // automatically rebuild and show the LoginScreen.
              // Do NOT navigate manually here; that causes a race condition
              // that breaks subsequent logins.
              await FirebaseAuthService().signOut();
            },
            child: const Text('Log Out', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
