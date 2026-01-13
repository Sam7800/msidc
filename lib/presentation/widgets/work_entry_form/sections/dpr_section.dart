import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../section_common_fields.dart';
import '../form_date_picker.dart';
import '../critical_bell_icon.dart';

/// DPR Section - Detailed Project Report
/// Checkboxes (exclusive - one at a time) with conditional date picker
class DPRSection extends StatefulWidget {
  final int? projectId;
  final bool isEditMode;
  final Map<String, dynamic> initialData;
  final Function(Map<String, dynamic>) onDataChanged;

  const DPRSection({
    super.key,
    required this.projectId,
    required this.isEditMode,
    required this.initialData,
    required this.onDataChanged,
  });

  @override
  State<DPRSection> createState() => _DPRSectionState();
}

class _DPRSectionState extends State<DPRSection> {
  late TextEditingController _personResponsibleController;
  late TextEditingController _postHeldController;
  late TextEditingController _pendingWithController;

  String _selectedStatus = 'not_started';
  DateTime? _likelyCompletionDate;

  final List<Map<String, String>> _statusOptions = [
    {'value': 'not_started', 'label': 'Not Started'},
    {'value': 'in_progress', 'label': 'In Progress'},
    {'value': 'submitted', 'label': 'Submitted'},
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
      _selectedStatus = sectionData['status'] ?? 'not_started';
      if (sectionData['likely_completion_date'] != null) {
        _likelyCompletionDate =
            DateTime.parse(sectionData['likely_completion_date']);
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
        if (_selectedStatus == 'in_progress' && _likelyCompletionDate != null)
          'likely_completion_date': _likelyCompletionDate!.toIso8601String(),
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
          // Status Selection (Checkboxes - exclusive)
          const Text(
            'Status',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),

          ..._statusOptions.map((option) {
            final isSelected = _selectedStatus == option['value'];
            final showBellIcon = option['value'] == 'submitted'; // Only show bell on Submitted
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Checkbox(
                    value: isSelected,
                    onChanged: widget.isEditMode
                        ? (checked) {
                            if (checked == true) {
                              setState(() {
                                _selectedStatus = option['value']!;
                                _notifyDataChanged();
                              });
                            }
                          }
                        : null,
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: widget.isEditMode
                          ? () {
                              setState(() {
                                _selectedStatus = option['value']!;
                                _notifyDataChanged();
                              });
                            }
                          : null,
                      child: Text(
                        option['label']!,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                  if (showBellIcon)
                    CriticalBellIcon(
                      projectId: widget.projectId,
                      sectionName: 'DPR',
                      optionName: option['label']!,
                    ),
                ],
              ),
            );
          }),

          // Conditional: Likely Completion Date (only if in_progress)
          if (_selectedStatus == 'in_progress') ...[
            const SizedBox(height: 24),
            FormDatePicker(
              label: 'Likely Completion Date',
              selectedDate: _likelyCompletionDate,
              enabled: widget.isEditMode,
              onDateSelected: (date) {
                setState(() {
                  _likelyCompletionDate = date;
                  _notifyDataChanged();
                });
              },
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
