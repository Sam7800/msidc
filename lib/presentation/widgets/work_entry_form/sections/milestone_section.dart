import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../section_common_fields.dart';

/// Milestone Section (Reusable for MS-I to MS-V)
/// Period, targets, achievements
class MilestoneSection extends StatefulWidget {
  final String milestoneName; // MS-I, MS-II, MS-III, MS-IV, MS-V
  final bool isEditMode;
  final Map<String, dynamic> initialData;
  final Function(Map<String, dynamic>) onDataChanged;

  const MilestoneSection({
    super.key,
    required this.milestoneName,
    required this.isEditMode,
    required this.initialData,
    required this.onDataChanged,
  });

  @override
  State<MilestoneSection> createState() => _MilestoneSectionState();
}

class _MilestoneSectionState extends State<MilestoneSection> {
  late TextEditingController _personResponsibleController;
  late TextEditingController _postHeldController;
  late TextEditingController _pendingWithController;
  late TextEditingController _periodController;
  late TextEditingController _physicalTargetController;
  late TextEditingController _financialTargetController;
  late TextEditingController _physicalAchievedController;
  late TextEditingController _financialAchievedController;

  double? _variance;

  @override
  void initState() {
    super.initState();
    _initControllers();
    _loadInitialData();
  }

  void _initControllers() {
    _personResponsibleController = TextEditingController();
    _postHeldController = TextEditingController();
    _pendingWithController = TextEditingController();
    _periodController = TextEditingController();
    _physicalTargetController = TextEditingController();
    _financialTargetController = TextEditingController();
    _physicalAchievedController = TextEditingController();
    _financialAchievedController = TextEditingController();
  }

  void _loadInitialData() {
    if (widget.initialData.isNotEmpty) {
      _personResponsibleController.text =
          widget.initialData['person_responsible'] ?? '';
      _postHeldController.text = widget.initialData['post_held'] ?? '';
      _pendingWithController.text = widget.initialData['pending_with'] ?? '';

      final sectionData = widget.initialData['section_data'] ?? {};
      _periodController.text = sectionData['period_months']?.toString() ?? '';
      _physicalTargetController.text = sectionData['physical_target']?.toString() ?? '';
      _financialTargetController.text = sectionData['financial_target']?.toString() ?? '';
      _physicalAchievedController.text = sectionData['physical_achieved']?.toString() ?? '';
      _financialAchievedController.text = sectionData['financial_achieved']?.toString() ?? '';
      _variance = sectionData['variance'];
    }
  }

  void _calculateVariance() {
    final target = double.tryParse(_financialTargetController.text) ?? 0;
    final achieved = double.tryParse(_financialAchievedController.text) ?? 0;
    _variance = achieved - target;
  }

  void _notifyDataChanged() {
    _calculateVariance();

    widget.onDataChanged({
      'person_responsible': _personResponsibleController.text,
      'post_held': _postHeldController.text,
      'pending_with': _pendingWithController.text,
      'section_data': {
        'milestone_name': widget.milestoneName,
        'period_months': _periodController.text,
        'physical_target': _physicalTargetController.text,
        'financial_target': _financialTargetController.text,
        'physical_achieved': _physicalAchievedController.text,
        'financial_achieved': _financialAchievedController.text,
        'variance': _variance,
      },
    });
  }

  @override
  void dispose() {
    _personResponsibleController.dispose();
    _postHeldController.dispose();
    _pendingWithController.dispose();
    _periodController.dispose();
    _physicalTargetController.dispose();
    _financialTargetController.dispose();
    _physicalAchievedController.dispose();
    _financialAchievedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _periodController,
            onChanged: (_) => _notifyDataChanged(),
            decoration: const InputDecoration(
              labelText: 'Period (in months)',
              hintText: 'e.g., 6',
              prefixIcon: Icon(Icons.calendar_month, size: 20),
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            enabled: widget.isEditMode,
          ),
          const SizedBox(height: 24),

          // Targets Section
          const Text(
            'Targets',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _physicalTargetController,
                  onChanged: (_) => _notifyDataChanged(),
                  decoration: const InputDecoration(
                    labelText: 'Physical Target (%)',
                    hintText: '0-100',
                    prefixIcon: Icon(Icons.percent, size: 20),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  enabled: widget.isEditMode,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _financialTargetController,
                  onChanged: (_) => _notifyDataChanged(),
                  decoration: const InputDecoration(
                    labelText: 'Financial Target (Lakhs)',
                    hintText: 'Amount',
                    prefixIcon: Icon(Icons.currency_rupee, size: 20),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  enabled: widget.isEditMode,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Achievements Section
          const Text(
            'Achievements',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _physicalAchievedController,
                  onChanged: (_) => _notifyDataChanged(),
                  decoration: const InputDecoration(
                    labelText: 'Physical Achieved (%)',
                    hintText: '0-100',
                    prefixIcon: Icon(Icons.percent, size: 20),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  enabled: widget.isEditMode,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _financialAchievedController,
                  onChanged: (_) => _notifyDataChanged(),
                  decoration: const InputDecoration(
                    labelText: 'Financial Achieved (Lakhs)',
                    hintText: 'Amount',
                    prefixIcon: Icon(Icons.currency_rupee, size: 20),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  enabled: widget.isEditMode,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Variance Display
          if (_variance != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: (_variance! >= 0) ? Colors.green.shade50 : Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: (_variance! >= 0) ? Colors.green : Colors.red,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    (_variance! >= 0) ? Icons.trending_up : Icons.trending_down,
                    color: (_variance! >= 0) ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Variance: ${_variance!.toStringAsFixed(2)} Lakhs',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: (_variance! >= 0) ? Colors.green.shade900 : Colors.red.shade900,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Common Fields
          SectionCommonFields(
            personResponsibleController: _personResponsibleController,
            postHeldController: _postHeldController,
            pendingWithController: _pendingWithController,
            enabled: widget.isEditMode,
            onChanged: _notifyDataChanged,
          ),
        ],
      ),
    );
  }
}
