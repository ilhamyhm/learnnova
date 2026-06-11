import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists user-specific learning progress in SharedPreferences.
///
/// Every key is namespaced with the current Firebase UID so that data
/// is completely isolated between users on the same device.
///
///   Format:  uid:<firebase_uid>:<key_type><module_key>
///   Example: uid:abc123:viewed_slides_codelab_html
class UserProgressService {
  // ─── Singleton ────────────────────────────────────────────────────────────
  static final UserProgressService instance = UserProgressService._();
  UserProgressService._();

  // ─── Key prefixes ─────────────────────────────────────────────────────────
  static const String _pfxViewed   = 'viewed_slides_';
  static const String _pfxScore    = 'quiz_score_';
  static const String _pfxPassed   = 'quiz_passed_';
  static const String _pfxMatProg  = 'mat_progress_';

  // ─── UID helper ───────────────────────────────────────────────────────────

  /// Returns the current Firebase UID.
  /// Falls back to "anonymous" when no user is signed in (should not happen
  /// in normal usage, but prevents null crashes during transitions).
  String get _uid {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    assert(uid != null, 'UserProgressService used before authentication');
    return uid ?? 'anonymous';
  }

  String _key(String prefix, String moduleKey) => 'uid:$_uid:$prefix$moduleKey';

  // ─── Slide Progress ───────────────────────────────────────────────────────

  /// Returns the set of viewed slide IDs for [subModuleKey].
  Future<Set<int>> getViewedSlides(String subModuleKey) async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList(_key(_pfxViewed, subModuleKey)) ?? [];
    return stored.map(int.parse).toSet();
  }

  /// Marks slide [slideId] as viewed for [subModuleKey].
  Future<void> markSlideViewed(String subModuleKey, int slideId) async {
    final prefs = await SharedPreferences.getInstance();
    final viewed = await getViewedSlides(subModuleKey);
    viewed.add(slideId);
    await prefs.setStringList(
      _key(_pfxViewed, subModuleKey),
      viewed.map((e) => e.toString()).toList(),
    );
  }

  // ─── Material Progress ────────────────────────────────────────────────────

  /// Returns the material progress (0.0–1.0) for [subModuleKey].
  Future<double> getMaterialProgress(String subModuleKey) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_key(_pfxMatProg, subModuleKey)) ?? 0.0;
  }

  /// Updates material progress for [subModuleKey] given viewed count / total.
  Future<void> updateMaterialProgress(
    String subModuleKey,
    int viewedCount,
    int totalSlides,
  ) async {
    if (totalSlides == 0) return;
    final prefs = await SharedPreferences.getInstance();
    final progress = (viewedCount / totalSlides).clamp(0.0, 1.0);
    await prefs.setDouble(_key(_pfxMatProg, subModuleKey), progress);
  }

  // ─── Quiz Results ─────────────────────────────────────────────────────────

  /// Returns the saved quiz score for [moduleKey], or null if not attempted.
  Future<double?> getQuizScore(String moduleKey) async {
    final prefs = await SharedPreferences.getInstance();
    final k = _key(_pfxScore, moduleKey);
    return prefs.containsKey(k) ? prefs.getDouble(k) : null;
  }

  /// Returns whether the [moduleKey] quiz was passed.
  Future<bool> isQuizPassed(String moduleKey) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key(_pfxPassed, moduleKey)) ?? false;
  }

  /// Saves a quiz result for [moduleKey].
  Future<void> saveQuizResult(
    String moduleKey,
    double scorePercent,
    bool passed,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_key(_pfxScore, moduleKey), scorePercent);
    await prefs.setBool(_key(_pfxPassed, moduleKey), passed);
  }

  // ─── Utility ──────────────────────────────────────────────────────────────

  /// Clears **all** progress data for the current user only.
  /// Useful for a "reset progress" feature without touching other users' data.
  Future<void> clearCurrentUserProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final prefix = 'uid:$_uid:';
    final keysToRemove = prefs.getKeys().where((k) => k.startsWith(prefix)).toList();
    for (final k in keysToRemove) {
      await prefs.remove(k);
    }
  }
}
