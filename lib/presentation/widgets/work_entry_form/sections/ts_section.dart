import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../section_common_fields.dart';
import '../form_date_picker.dart';
import '../dynamic_table_widget.dart';
import '../critical_bell_icon.dart';

/// TS Section - Technical Sanction
/// Radio: Awaited/Accorded with status and conditional table
class TSSection extends StatefulWidget {
  final int? projectId;
  final Map<String, dynamic> initialData;
  final Function(Map<String, dynamic>) onDataChanged;

  const TSSection({
    super.key,
    required this.projectId,
    required this.initialData,
    required this.onDataChanged,
  });

  @override
  State<TSSection> createState() => _TSSectionState();
}

class _TSSectionState extends State<TSSection> {
  late TextEditingController _personResponsibleController;
  late TextEditingController _postHeldController;
  late TextEditingController _pendingWithController;
  late TextEditingController _statusController;
  late TextEditingController _tsNoController;
  late TextEditingController _amountController;

  String _selectedType = 'awaited'; // awaited or accorded
  String _selectedStatus = 'not_started'; // Status when awaited: not_started or in_progress
  DateTime? _likelySubmissionDate;
  DateTime? _dateAccorded;
  List<Map<String, String>> _tableRows = [];

  final List<Map<String, String>> _awaitedStatusOptions = [
    {'value': 'not_started', 'label': 'Not started'},
    {'value': 'in_progress', 'label': 'In Progress'},
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
    _statusController = TextEditingController();
    _tsNoController = TextEditingController();
    _amountController = TextEditingController();
  }

  void _loadInitialData() {
    if (widget.initialData.isNotEmpty) {
      _personResponsibleController.text =
          widget.initialData['person_responsible'] ?? '';
      _postHeldController.text = widget.initialData['post_held'] ?? '';
      _pendingWithController.text = widget.initialData['pending_with'] ?? '';

      final sectionData = widget.initialData['section_data'] ?? {};
      _selectedType = sectionData['type'] ?? 'awaited';
      _selectedStatus = sectionData['status'] ?? 'not_started';

      if (_selectedType == 'awaited') {
        _statusController.text = sectionData['status_text'] ?? '';
        if (sectionData['likely_submission_date'] != null) {
          _likelySubmissionDate = DateTime.parse(sectionData['likely_submission_date']);
        }
      } else {
        _amountController.text = sectionData['amount'] ?? '';
        _tsNoController.text = sectionData['ts_no'] ?? '';
        if (sectionData['date'] != null) {
          _dateAccorded = DateTime.parse(sectionData['date']);
        }
        if (sectionData['items'] is List) {
          _tableRows = (sectionData['items'] as List)
              .map((item) => Map<String, String>.from(item))
              .toList();
        }
      }
    }
  }

  void _notifyDataChanged() {
    final sectionData = <String, dynamic>{
      'type': _selectedType,
    };

    if (_selectedType == 'awaited') {
      sectionData['status'] = _selectedStatus;
      sectionData['likely_submission_date'] = _likelySubmissionDate?.toIso8601String();
      sectionData['status_text'] = _statusController.text;
    } else {
      sectionData['amount'] = _amountController.text;
      sectionData['ts_no'] = _tsNoController.text;
      sectionData['date'] = _dateAccorded?.toIso8601String();
      sectionData['items'] = _tableRows;
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
    _statusController.dispose();
    _tsNoController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Type Selection (Radio Buttons)
          const Text(
            'Status',
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
                  title: const Text('Awaited'),
                  value: 'awaited',
                  groupValue: _selectedType,
                  onChanged: (value) {
                    setState(() {
                      _selectedType = value!;
                      _notifyDataChanged();
                    });
                  },
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              Expanded(
                child: RadioListTile<String>(
                  title: const Text('Accorded'),
                  value: 'accorded',
                  groupValue: _selectedType,
                  onChanged: (value) {
                    setState(() {
                      _selectedType = value!;
                      _notifyDataChanged();
                    });
                  },
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Conditional Fields based on type
          if (_selectedType == 'awaited') ...[
            // Status Selection for Awaited
            ..._awaitedStatusOptions.map((option) {
              final isSelected = _selectedStatus == option['value'];
              final showBellIcon = option['value'] == 'in_progress'; // Only show bell on In Progress
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
                        sectionName: 'TS',
                        optionName: option['label']!,
                      ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 24),

            // Show Likely Date picker only when In Progress is selected
            if (_selectedStatus == 'in_progress') ...[
              FormDatePicker(
                label: 'Likely Date of Submission',
                selectedDate: _likelySubmissionDate,
                onDateSelected: (date) {
                  setState(() {
                    _likelySubmissionDate = date;
                    _notifyDataChanged();
                  });
                },
              ),
              const SizedBox(height: 16),
            ],

            // Status textfield (always show)
            TextFormField(
              controller: _statusController,
              onChanged: (_) => _notifyDataChanged(),
              decoration: const InputDecoration(
                labelText: 'Status',
                hintText: 'Enter current status',
                prefixIcon: Icon(Icons.info_outline, size: 20),
                border: OutlineInputBorder(),
              ),
            ),
          ] else ...[
            // Accorded Fields
            TextFormField(
              controller: _amountController,
              onChanged: (_) => _notifyDataChanged(),
              decoration: const InputDecoration(
                labelText: 'Amount (Rs. Crore / Lakhs)',
                hintText: 'e.g., 450 Lakhs or 45 Crore',
                prefixIcon: Icon(Icons.currency_rupee, size: 20),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _tsNoController,
              onChanged: (_) => _notifyDataChanged(),
              decoration: const InputDecoration(
                labelText: 'TS No.',
                hintText: 'e.g., "TS/2026/001"',
                prefixIcon: Icon(Icons.confirmation_number, size: 20),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            FormDatePicker(
              label: 'Date',
              selectedDate: _dateAccorded,
              onDateSelected: (date) {
                setState(() {
                  _dateAccorded = date;
                  _notifyDataChanged();
                });
              },
            ),
            const SizedBox(height: 24),

            // Detailed Scope Table
            const Text(
              'Detailed Scope',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            DynamicTableWidget(
              columnHeaders: const ['Sr. No.', 'Broad Items', 'Amount'],
              rows: _tableRows,
              onRowsChanged: (rows) {
                setState(() {
                  _tableRows = rows;
                  _notifyDataChanged();
                });
              },
              addButtonLabel: 'Add Item',
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
