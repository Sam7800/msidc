import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../section_common_fields.dart';
import '../dynamic_table_widget.dart';
import '../critical_bell_icon.dart';

/// Audit Para Section
/// Radio: Not applicable or Applicable with tables
class AuditParaSection extends StatefulWidget {
  final int? projectId;
  final Map<String, dynamic> initialData;
  final Function(Map<String, dynamic>) onDataChanged;
  final bool isEditMode;

  const AuditParaSection({
    super.key,
    required this.projectId,
    required this.initialData,
    required this.onDataChanged,
    required this.isEditMode,
  });

  @override
  State<AuditParaSection> createState() => _AuditParaSectionState();
}

class _AuditParaSectionState extends State<AuditParaSection> {
  late TextEditingController _personResponsibleController;
  late TextEditingController _postHeldController;
  late TextEditingController _pendingWithController;
  late TextEditingController _draftParasController;
  late TextEditingController _responsiblePersonController;

  String _applicability = 'na'; // na or applicable
  List<Map<String, String>> _detailsOfParasRows = [];
  List<Map<String, String>> _repliesSubmittedRows = [];
  List<Map<String, String>> _parasClosedRows = [];

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
    _draftParasController = TextEditingController();
    _responsiblePersonController = TextEditingController();
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
        _draftParasController.text = sectionData['draft_paras'] ?? '';
        _responsiblePersonController.text = sectionData['responsible_person'] ?? '';

        if (sectionData['details_of_paras'] is List) {
          _detailsOfParasRows = (sectionData['details_of_paras'] as List)
              .map((item) => Map<String, String>.from(item))
              .toList();
        }
        if (sectionData['replies_submitted'] is List) {
          _repliesSubmittedRows = (sectionData['replies_submitted'] as List)
              .map((item) => Map<String, String>.from(item))
              .toList();
        }
        if (sectionData['paras_closed'] is List) {
          _parasClosedRows = (sectionData['paras_closed'] as List)
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
      sectionData['draft_paras'] = _draftParasController.text;
      sectionData['responsible_person'] = _responsiblePersonController.text;
      sectionData['details_of_paras'] = _detailsOfParasRows;
      sectionData['replies_submitted'] = _repliesSubmittedRows;
      sectionData['paras_closed'] = _parasClosedRows;
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
    _draftParasController.dispose();
    _responsiblePersonController.dispose();
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
            'Audit Para:',
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

          // If Applicable
          if (_applicability == 'applicable') ...[
            const SizedBox(height: 16),

            // # of draft paras
            const Text(
              '# of draft paras',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _draftParasController,
              enabled: widget.isEditMode,
              onChanged: (_) => _notifyDataChanged(),
              decoration: const InputDecoration(
                hintText: 'Enter number',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            // Details of paras
            const Text(
              'Details of paras',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            DynamicTableWidget(
              columnHeaders: const ['Sr. No.', 'Para Short Description', 'Date of issue', 'Remarks'],
              rows: _detailsOfParasRows,
              enabled: widget.isEditMode,
              onRowsChanged: (rows) {
                setState(() {
                  _detailsOfParasRows = rows;
                  _notifyDataChanged();
                });
              },
              addButtonLabel: 'Add Para',
            ),
            const SizedBox(height: 16),

            // Responsible person for replies
            const Text(
              'Responsible person for replies',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _responsiblePersonController,
              enabled: widget.isEditMode,
              onChanged: (_) => _notifyDataChanged(),
              decoration: const InputDecoration(
                hintText: 'Enter name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Replies Submitted with bell icon
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Replies Submitted: # and Dates',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                CriticalBellIcon(
                  projectId: widget.projectId,
                  sectionName: 'Audit Para',
                  optionName: 'Replies Submitted',
                ),
              ],
            ),
            const SizedBox(height: 12),
            DynamicTableWidget(
              columnHeaders: const ['Sr. No.', 'Para Short Description', 'Date of submission', 'Status'],
              rows: _repliesSubmittedRows,
              enabled: widget.isEditMode,
              onRowsChanged: (rows) {
                setState(() {
                  _repliesSubmittedRows = rows;
                  _notifyDataChanged();
                });
              },
              addButtonLabel: 'Add Reply',
            ),
            const SizedBox(height: 16),

            // Paras Closed
            const Text(
              'Paras Closed',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            DynamicTableWidget(
              columnHeaders: const ['Sr. No.', 'Para Short Description', 'Date of Closure', 'Remarks'],
              rows: _parasClosedRows,
              enabled: widget.isEditMode,
              onRowsChanged: (rows) {
                setState(() {
                  _parasClosedRows = rows;
                  _notifyDataChanged();
                });
              },
              addButtonLabel: 'Add Closed Para',
            ),
          ],

          const SizedBox(height: 24),

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
