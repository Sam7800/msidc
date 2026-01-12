import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../section_common_fields.dart';
import '../form_date_picker.dart';
import '../critical_bell_icon.dart';

/// CSD Section - Common Set of Deviations
/// Status checkboxes with bell icons + date
class CSDSection extends StatefulWidget {
  final int? projectId;
  final Map<String, dynamic> initialData;
  final Function(Map<String, dynamic>) onDataChanged;

  const CSDSection({
    super.key,
    required this.projectId,
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

  String _selectedStatus = 'not_applicable';
  DateTime? _submissionDate;

  final List<Map<String, String>> _statusOptions = [
    {'value': 'not_applicable', 'label': 'Not Applicable'},
    {'value': 'queries_in_progress', 'label': 'Queries reply in progress'},
    {'value': 'replies_submitted', 'label': 'Replies submitted for approval'},
    {'value': 'approved', 'label': 'Approved'},
  ];

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
      _selectedStatus = sectionData['status'] ?? 'not_applicable';
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
        'status': _selectedStatus,
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

          ..._statusOptions.map((option) {
            final isSelected = _selectedStatus == option['value'];
            // Show bell on "Queries reply in progress" and "Replies submitted for approval"
            final showBellIcon = option['value'] == 'queries_in_progress' ||
                                 option['value'] == 'replies_submitted';
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Checkbox(
                    value: isSelected,
                    onChanged: (checked) {
                      if (checked == true) {
                        setState(() {
                          _selectedStatus = option['value']!;
                          _notifyDataChanged();
                        });
                      }
                    },
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _selectedStatus = option['value']!;
                          _notifyDataChanged();
                        });
                      },
                      child: Text(
                        option['label']!,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                  if (showBellIcon)
                    CriticalBellIcon(
                      projectId: widget.projectId,
                      sectionName: 'CSD',
                      optionName: option['label']!,
                    ),
                ],
              ),
            );
          }),

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
