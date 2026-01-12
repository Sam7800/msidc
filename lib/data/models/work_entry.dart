/// WorkEntry model - Main work entry for a project (1:1 relationship)
class WorkEntry {
  final int? id;
  final int projectId;
  final String? lastUpdatedBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  WorkEntry({
    this.id,
    required this.projectId,
    this.lastUpdatedBy,
    this.createdAt,
    this.updatedAt,
  });

  /// Create from JSON (SQLite or API)
  factory WorkEntry.fromJson(Map<String, dynamic> json) {
    return WorkEntry(
      id: json['id'] as int?,
      projectId: json['project_id'] as int,
      lastUpdatedBy: json['last_updated_by'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  /// Convert to JSON (for SQLite or API)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'project_id': projectId,
      'last_updated_by': lastUpdatedBy,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Convert to JSON for insert (without id, timestamps)
  Map<String, dynamic> toJsonForInsert() {
    return {
      'project_id': projectId,
      'last_updated_by': lastUpdatedBy,
    };
  }

  /// Copy with
  WorkEntry copyWith({
    int? id,
    int? projectId,
    String? lastUpdatedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WorkEntry(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      lastUpdatedBy: lastUpdatedBy ?? this.lastUpdatedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'WorkEntry(id: $id, projectId: $projectId, lastUpdatedBy: $lastUpdatedBy)';
  }
}
