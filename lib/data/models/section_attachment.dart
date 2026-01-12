/// SectionAttachment model - File attachments for sections (photos, PDFs)
class SectionAttachment {
  final int? id;
  final int sectionId;
  final String fileName;
  final String filePath;
  final String? fileType;
  final int? fileSize;
  final DateTime? uploadedAt;

  SectionAttachment({
    this.id,
    required this.sectionId,
    required this.fileName,
    required this.filePath,
    this.fileType,
    this.fileSize,
    this.uploadedAt,
  });

  /// Create from JSON (SQLite or API)
  factory SectionAttachment.fromJson(Map<String, dynamic> json) {
    return SectionAttachment(
      id: json['id'] as int?,
      sectionId: json['section_id'] as int,
      fileName: json['file_name'] as String,
      filePath: json['file_path'] as String,
      fileType: json['file_type'] as String?,
      fileSize: json['file_size'] as int?,
      uploadedAt: json['uploaded_at'] != null
          ? DateTime.parse(json['uploaded_at'] as String)
          : null,
    );
  }

  /// Convert to JSON (for SQLite or API)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'section_id': sectionId,
      'file_name': fileName,
      'file_path': filePath,
      'file_type': fileType,
      'file_size': fileSize,
      'uploaded_at': uploadedAt?.toIso8601String(),
    };
  }

  /// Convert to JSON for insert (without id, timestamp)
  Map<String, dynamic> toJsonForInsert() {
    return {
      'section_id': sectionId,
      'file_name': fileName,
      'file_path': filePath,
      'file_type': fileType,
      'file_size': fileSize,
    };
  }

  /// Copy with
  SectionAttachment copyWith({
    int? id,
    int? sectionId,
    String? fileName,
    String? filePath,
    String? fileType,
    int? fileSize,
    DateTime? uploadedAt,
  }) {
    return SectionAttachment(
      id: id ?? this.id,
      sectionId: sectionId ?? this.sectionId,
      fileName: fileName ?? this.fileName,
      filePath: filePath ?? this.filePath,
      fileType: fileType ?? this.fileType,
      fileSize: fileSize ?? this.fileSize,
      uploadedAt: uploadedAt ?? this.uploadedAt,
    );
  }

  @override
  String toString() {
    return 'SectionAttachment(id: $id, fileName: $fileName, fileSize: $fileSize)';
  }
}
