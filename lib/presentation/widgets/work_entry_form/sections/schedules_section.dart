import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../section_common_fields.dart';
import '../form_date_picker.dart';

/// Schedules Section
/// Status checkboxes with conditional date picker
class SchedulesSection extends StatefulWidget {
  final Map<String, dynamic> initialData;
  final Function(Map<String, dynamic>) onDataChanged;

  const SchedulesSection({
    super.key,
    required this.initialData,
    required this.onDataChanged,
  });

  @override
  State<SchedulesSection> createState() => _SchedulesSectionState();
}

class _SchedulesSectionState extends State<SchedulesSection> {
  late TextEditingController _personResponsibleController;
  late TextEditingController _postHeldController;
  late TextEditingController _pendingWithController;

  String _selectedStatus = 'not_started';
  DateTime? _likelyCompletionDate;

  final List<Map<String, String>> _statusOptions = [
    {'value': 'not_started', 'label': 'Not Started'},
    {'value': 'in_progress', 'label': 'In Progress'},
    {'value': 'completed', 'label': 'Completed'},
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
            return CheckboxListTile(
              title: Text(option['label']!),
              value: isSelected,
              onChanged: (checked) {
                if (checked == true) {
                  setState(() {
                    _selectedStatus = option['value']!;
                    _notifyDataChanged();
                  });
                }
              },
              dense: true,
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
            );
          }),

          // Conditional: Likely Completion Date (only if in_progress)
          if (_selectedStatus == 'in_progress') ...[
            const SizedBox(height: 24),
            FormDatePicker(
              label: 'Likely Completion Date',
              selectedDate: _likelyCompletionDate,
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
          ),
        ],
      ),
    );
  }
}
