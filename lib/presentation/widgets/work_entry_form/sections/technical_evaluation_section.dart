import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../section_common_fields.dart';
import '../form_date_picker.dart';
import '../critical_bell_icon.dart';

/// Technical Evaluation Section
/// Status checkboxes with conditional fields
class TechnicalEvaluationSection extends StatefulWidget {
  final int? projectId;
  final Map<String, dynamic> initialData;
  final Function(Map<String, dynamic>) onDataChanged;
  final bool isEditMode;

  const TechnicalEvaluationSection({
    super.key,
    required this.projectId,
    required this.initialData,
    required this.onDataChanged,
    required this.isEditMode,
  });

  @override
  State<TechnicalEvaluationSection> createState() => _TechnicalEvaluationSectionState();
}

class _TechnicalEvaluationSectionState extends State<TechnicalEvaluationSection> {
  late TextEditingController _personResponsibleController;
  late TextEditingController _postHeldController;
  late TextEditingController _pendingWithController;
  late TextEditingController _qualifiedBiddersController;
  late TextEditingController _remarksController;

  String _selectedStatus = 'in_progress';
  DateTime? _likelyCompletionDate;
  DateTime? _completionDate;

  final List<Map<String, String>> _statusOptions = [
    {'value': 'in_progress', 'label': 'In Progress'},
    {'value': 'completed', 'label': 'Completed'},
    {'value': 'results_published', 'label': 'Qualified bidders results published'},
    {'value': 'date_informed', 'label': 'Date of financial bid opening informed'},
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
    _qualifiedBiddersController = TextEditingController();
    _remarksController = TextEditingController();
  }

  void _loadInitialData() {
    if (widget.initialData.isNotEmpty) {
      _personResponsibleController.text =
          widget.initialData['person_responsible'] ?? '';
      _postHeldController.text = widget.initialData['post_held'] ?? '';
      _pendingWithController.text = widget.initialData['pending_with'] ?? '';

      final sectionData = widget.initialData['section_data'] ?? {};
      _selectedStatus = sectionData['status'] ?? 'in_progress';

      if (sectionData['likely_completion_date'] != null) {
        _likelyCompletionDate = DateTime.parse(sectionData['likely_completion_date']);
      }

      if (sectionData['completion_date'] != null) {
        _completionDate = DateTime.parse(sectionData['completion_date']);
      }

      _qualifiedBiddersController.text = sectionData['qualified_bidders']?.toString() ?? '';
      _remarksController.text = sectionData['remarks'] ?? '';
    }
  }

  void _notifyDataChanged() {
    final sectionData = <String, dynamic>{
      'status': _selectedStatus,
      if (_selectedStatus == 'in_progress' && _likelyCompletionDate != null)
        'likely_completion_date': _likelyCompletionDate!.toIso8601String(),
      if (_selectedStatus == 'completed' && _completionDate != null)
        'completion_date': _completionDate!.toIso8601String(),
      if (_qualifiedBiddersController.text.isNotEmpty)
        'qualified_bidders': _qualifiedBiddersController.text,
      if (_remarksController.text.isNotEmpty)
        'remarks': _remarksController.text,
    };

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
    _qualifiedBiddersController.dispose();
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
            final showBellIcon = option['value'] == 'in_progress'; // Only show bell on In Progress
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
                      sectionName: 'Technical Evaluation',
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
              onDateSelected: (date) {
                setState(() {
                  _likelyCompletionDate = date;
                  _notifyDataChanged();
                });
              },
              enabled: widget.isEditMode,
            ),
          ],

          // Conditional fields (if completed)
          if (_selectedStatus == 'completed') ...[
            const SizedBox(height: 24),
            FormDatePicker(
              label: 'Completion Date',
              selectedDate: _completionDate,
              onDateSelected: (date) {
                setState(() {
                  _completionDate = date;
                  _notifyDataChanged();
                });
              },
              enabled: widget.isEditMode,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _qualifiedBiddersController,
              onChanged: (_) => _notifyDataChanged(),
              enabled: widget.isEditMode,
              decoration: const InputDecoration(
                labelText: 'Number of Qualified Bidders',
                hintText: 'e.g., 2',
                prefixIcon: Icon(Icons.check_circle, size: 20),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _remarksController,
              onChanged: (_) => _notifyDataChanged(),
              enabled: widget.isEditMode,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Remarks',
                hintText: 'Enter remarks',
                prefixIcon: Icon(Icons.notes, size: 20),
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
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
