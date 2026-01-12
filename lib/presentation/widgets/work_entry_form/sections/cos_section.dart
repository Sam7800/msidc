import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../section_common_fields.dart';
import '../form_date_picker.dart';
import '../dynamic_table_widget.dart';
import '../critical_bell_icon.dart';

/// COS Section - Change of Scope
/// Radio: N/A or Applicable with 2 tables
class COSSection extends StatefulWidget {
  final int? projectId;
  final Map<String, dynamic> initialData;
  final Function(Map<String, dynamic>) onDataChanged;

  const COSSection({
    super.key,
    required this.projectId,
    required this.initialData,
    required this.onDataChanged,
  });

  @override
  State<COSSection> createState() => _COSSectionState();
}

class _COSSectionState extends State<COSSection> {
  late TextEditingController _personResponsibleController;
  late TextEditingController _postHeldController;
  late TextEditingController _pendingWithController;

  String _applicability = 'na'; // na or applicable
  String _proposalStatus = 'not_started'; // not_started, under_consideration, submitted, approved
  DateTime? _submittedDate;
  List<Map<String, String>> _underConsiderationRows = [];
  List<Map<String, String>> _approvedRows = [];

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
      _applicability = sectionData['applicability'] ?? 'na';

      if (_applicability == 'applicable') {
        _proposalStatus = sectionData['proposal_status'] ?? 'not_started';
        if (sectionData['submitted_date'] != null) {
          _submittedDate = DateTime.parse(sectionData['submitted_date']);
        }
        if (sectionData['under_consideration_items'] is List) {
          _underConsiderationRows = (sectionData['under_consideration_items'] as List)
              .map((item) => Map<String, String>.from(item))
              .toList();
        }
        if (sectionData['approved_items'] is List) {
          _approvedRows = (sectionData['approved_items'] as List)
              .map((item) => Map<String, String>.from(item))
              .toList();
        }
      }
    }
  }

  void _notifyDataChanged() {
    final sectionData = <String, dynamic>{
      'applicability': _applicability,
    };

    if (_applicability == 'applicable') {
      sectionData['proposal_status'] = _proposalStatus;
      sectionData['submitted_date'] = _submittedDate?.toIso8601String();
      sectionData['under_consideration_items'] = _underConsiderationRows;
      sectionData['approved_items'] = _approvedRows;
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
            'COS (Change of Scope):',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          // Not applicable / Applicable
          Row(
            children: [
              Expanded(
                child: RadioListTile<String>(
                  title: const Text('Not applicable'),
                  value: 'na',
                  groupValue: _applicability,
                  onChanged: (value) {
                    setState(() {
                      _applicability = value!;
                      _notifyDataChanged();
                    });
                  },
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              Expanded(
                child: RadioListTile<String>(
                  title: const Text('Applicable'),
                  value: 'applicable',
                  groupValue: _applicability,
                  onChanged: (value) {
                    setState(() {
                      _applicability = value!;
                      _notifyDataChanged();
                    });
                  },
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),

          // If Applicable
          if (_applicability == 'applicable') ...[
            const SizedBox(height: 16),

            // Proposal Not started
            RadioListTile<String>(
              title: const Text('Proposal Not started'),
              value: 'not_started',
              groupValue: _proposalStatus,
              onChanged: (value) {
                setState(() {
                  _proposalStatus = value!;
                  _notifyDataChanged();
                });
              },
              dense: true,
              contentPadding: EdgeInsets.zero,
            ),

            // Proposal under Consideration with bell icon
            Row(
              children: [
                Radio<String>(
                  value: 'under_consideration',
                  groupValue: _proposalStatus,
                  onChanged: (value) {
                    setState(() {
                      _proposalStatus = value!;
                      _notifyDataChanged();
                    });
                  },
                ),
                const Expanded(
                  child: Text(
                    'Proposal under Consideration',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
                CriticalBellIcon(
                  projectId: widget.projectId,
                  sectionName: 'COS',
                  optionName: 'Proposal under Consideration',
                ),
              ],
            ),
            if (_proposalStatus == 'under_consideration') ...[
              const SizedBox(height: 12),
              DynamicTableWidget(
                columnHeaders: const ['Sr. No.', 'Broad Items', 'Amount', 'Reasons'],
                rows: _underConsiderationRows,
                onRowsChanged: (rows) {
                  setState(() {
                    _underConsiderationRows = rows;
                    _notifyDataChanged();
                  });
                },
                addButtonLabel: 'Add Item',
              ),
            ],
            const SizedBox(height: 8),

            // Proposal Submitted: Date with bell icon
            Row(
              children: [
                Radio<String>(
                  value: 'submitted',
                  groupValue: _proposalStatus,
                  onChanged: (value) {
                    setState(() {
                      _proposalStatus = value!;
                      _notifyDataChanged();
                    });
                  },
                ),
                const Text(
                  'Proposal Submitted: Date',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(width: 8),
                CriticalBellIcon(
                  projectId: widget.projectId,
                  sectionName: 'COS',
                  optionName: 'Proposal Submitted',
                ),
              ],
            ),
            if (_proposalStatus == 'submitted') ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 24),
                child: FormDatePicker(
                  label: '',
                  selectedDate: _submittedDate,
                  onDateSelected: (date) {
                    setState(() {
                      _submittedDate = date;
                      _notifyDataChanged();
                    });
                  },
                ),
              ),
            ],
            const SizedBox(height: 8),

            // Proposal Approved
            RadioListTile<String>(
              title: const Text('Proposal Approved'),
              value: 'approved',
              groupValue: _proposalStatus,
              onChanged: (value) {
                setState(() {
                  _proposalStatus = value!;
                  _notifyDataChanged();
                });
              },
              dense: true,
              contentPadding: EdgeInsets.zero,
            ),
            if (_proposalStatus == 'approved') ...[
              const SizedBox(height: 12),
              DynamicTableWidget(
                columnHeaders: const ['Sr. No.', 'Broad Items', 'Amount', 'Reasons'],
                rows: _approvedRows,
                onRowsChanged: (rows) {
                  setState(() {
                    _approvedRows = rows;
                    _notifyDataChanged();
                  });
                },
                addButtonLabel: 'Add Item',
              ),
            ],
          ],

          const SizedBox(height: 24),

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
