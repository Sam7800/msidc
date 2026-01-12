/// Project model - Projects within categories
class Project {
  final int? id;
  final String srNo;
  final String name;
  final int categoryId;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Additional fields for display (not in database)
  final String? categoryName;
  final String? categoryColor;

  Project({
    this.id,
    required this.srNo,
    required this.name,
    required this.categoryId,
    this.status = 'Pending',
    this.createdAt,
    this.updatedAt,
    this.categoryName,
    this.categoryColor,
  });

  /// Create from JSON (SQLite or API)
  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'] as int?,
      srNo: json['sr_no'] as String,
      name: json['name'] as String,
      categoryId: json['category_id'] as int,
      status: json['status'] as String? ?? 'Pending',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      categoryName: json['category_name'] as String?,
      categoryColor: json['category_color'] as String?,
    );
  }

  /// Convert to JSON (for SQLite or API)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sr_no': srNo,
      'name': name,
      'category_id': categoryId,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Convert to JSON for insert (without id, timestamps)
  Map<String, dynamic> toJsonForInsert() {
    return {
      'sr_no': srNo,
      'name': name,
      'category_id': categoryId,
      'status': status,
    };
  }

  /// Copy with
  Project copyWith({
    int? id,
    String? srNo,
    String? name,
    int? categoryId,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? categoryName,
    String? categoryColor,
  }) {
    return Project(
      id: id ?? this.id,
      srNo: srNo ?? this.srNo,
      name: name ?? this.name,
      categoryId: categoryId ?? this.categoryId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      categoryName: categoryName ?? this.categoryName,
      categoryColor: categoryColor ?? this.categoryColor,
    );
  }

  @override
  String toString() {
    return 'Project(id: $id, srNo: $srNo, name: $name, status: $status)';
  }
}
