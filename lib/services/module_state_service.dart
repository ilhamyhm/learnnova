import '../data/modules_data.dart';
import '../models/module_model.dart';
import 'user_progress_service.dart';

/// Manages the current user's in-memory module list.
///
/// On sign-in, call [initialize] to get a fresh copy of the modules with
/// progress loaded from [UserProgressService].
/// On sign-out, call [reset] to clear the in-memory state so the next
/// user starts clean.
class ModuleStateService {
  // ─── Singleton ────────────────────────────────────────────────────────────
  static final ModuleStateService instance = ModuleStateService._();
  ModuleStateService._();

  List<Module> _modules = [];
  bool _initialized = false;

  /// The current user's module list. Empty until [initialize] is called.
  List<Module> get modules => _modules;

  bool get isInitialized => _initialized;

  // ─── Lifecycle ────────────────────────────────────────────────────────────

  /// Loads a fresh module list and populates it with progress from
  /// [UserProgressService] for the currently signed-in user.
  ///
  /// Safe to call multiple times — re-initializes on each call.
  Future<void> initialize() async {
    // Build a completely fresh set of module/submodule instances
    _modules = buildModules();

    final progressService = UserProgressService.instance;

    // Load persisted progress for every submodule
    for (final module in _modules) {
      for (final sub in module.subModules) {
        final progress = await progressService.getMaterialProgress(sub.apiKey);
        sub.progress = progress;
        sub.isQuizPassed = await progressService.isQuizPassed(sub.apiKey);
        sub.quizScore = (await progressService.getQuizScore(sub.apiKey)) ?? 0.0;
        sub.isCompleted = sub.allMaterialsCompleted && sub.isQuizPassed;
      }
    }

    _initialized = true;
  }

  /// Clears in-memory state.  Call this on sign-out so the next user
  /// sees a clean slate until [initialize] is called again.
  void reset() {
    _modules = [];
    _initialized = false;
  }

  /// Refreshes progress for a single submodule from persistent storage.
  /// Useful after returning from [MaterialScreen] or [QuizScreen].
  Future<void> refreshSubModule(String subModuleKey, String moduleApiKey) async {
    final progressService = UserProgressService.instance;

    for (final module in _modules) {
      for (final sub in module.subModules) {
        if (sub.apiKey == subModuleKey) {
          final progress = await progressService.getMaterialProgress(subModuleKey);
          sub.progress = progress;
          sub.isQuizPassed = await progressService.isQuizPassed(sub.apiKey);
          sub.quizScore = (await progressService.getQuizScore(sub.apiKey)) ?? 0.0;
          sub.isCompleted = sub.allMaterialsCompleted && sub.isQuizPassed;
          return;
        }
      }
    }
  }

  /// Refreshes all module progress from persistent storage.
  Future<void> refreshAll() async {
    final progressService = UserProgressService.instance;
    for (final module in _modules) {
      for (final sub in module.subModules) {
        final progress = await progressService.getMaterialProgress(sub.apiKey);
        sub.progress = progress;
        sub.isQuizPassed = await progressService.isQuizPassed(sub.apiKey);
        sub.quizScore = (await progressService.getQuizScore(sub.apiKey)) ?? 0.0;
        sub.isCompleted = sub.allMaterialsCompleted && sub.isQuizPassed;
      }
    }
  }
}
