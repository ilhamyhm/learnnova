import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Tracks per-user daily learning streaks.
///
/// A streak increments when [recordActivity] is called on a new calendar day
/// (relative to the last day activity was recorded). If the user misses a day
/// the streak resets to 1 (the current active day still counts).
///
/// All keys are namespaced by Firebase UID so data is isolated per user.
class StreakService {
  static final StreakService instance = StreakService._();
  StreakService._();

  String get _uid {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return uid ?? 'anonymous';
  }

  String get _streakKey => 'uid:$_uid:streak_count';
  String get _lastDateKey => 'uid:$_uid:streak_last_date';

  /// Returns the current streak for the logged-in user.
  Future<int> getStreak() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_streakKey) ?? 0;
  }

  /// Call this whenever the user does something that counts as learning
  /// (viewed a slide, passed a quiz, completed a material).
  ///
  /// Returns the updated streak value.
  Future<int> recordActivity() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _todayString();
    final lastDate = prefs.getString(_lastDateKey);
    int streak = prefs.getInt(_streakKey) ?? 0;

    if (lastDate == null) {
      // First ever activity — start streak at 1
      streak = 1;
    } else if (lastDate == today) {
      // Already recorded today — no change
      return streak;
    } else {
      final last = DateTime.parse(lastDate);
      final now = DateTime.now();
      final diff = DateTime(now.year, now.month, now.day)
          .difference(DateTime(last.year, last.month, last.day))
          .inDays;

      if (diff == 1) {
        // Consecutive day
        streak += 1;
      } else {
        // Missed one or more days — reset
        streak = 1;
      }
    }

    await prefs.setInt(_streakKey, streak);
    await prefs.setString(_lastDateKey, today);
    return streak;
  }

  /// Clears streak data for the current user (e.g. for testing).
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_streakKey);
    await prefs.remove(_lastDateKey);
  }

  /// Returns today as an ISO date string (e.g. "2026-06-11").
  String _todayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}
