import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../section_common_fields.dart';
import '../dynamic_table_widget.dart';

/// LAQ Section - Legislative Assembly Questions
/// Radio: N/A or Applicable with counts + 4 tables
class LAQSection extends StatefulWidget {
  final Map<String, dynamic> initialData;
  final Function(Map<String, dynamic>) onDataChanged;

  const LAQSection({
    super.key,
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
  late TextEditingController _totalQuestionsController;
  late TextEditingController _pendingQuestionsController;

  String _applicability = 'na'; // na or applicable
  List<Map<String, String>> _questionsRows = [];
  List<Map<String, String>> _responsesRows = [];
  List<Map<String, String>> _followUpRows = [];
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
    _totalQuestionsController = TextEditingController();
    _pendingQuestionsController = TextEditingController();
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
        _totalQuestionsController.text = sectionData['total_questions']?.toString() ?? '';
        _pendingQuestionsController.text = sectionData['pending_questions']?.toString() ?? '';

        if (sectionData['questions'] is List) {
          _questionsRows = (sectionData['questions'] as List)
              .map((item) => Map<String, String>.from(item))
              .toList();
        }
        if (sectionData['responses'] is List) {
          _responsesRows = (sectionData['responses'] as List)
              .map((item) => Map<String, String>.from(item))
              .toList();
        }
        if (sectionData['follow_up'] is List) {
          _followUpRows = (sectionData['follow_up'] as List)
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
      sectionData['total_questions'] = _totalQuestionsController.text;
      sectionData['pending_questions'] = _pendingQuestionsController.text;
      sectionData['questions'] = _questionsRows;
      sectionData['responses'] = _responsesRows;
      sectionData['follow_up'] = _followUpRows;
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
    _totalQuestionsController.dispose();
    _pendingQuestionsController.dispose();
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
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _totalQuestionsController,
                    onChanged: (_) => _notifyDataChanged(),
                    decoration: const InputDecoration(
                      labelText: 'Total Questions',
                      hintText: 'e.g., 10',
                      prefixIcon: Icon(Icons.question_answer, size: 20),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _pendingQuestionsController,
                    onChanged: (_) => _notifyDataChanged(),
                    decoration: const InputDecoration(
                      labelText: 'Pending Questions',
                      hintText: 'e.g., 3',
                      prefixIcon: Icon(Icons.pending, size: 20),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Questions Table
            const Text(
              'Questions List',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            DynamicTableWidget(
              columnHeaders: const ['Q. No.', 'Question', 'Date Received'],
              rows: _questionsRows,
              onRowsChanged: (rows) {
                setState(() {
                  _questionsRows = rows;
                  _notifyDataChanged();
                });
              },
              addButtonLabel: 'Add Question',
            ),
            const SizedBox(height: 24),

            // Responses Table
            const Text(
              'Responses',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            DynamicTableWidget(
              columnHeaders: const ['Q. No.', 'Response', 'Date Sent'],
              rows: _responsesRows,
              onRowsChanged: (rows) {
                setState(() {
                  _responsesRows = rows;
                  _notifyDataChanged();
                });
              },
              addButtonLabel: 'Add Response',
            ),
            const SizedBox(height: 24),

            // Follow-up Table
            const Text(
              'Follow-up Questions',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            DynamicTableWidget(
              columnHeaders: const ['Q. No.', 'Follow-up', 'Date'],
              rows: _followUpRows,
              onRowsChanged: (rows) {
                setState(() {
                  _followUpRows = rows;
                  _notifyDataChanged();
                });
              },
              addButtonLabel: 'Add Follow-up',
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
              columnHeaders: const ['Q. No.', 'Status', 'Remarks'],
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
