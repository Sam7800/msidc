import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../section_common_fields.dart';
import '../form_date_picker.dart';

/// Bid Submission Section
/// Date + bidders count + checkbox
class BidSubmissionSection extends StatefulWidget {
  final Map<String, dynamic> initialData;
  final Function(Map<String, dynamic>) onDataChanged;

  const BidSubmissionSection({
    super.key,
    required this.initialData,
    required this.onDataChanged,
  });

  @override
  State<BidSubmissionSection> createState() => _BidSubmissionSectionState();
}

class _BidSubmissionSectionState extends State<BidSubmissionSection> {
  late TextEditingController _personResponsibleController;
  late TextEditingController _postHeldController;
  late TextEditingController _pendingWithController;
  late TextEditingController _biddersCountController;

  DateTime? _submissionDate;
  bool _isComplete = false;

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
    _biddersCountController = TextEditingController();
  }

  void _loadInitialData() {
    if (widget.initialData.isNotEmpty) {
      _personResponsibleController.text =
          widget.initialData['person_responsible'] ?? '';
      _postHeldController.text = widget.initialData['post_held'] ?? '';
      _pendingWithController.text = widget.initialData['pending_with'] ?? '';

      final sectionData = widget.initialData['section_data'] ?? {};
      _biddersCountController.text = sectionData['bidders_count']?.toString() ?? '';
      _isComplete = sectionData['is_complete'] ?? false;
      if (sectionData['submission_date'] != null) {
        _submissionDate = DateTime.parse(sectionData['submission_date']);
      }
    }
  }

  void _notifyDataChanged() {
    widget.onDataChanged({
      'person_responsible': _personResponsibleController.text,
      'post_held': _postHeldController.text,
      'pending_with': _pendingWithController.text,
      'section_data': {
        'submission_date': _submissionDate?.toIso8601String(),
        'bidders_count': _biddersCountController.text,
        'is_complete': _isComplete,
      },
    });
  }

  @override
  void dispose() {
    _personResponsibleController.dispose();
    _postHeldController.dispose();
    _pendingWithController.dispose();
    _biddersCountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FormDatePicker(
            label: 'Bid Submission Date',
            selectedDate: _submissionDate,
            onDateSelected: (date) {
              setState(() {
                _submissionDate = date;
                _notifyDataChanged();
              });
            },
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _biddersCountController,
            onChanged: (_) => _notifyDataChanged(),
            decoration: const InputDecoration(
              labelText: 'Number of Bidders Submitted',
              hintText: 'e.g., 3',
              prefixIcon: Icon(Icons.people, size: 20),
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),

          CheckboxListTile(
            title: const Text('Bid Submission Complete'),
            value: _isComplete,
            onChanged: (value) {
              setState(() {
                _isComplete = value ?? false;
                _notifyDataChanged();
              });
            },
            dense: true,
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
          ),

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
