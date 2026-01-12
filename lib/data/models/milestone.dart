/// Milestone model - Project milestones (MS-I to MS-V)
class Milestone {
  final int? id;
  final int workEntryId;
  final String milestoneName; // MS-I, MS-II, MS-III, MS-IV, MS-V
  final int? periodMonths;
  final double? physicalTargetPercent;
  final double? financialTargetAmount;
  final double? physicalAchievedPercent;
  final double? financialAchievedAmount;
  final double? varianceAmount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Milestone({
    this.id,
    required this.workEntryId,
    required this.milestoneName,
    this.periodMonths,
    this.physicalTargetPercent,
    this.financialTargetAmount,
    this.physicalAchievedPercent,
    this.financialAchievedAmount,
    this.varianceAmount,
    this.createdAt,
    this.updatedAt,
  });

  /// Create from JSON (SQLite or API)
  factory Milestone.fromJson(Map<String, dynamic> json) {
    return Milestone(
      id: json['id'] as int?,
      workEntryId: json['work_entry_id'] as int,
      milestoneName: json['milestone_name'] as String,
      periodMonths: json['period_months'] as int?,
      physicalTargetPercent: json['physical_target_percent'] != null
          ? (json['physical_target_percent'] as num).toDouble()
          : null,
      financialTargetAmount: json['financial_target_amount'] != null
          ? (json['financial_target_amount'] as num).toDouble()
          : null,
      physicalAchievedPercent: json['physical_achieved_percent'] != null
          ? (json['physical_achieved_percent'] as num).toDouble()
          : null,
      financialAchievedAmount: json['financial_achieved_amount'] != null
          ? (json['financial_achieved_amount'] as num).toDouble()
          : null,
      varianceAmount: json['variance_amount'] != null
          ? (json['variance_amount'] as num).toDouble()
          : null,
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
      'work_entry_id': workEntryId,
      'milestone_name': milestoneName,
      'period_months': periodMonths,
      'physical_target_percent': physicalTargetPercent,
      'financial_target_amount': financialTargetAmount,
      'physical_achieved_percent': physicalAchievedPercent,
      'financial_achieved_amount': financialAchievedAmount,
      'variance_amount': varianceAmount,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Convert to JSON for insert (without id, timestamps)
  Map<String, dynamic> toJsonForInsert() {
    return {
      'work_entry_id': workEntryId,
      'milestone_name': milestoneName,
      'period_months': periodMonths,
      'physical_target_percent': physicalTargetPercent,
      'financial_target_amount': financialTargetAmount,
      'physical_achieved_percent': physicalAchievedPercent,
      'financial_achieved_amount': financialAchievedAmount,
      'variance_amount': varianceAmount,
    };
  }

  /// Copy with
  Milestone copyWith({
    int? id,
    int? workEntryId,
    String? milestoneName,
    int? periodMonths,
    double? physicalTargetPercent,
    double? financialTargetAmount,
    double? physicalAchievedPercent,
    double? financialAchievedAmount,
    double? varianceAmount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Milestone(
      id: id ?? this.id,
      workEntryId: workEntryId ?? this.workEntryId,
      milestoneName: milestoneName ?? this.milestoneName,
      periodMonths: periodMonths ?? this.periodMonths,
      physicalTargetPercent: physicalTargetPercent ?? this.physicalTargetPercent,
      financialTargetAmount: financialTargetAmount ?? this.financialTargetAmount,
      physicalAchievedPercent:
          physicalAchievedPercent ?? this.physicalAchievedPercent,
      financialAchievedAmount:
          financialAchievedAmount ?? this.financialAchievedAmount,
      varianceAmount: varianceAmount ?? this.varianceAmount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Milestone(id: $id, name: $milestoneName, physical: $physicalAchievedPercent%)';
  }
}
