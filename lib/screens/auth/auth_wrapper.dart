import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'login_screen.dart';
import '../../main.dart'; // MainScaffold
import '../../constants/app_colors.dart';
import '../../services/module_state_service.dart';

/// Listens to [FirebaseAuth.authStateChanges] and routes the user
/// to either [MainScaffold] (authenticated) or [LoginScreen] (unauthenticated).
///
/// When a user signs in, it initializes [ModuleStateService] to load
/// their personal progress before showing the main scaffold.
/// When a user signs out, it resets [ModuleStateService] so the next
/// user starts with a clean in-memory state.
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  // Track the UID we last initialized for, so we only re-init when
  // the user actually changes (not on every stream event).
  String? _initializedUid;
  bool _isInitializing = false;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // ── Resolving auth state ─────────────────────────────────────────────
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _SplashLoading();
        }

        final user = snapshot.data;

        // ── Not authenticated ────────────────────────────────────────────────
        if (user == null) {
          // Reset module state so the next login starts clean
          if (_initializedUid != null) {
            ModuleStateService.instance.reset();
            _initializedUid = null;
          }
          return const LoginScreen();
        }

        // ── Authenticated ────────────────────────────────────────────────────
        // Only re-initialize if a different (or new) user signed in
        if (_initializedUid != user.uid) {
          // Show splash while we load this user's progress
          if (!_isInitializing) {
            _isInitializing = true;
            ModuleStateService.instance.initialize().then((_) {
              if (mounted) {
                setState(() {
                  _initializedUid = user.uid;
                  _isInitializing = false;
                });
              }
            });
          }
          return const _SplashLoading();
        }

        return const MainScaffold();
      },
    );
  }
}

/// Simple branded splash/loading screen shown while the auth state resolves
/// or while user progress is being loaded.
class _SplashLoading extends StatelessWidget {
  const _SplashLoading();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Center(
                child: Text('📚', style: TextStyle(fontSize: 38)),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'LearnNova',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 32),
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
