import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../section_common_fields.dart';
import '../form_date_picker.dart';

/// CSD Section - Common Set of Deviations
/// Multiple checkboxes + date
class CSDSection extends StatefulWidget {
  final Map<String, dynamic> initialData;
  final Function(Map<String, dynamic>) onDataChanged;

  const CSDSection({
    super.key,
    required this.initialData,
    required this.onDataChanged,
  });

  @override
  State<CSDSection> createState() => _CSDSectionState();
}

class _CSDSectionState extends State<CSDSection> {
  late TextEditingController _personResponsibleController;
  late TextEditingController _postHeldController;
  late TextEditingController _pendingWithController;

  bool _isApplicable = false;
  bool _isSubmitted = false;
  bool _isApproved = false;
  DateTime? _submissionDate;

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
  }

  void _loadInitialData() {
    if (widget.initialData.isNotEmpty) {
      _personResponsibleController.text =
          widget.initialData['person_responsible'] ?? '';
      _postHeldController.text = widget.initialData['post_held'] ?? '';
      _pendingWithController.text = widget.initialData['pending_with'] ?? '';

      final sectionData = widget.initialData['section_data'] ?? {};
      _isApplicable = sectionData['is_applicable'] ?? false;
      _isSubmitted = sectionData['is_submitted'] ?? false;
      _isApproved = sectionData['is_approved'] ?? false;
      if (sectionData['submission_date'] != null) {
        _submissionDate = DateTime.parse(sectionData['submission_date']);
      }
    }
  }

  void _notifyDataChanged() {
    widget.onDataChanged({
      'person_responsible': _personResponsibleController.text,
      'post_held': _postHeldController.text,
      'pending_with': _pendingWithController.text,
      'section_data': {
        'is_applicable': _isApplicable,
        'is_submitted': _isSubmitted,
        'is_approved': _isApproved,
        'submission_date': _submissionDate?.toIso8601String(),
      },
    });
  }

  @override
  void dispose() {
    _personResponsibleController.dispose();
    _postHeldController.dispose();
    _pendingWithController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'CSD Status',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),

          CheckboxListTile(
            title: const Text('Applicable'),
            value: _isApplicable,
            onChanged: (value) {
              setState(() {
                _isApplicable = value ?? false;
                _notifyDataChanged();
              });
            },
            dense: true,
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
          ),

          CheckboxListTile(
            title: const Text('Submitted'),
            value: _isSubmitted,
            onChanged: (value) {
              setState(() {
                _isSubmitted = value ?? false;
                _notifyDataChanged();
              });
            },
            dense: true,
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
          ),

          CheckboxListTile(
            title: const Text('Approved'),
            value: _isApproved,
            onChanged: (value) {
              setState(() {
                _isApproved = value ?? false;
                _notifyDataChanged();
              });
            },
            dense: true,
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
          ),

          const SizedBox(height: 24),

          FormDatePicker(
            label: 'Submission Date',
            selectedDate: _submissionDate,
            onDateSelected: (date) {
              setState(() {
                _submissionDate = date;
                _notifyDataChanged();
              });
            },
          ),

          // Common Fields
          SectionCommonFields(
            personResponsibleController: _personResponsibleController,
            postHeldController: _postHeldController,
            pendingWithController: _pendingWithController,
          ),
        ],
      ),
    );
  }
}
