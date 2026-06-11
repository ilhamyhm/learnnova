import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ── Auth State ──────────────────────────────────────────────────────────────

  /// Stream of auth-state changes (null = signed out, User = signed in).
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Currently signed-in user, or null.
  User? get currentUser => _auth.currentUser;

  // ── Sign In ─────────────────────────────────────────────────────────────────

  /// Signs in with email and password.
  /// Throws [FirebaseAuthException] on failure.
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  // ── Register ─────────────────────────────────────────────────────────────────

  /// Creates a new account and sets the display name.
  /// Throws [FirebaseAuthException] on failure.
  Future<UserCredential> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    await credential.user?.updateDisplayName(displayName.trim());
    await credential.user?.reload();
    return credential;
  }

  // ── Password Reset ────────────────────────────────────────────────────────────

  /// Sends a password-reset email to the given address.
  /// Throws [FirebaseAuthException] on failure.
  Future<void> sendPasswordResetEmail({required String email}) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  // ── Sign Out ──────────────────────────────────────────────────────────────────

  /// Signs out the current user.
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // ── Error Helpers ─────────────────────────────────────────────────────────────

  /// Converts a [FirebaseAuthException] code into a user-friendly message.
  static String friendlyError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-not-found':
        return 'No account found for this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-credential':
        return 'Invalid email or password. Please check your credentials.';
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'user-disabled':
        return 'This account has been disabled. Contact support.';
      case 'operation-not-allowed':
        return 'Email/password sign-in is not enabled.';
      default:
        return e.message ?? 'An unexpected error occurred.';
    }
  }
}
