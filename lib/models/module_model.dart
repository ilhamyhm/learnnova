/// Represents an individual lesson/topic within a submodule.
class SubModule {
  final String name;
  final String description;
  final String icon;
  final int totalLessons;

  /// Key used to fetch materials from the API (e.g. "codelab_html").
  final String apiKey;

  /// Runtime progress (0.0–1.0), loaded from persistent storage.
  double progress;
  bool isCompleted;

  SubModule({
    required this.name,
    required this.description,
    required this.icon,
    required this.apiKey,
    this.totalLessons = 5,
    this.progress = 0.0,
    this.isCompleted = false,
  });

  int get completedLessons => (progress * totalLessons).round();
}

/// Represents a top-level learning module (e.g. CodeLab, BizLab).
class Module {
  final String name;
  final String description;
  final String icon;
  final int colorValue;
  final List<SubModule> subModules;
  final String category;

  /// Key used to fetch quizzes from the API (e.g. "codelab").
  final String apiKey;

  Module({
    required this.name,
    required this.description,
    required this.icon,
    required this.colorValue,
    required this.subModules,
    required this.category,
    required this.apiKey,
  });

  /// Average progress across all submodules (0.0–1.0).
  double get overallProgress {
    if (subModules.isEmpty) return 0.0;
    return subModules.map((s) => s.progress).reduce((a, b) => a + b) /
        subModules.length;
  }

  /// Number of submodules the user has fully completed.
  int get completedSubModules =>
      subModules.where((s) => s.isCompleted).length;

  /// Whether all submodules are completed (unlocks the quiz).
  bool get allSubModulesCompleted =>
      subModules.isNotEmpty &&
      subModules.every((s) => s.isCompleted);
}
