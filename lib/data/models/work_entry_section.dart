import 'dart:convert';

/// WorkEntrySection model - Individual sections of work entry form (33+ sections)
///
/// Sections: aa, dpr, boq, schedules, drawings, bid_documents, env, la,
/// utility_shifting, ts, nit, prebid, csd, bid_submission, tech_evaluation,
/// financial_bid, bid_acceptance, loa, pbg, work_order, agreement, ms_i, ms_ii,
/// ms_iii, ms_iv, ms_v, ld, eot, cos, expenditure, audit_para, laq,
/// technical_audit, rev_aa, supplementary_agreement
class WorkEntrySection {
  final int? id;
  final int workEntryId;
  final String sectionName;
  final Map<String, dynamic> sectionData;
  final String? personResponsible;
  final String? pendingWith;
  final String? heldWith;
  final String? tabImprint;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  WorkEntrySection({
    this.id,
    required this.workEntryId,
    required this.sectionName,
    required this.sectionData,
    this.personResponsible,
    this.pendingWith,
    this.heldWith,
    this.tabImprint,
    this.status = 'not_started',
    this.createdAt,
    this.updatedAt,
  });

  /// Create from JSON (SQLite or API)
  factory WorkEntrySection.fromJson(Map<String, dynamic> json) {
    return WorkEntrySection(
      id: json['id'] as int?,
      workEntryId: json['work_entry_id'] as int,
      sectionName: json['section_name'] as String,
      sectionData: json['section_data'] is String
          ? jsonDecode(json['section_data'] as String)
          : json['section_data'] as Map<String, dynamic>,
      personResponsible: json['person_responsible'] as String?,
      pendingWith: json['pending_with'] as String?,
      heldWith: json['held_with'] as String?,
      tabImprint: json['tab_imprint'] as String?,
      status: json['status'] as String? ?? 'not_started',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  /// Convert to JSON (for API)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'work_entry_id': workEntryId,
      'section_name': sectionName,
      'section_data': sectionData,
      'person_responsible': personResponsible,
      'pending_with': pendingWith,
      'held_with': heldWith,
      'tab_imprint': tabImprint,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Convert to JSON for SQLite (stringify section_data)
  Map<String, dynamic> toJsonForSQLite() {
    return {
      'id': id,
      'work_entry_id': workEntryId,
      'section_name': sectionName,
      'section_data': jsonEncode(sectionData),
      'person_responsible': personResponsible,
      'pending_with': pendingWith,
      'held_with': heldWith,
      'tab_imprint': tabImprint,
      'status': status,
    };
  }

  /// Convert to JSON for insert (without id, timestamps)
  Map<String, dynamic> toJsonForInsert() {
    return {
      'work_entry_id': workEntryId,
      'section_name': sectionName,
      'section_data': jsonEncode(sectionData),
      'person_responsible': personResponsible,
      'pending_with': pendingWith,
      'held_with': heldWith,
      'tab_imprint': tabImprint,
      'status': status,
    };
  }

  /// Copy with
  WorkEntrySection copyWith({
    int? id,
    int? workEntryId,
    String? sectionName,
    Map<String, dynamic>? sectionData,
    String? personResponsible,
    String? pendingWith,
    String? heldWith,
    String? tabImprint,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WorkEntrySection(
      id: id ?? this.id,
      workEntryId: workEntryId ?? this.workEntryId,
      sectionName: sectionName ?? this.sectionName,
      sectionData: sectionData ?? this.sectionData,
      personResponsible: personResponsible ?? this.personResponsible,
      pendingWith: pendingWith ?? this.pendingWith,
      heldWith: heldWith ?? this.heldWith,
      tabImprint: tabImprint ?? this.tabImprint,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'WorkEntrySection(id: $id, sectionName: $sectionName, status: $status)';
  }
}
