import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../section_common_fields.dart';
import '../dynamic_table_widget.dart';
import '../critical_bell_icon.dart';

/// LAQ Section - Legislative Assembly Questions
/// Radio: Not applicable or Applicable with 4 tables
class LAQSection extends StatefulWidget {
  final int? projectId;
  final Map<String, dynamic> initialData;
  final Function(Map<String, dynamic>) onDataChanged;

  const LAQSection({
    super.key,
    required this.projectId,
    required this.initialData,
    required this.onDataChanged,
  });

  @override
  State<LAQSection> createState() => _LAQSectionState();
}

class _LAQSectionState extends State<LAQSection> {
  late TextEditingController _personResponsibleController;
  late TextEditingController _postHeldController;
  late TextEditingController _pendingWithController;
  late TextEditingController _laqCountController;
  late TextEditingController _responsiblePersonController;

  String _applicability = 'na'; // na or applicable
  List<Map<String, String>> _detailsOfQuestionsRows = [];
  List<Map<String, String>> _repliesSubmittedRows = [];
  List<Map<String, String>> _promisesGivenRows = [];
  List<Map<String, String>> _promisesComplianceRows = [];

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
    _laqCountController = TextEditingController();
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
        _laqCountController.text = sectionData['laq_count'] ?? '';
        _responsiblePersonController.text = sectionData['responsible_person'] ?? '';

        if (sectionData['details_of_questions'] is List) {
          _detailsOfQuestionsRows = (sectionData['details_of_questions'] as List)
              .map((item) => Map<String, String>.from(item))
              .toList();
        }
        if (sectionData['replies_submitted'] is List) {
          _repliesSubmittedRows = (sectionData['replies_submitted'] as List)
              .map((item) => Map<String, String>.from(item))
              .toList();
        }
        if (sectionData['promises_given'] is List) {
          _promisesGivenRows = (sectionData['promises_given'] as List)
              .map((item) => Map<String, String>.from(item))
              .toList();
        }
        if (sectionData['promises_compliance'] is List) {
          _promisesComplianceRows = (sectionData['promises_compliance'] as List)
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
      sectionData['laq_count'] = _laqCountController.text;
      sectionData['responsible_person'] = _responsiblePersonController.text;
      sectionData['details_of_questions'] = _detailsOfQuestionsRows;
      sectionData['replies_submitted'] = _repliesSubmittedRows;
      sectionData['promises_given'] = _promisesGivenRows;
      sectionData['promises_compliance'] = _promisesComplianceRows;
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
    _laqCountController.dispose();
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
            'LAQ (Legislative Questions):',
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

            // # of LAQs / LCQs / Lakshvwdhi / Others
            const Text(
              '# of LAQs / LCQs / Lakshvwdhi / Others',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _laqCountController,
              onChanged: (_) => _notifyDataChanged(),
              decoration: const InputDecoration(
                hintText: 'Enter number',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            // Details of Questions with bell icon
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Details of Questions',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                CriticalBellIcon(
                  projectId: widget.projectId,
                  sectionName: 'LAQ',
                  optionName: 'Details of Questions',
                ),
              ],
            ),
            const SizedBox(height: 12),
            DynamicTableWidget(
              columnHeaders: const ['Sr. No.', 'LAQ / LCQ No.', 'Date of Question', 'Remarks'],
              rows: _detailsOfQuestionsRows,
              onRowsChanged: (rows) {
                setState(() {
                  _detailsOfQuestionsRows = rows;
                  _notifyDataChanged();
                });
              },
              addButtonLabel: 'Add Question',
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
              onChanged: (_) => _notifyDataChanged(),
              decoration: const InputDecoration(
                hintText: 'Enter name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Replies Submitted: # and Dates
            const Text(
              'Replies Submitted: # and Dates',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            DynamicTableWidget(
              columnHeaders: const ['Sr. No.', 'LAQ / LCQ No.', 'Date of Reply submitted', 'Remarks'],
              rows: _repliesSubmittedRows,
              onRowsChanged: (rows) {
                setState(() {
                  _repliesSubmittedRows = rows;
                  _notifyDataChanged();
                });
              },
              addButtonLabel: 'Add Reply',
            ),
            const SizedBox(height: 16),

            // Promises given by Hon Minister/s
            const Text(
              'Promises given by Hon Minister/s',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            DynamicTableWidget(
              columnHeaders: const ['Sr. No.', 'LAQ / LCQ No.', 'Date of Question', 'Remarks'],
              rows: _promisesGivenRows,
              onRowsChanged: (rows) {
                setState(() {
                  _promisesGivenRows = rows;
                  _notifyDataChanged();
                });
              },
              addButtonLabel: 'Add Promise',
            ),
            const SizedBox(height: 16),

            // Promises Compliance
            const Text(
              'Promises Compliance',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            DynamicTableWidget(
              columnHeaders: const ['Sr. No.', 'LAQ / LCQ No.', 'Date of Promise', 'Promise contents', 'Action taken'],
              rows: _promisesComplianceRows,
              onRowsChanged: (rows) {
                setState(() {
                  _promisesComplianceRows = rows;
                  _notifyDataChanged();
                });
              },
              addButtonLabel: 'Add Compliance',
            ),
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
