import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../section_common_fields.dart';
import '../form_date_picker.dart';
import '../critical_bell_icon.dart';

/// LA Section - Land Acquisition
/// Radio: N/A or Applicable with status checkboxes, area field and conditional fields
class LASection extends StatefulWidget {
  final int? projectId;
  final Map<String, dynamic> initialData;
  final Function(Map<String, dynamic>) onDataChanged;
  final bool isEditMode;

  const LASection({
    super.key,
    required this.projectId,
    required this.initialData,
    required this.onDataChanged,
    required this.isEditMode,
  });

  @override
  State<LASection> createState() => _LASectionState();
}

class _LASectionState extends State<LASection> {
  late TextEditingController _personResponsibleController;
  late TextEditingController _postHeldController;
  late TextEditingController _pendingWithController;
  late TextEditingController _totalAreaController;
  late TextEditingController _acquiredAreaController;
  late TextEditingController _remarksController;

  String _applicability = 'na'; // na or applicable
  String _selectedStatus = 'not_started';
  DateTime? _submissionDate;
  late TextEditingController _statusController;

  final List<Map<String, String>> _statusOptions = [
    {'value': 'not_started', 'label': 'Proposal Not started'},
    {'value': 'under_preparation', 'label': 'Proposal under preparation'},
    {'value': 'submitted', 'label': 'Proposal Submitted'},
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
    _totalAreaController = TextEditingController();
    _acquiredAreaController = TextEditingController();
    _statusController = TextEditingController();
    _remarksController = TextEditingController();
  }

  void _loadInitialData() {
    if (widget.initialData.isNotEmpty) {
      _personResponsibleController.text =
          widget.initialData['person_responsible'] ?? '';
      _postHeldController.text = widget.initialData['post_held'] ?? '';
      _pendingWithController.text = widget.initialData['pending_with'] ?? '';

      final sectionData = widget.initialData['section_data'] ?? {};
      _applicability = sectionData['applicability'] ?? 'na';
      _selectedStatus = sectionData['status'] ?? 'not_started';

      if (_applicability == 'applicable') {
        _totalAreaController.text = sectionData['total_area'] ?? '';
        _acquiredAreaController.text = sectionData['acquired_area'] ?? '';
        _statusController.text = sectionData['status_text'] ?? '';
        _remarksController.text = sectionData['remarks'] ?? '';
        if (sectionData['submission_date'] != null) {
          _submissionDate = DateTime.parse(sectionData['submission_date']);
        }
      }
    }
  }

  void _notifyDataChanged() {
    final sectionData = <String, dynamic>{
      'applicability': _applicability,
    };

    if (_applicability == 'applicable') {
      sectionData['status'] = _selectedStatus;
      sectionData['total_area'] = _totalAreaController.text;
      sectionData['acquired_area'] = _acquiredAreaController.text;
      sectionData['submission_date'] = _submissionDate?.toIso8601String();
      sectionData['status_text'] = _statusController.text;
      sectionData['remarks'] = _remarksController.text;
    }

    widget.onDataChanged({
      'person_responsible': _personResponsibleController.text,
      'post_held': _postHeldController.text,
      'pending_with': _pendingWithController.text,
      'section_data': sectionData,
    });
  }

  @override
  void dispose() {
    _personResponsibleController.dispose();
    _postHeldController.dispose();
    _pendingWithController.dispose();
    _totalAreaController.dispose();
    _acquiredAreaController.dispose();
    _statusController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Applicability Selection
          const Text(
            'Applicability',
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
                child: RadioListTile<String>(
                  title: const Text('N/A'),
                  value: 'na',
                  groupValue: _applicability,
                  onChanged: widget.isEditMode ? (value) {
                    setState(() {
                      _applicability = value!;
                      _notifyDataChanged();
                    });
                  } : null,
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              Expanded(
                child: RadioListTile<String>(
                  title: const Text('Applicable'),
                  value: 'applicable',
                  groupValue: _applicability,
                  onChanged: widget.isEditMode ? (value) {
                    setState(() {
                      _applicability = value!;
                      _notifyDataChanged();
                    });
                  } : null,
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Conditional Fields (if applicable)
          if (_applicability == 'applicable') ...[
            // Status Selection
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
              final showBellIcon = option['value'] == 'under_preparation'; // Only show bell on Proposal under preparation
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Checkbox(
                      value: isSelected,
                      onChanged: widget.isEditMode ? (checked) {
                        if (checked == true) {
                          setState(() {
                            _selectedStatus = option['value']!;
                            _notifyDataChanged();
                          });
                        }
                      } : null,
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: widget.isEditMode ? () {
                          setState(() {
                            _selectedStatus = option['value']!;
                            _notifyDataChanged();
                          });
                        } : null,
                        child: Text(
                          option['label']!,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                    if (showBellIcon)
                      CriticalBellIcon(
                        projectId: widget.projectId,
                        sectionName: 'LA',
                        optionName: option['label']!,
                      ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 24),

            // Show Date picker only when Proposal Submitted is selected
            if (_selectedStatus == 'submitted') ...[
              FormDatePicker(
                label: 'Proposal Submitted Date',
                selectedDate: _submissionDate,
                enabled: widget.isEditMode,
                onDateSelected: (date) {
                  setState(() {
                    _submissionDate = date;
                    _notifyDataChanged();
                  });
                },
              ),
              const SizedBox(height: 16),
            ],

            TextFormField(
              controller: _statusController,
              enabled: widget.isEditMode,
              onChanged: (_) => _notifyDataChanged(),
              decoration: const InputDecoration(
                labelText: 'Status',
                hintText: 'Enter current status',
                prefixIcon: Icon(Icons.info_outline, size: 20),
                border: OutlineInputBorder(),
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
