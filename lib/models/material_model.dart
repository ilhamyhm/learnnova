/// Represents a single learning slide/material from the backend API.
class MaterialSlide {
  final int materialId;
  final String title;
  final String content;
  final String? example; // Optional code example

  const MaterialSlide({
    required this.materialId,
    required this.title,
    required this.content,
    this.example,
  });

  factory MaterialSlide.fromJson(Map<String, dynamic> json) {
    return MaterialSlide(
      materialId: json['material_id'] as int,
      title: json['title'] as String,
      content: json['content'] as String,
      example: json['example'] as String?,
    );
  }
}

/// Represents the complete materials response for a submodule from the backend.
class ModuleMaterialsResponse {
  final int moduleId;
  final String title;
  final String level;
  final String tujuanPembelajaran; // Learning objectives
  final int totalSlide;
  final List<MaterialSlide> materials;

  const ModuleMaterialsResponse({
    required this.moduleId,
    required this.title,
    required this.level,
    required this.tujuanPembelajaran,
    required this.totalSlide,
    required this.materials,
  });

  factory ModuleMaterialsResponse.fromJson(Map<String, dynamic> json) {
    return ModuleMaterialsResponse(
      moduleId: json['module_id'] as int,
      title: json['title'] as String,
      level: json['level'] as String,
      tujuanPembelajaran: json['tujuan_pembelajaran'] as String,
      totalSlide: json['total_slide'] as int,
      materials: (json['materials'] as List<dynamic>)
          .map((e) => MaterialSlide.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
