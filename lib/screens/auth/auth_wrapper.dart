import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'login_screen.dart';
import '../../main.dart'; // MainScaffold
import '../../constants/app_colors.dart';

/// Listens to [FirebaseAuth.authStateChanges] and routes the user
/// to either [MainScaffold] (authenticated) or [LoginScreen] (unauthenticated).
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // ── Resolving auth state ─────────────────────────────────────────────
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _SplashLoading();
        }

        // ── Authenticated ────────────────────────────────────────────────────
        if (snapshot.hasData && snapshot.data != null) {
          return const MainScaffold();
        }

        // ── Not authenticated ────────────────────────────────────────────────
        return const LoginScreen();
      },
    );
  }
}

/// Simple branded splash/loading screen shown while the auth state resolves.
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
