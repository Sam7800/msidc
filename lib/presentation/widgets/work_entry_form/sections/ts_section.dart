import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../section_common_fields.dart';
import '../form_date_picker.dart';
import '../dynamic_table_widget.dart';

/// TS Section - Technical Sanction
/// Radio: Awaited/Accorded with conditional table
class TSSection extends StatefulWidget {
  final Map<String, dynamic> initialData;
  final Function(Map<String, dynamic>) onDataChanged;

  const TSSection({
    super.key,
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
  late TextEditingController _pendingWithWhomController;
  late TextEditingController _tsNoController;

  String _selectedType = 'awaited'; // awaited or accorded
  DateTime? _dateOfProposal;
  DateTime? _dateAccorded;
  List<Map<String, String>> _tableRows = [];

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
    _pendingWithWhomController = TextEditingController();
    _tsNoController = TextEditingController();
  }

  void _loadInitialData() {
    if (widget.initialData.isNotEmpty) {
      _personResponsibleController.text =
          widget.initialData['person_responsible'] ?? '';
      _postHeldController.text = widget.initialData['post_held'] ?? '';
      _pendingWithController.text = widget.initialData['pending_with'] ?? '';

      final sectionData = widget.initialData['section_data'] ?? {};
      _selectedType = sectionData['type'] ?? 'awaited';

      if (_selectedType == 'awaited') {
        _pendingWithWhomController.text =
            sectionData['pending_with_whom'] ?? '';
        if (sectionData['date_of_proposal'] != null) {
          _dateOfProposal = DateTime.parse(sectionData['date_of_proposal']);
        }
      } else {
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
      sectionData['date_of_proposal'] = _dateOfProposal?.toIso8601String();
      sectionData['pending_with_whom'] = _pendingWithWhomController.text;
    } else {
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
    _pendingWithWhomController.dispose();
    _tsNoController.dispose();
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
            // Awaited Fields
            FormDatePicker(
              label: 'Date of Proposal',
              selectedDate: _dateOfProposal,
              onDateSelected: (date) {
                setState(() {
                  _dateOfProposal = date;
                  _notifyDataChanged();
                });
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _pendingWithWhomController,
              onChanged: (_) => _notifyDataChanged(),
              decoration: const InputDecoration(
                labelText: 'Pending With Whom',
                hintText: 'e.g., "Director"',
                prefixIcon: Icon(Icons.person_search, size: 20),
                border: OutlineInputBorder(),
              ),
            ),
          ] else ...[
            // Accorded Fields
            TextFormField(
              controller: _tsNoController,
              onChanged: (_) => _notifyDataChanged(),
              decoration: const InputDecoration(
                labelText: 'TS Number',
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

            // Sanctioned Items Table
            const Text(
              'Sanctioned Items',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            DynamicTableWidget(
              columnHeaders: const ['Sr. No.', 'Item Description', 'Amount (Lakhs)'],
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
