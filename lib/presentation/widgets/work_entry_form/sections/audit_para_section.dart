import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../section_common_fields.dart';
import '../dynamic_table_widget.dart';

/// Audit Para Section
/// Radio: N/A or Applicable with count + 3 tables
class AuditParaSection extends StatefulWidget {
  final Map<String, dynamic> initialData;
  final Function(Map<String, dynamic>) onDataChanged;

  const AuditParaSection({
    super.key,
    required this.initialData,
    required this.onDataChanged,
  });

  @override
  State<AuditParaSection> createState() => _AuditParaSectionState();
}

class _AuditParaSectionState extends State<AuditParaSection> {
  late TextEditingController _personResponsibleController;
  late TextEditingController _postHeldController;
  late TextEditingController _pendingWithController;
  late TextEditingController _paraCountController;

  String _applicability = 'na'; // na or applicable
  List<Map<String, String>> _paraDetailsRows = [];
  List<Map<String, String>> _complianceRows = [];
  List<Map<String, String>> _statusRows = [];

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
    _paraCountController = TextEditingController();
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
        _paraCountController.text = sectionData['para_count']?.toString() ?? '';
        if (sectionData['para_details'] is List) {
          _paraDetailsRows = (sectionData['para_details'] as List)
              .map((item) => Map<String, String>.from(item))
              .toList();
        }
        if (sectionData['compliance'] is List) {
          _complianceRows = (sectionData['compliance'] as List)
              .map((item) => Map<String, String>.from(item))
              .toList();
        }
        if (sectionData['status'] is List) {
          _statusRows = (sectionData['status'] as List)
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
      sectionData['para_count'] = _paraCountController.text;
      sectionData['para_details'] = _paraDetailsRows;
      sectionData['compliance'] = _complianceRows;
      sectionData['status'] = _statusRows;
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
    _paraCountController.dispose();
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
          const SizedBox(height: 24),

          // Conditional Fields (if applicable)
          if (_applicability == 'applicable') ...[
            TextFormField(
              controller: _paraCountController,
              onChanged: (_) => _notifyDataChanged(),
              decoration: const InputDecoration(
                labelText: 'Number of Audit Paras',
                hintText: 'e.g., 5',
                prefixIcon: Icon(Icons.numbers, size: 20),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),

            // Para Details Table
            const Text(
              'Para Details',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            DynamicTableWidget(
              columnHeaders: const ['Para No.', 'Description', 'Amount'],
              rows: _paraDetailsRows,
              onRowsChanged: (rows) {
                setState(() {
                  _paraDetailsRows = rows;
                  _notifyDataChanged();
                });
              },
              addButtonLabel: 'Add Para',
            ),
            const SizedBox(height: 24),

            // Compliance Table
            const Text(
              'Compliance Status',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            DynamicTableWidget(
              columnHeaders: const ['Para No.', 'Action Taken', 'Date'],
              rows: _complianceRows,
              onRowsChanged: (rows) {
                setState(() {
                  _complianceRows = rows;
                  _notifyDataChanged();
                });
              },
              addButtonLabel: 'Add Compliance',
            ),
            const SizedBox(height: 24),

            // Status Table
            const Text(
              'Current Status',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            DynamicTableWidget(
              columnHeaders: const ['Para No.', 'Status', 'Remarks'],
              rows: _statusRows,
              onRowsChanged: (rows) {
                setState(() {
                  _statusRows = rows;
                  _notifyDataChanged();
                });
              },
              addButtonLabel: 'Add Status',
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
