import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../section_common_fields.dart';
import '../form_date_picker.dart';

/// Bid Submission Section
/// Date + bidders count + checkbox
class BidSubmissionSection extends StatefulWidget {
  final Map<String, dynamic> initialData;
  final Function(Map<String, dynamic>) onDataChanged;
  final bool isEditMode;

  const BidSubmissionSection({
    super.key,
    required this.initialData,
    required this.onDataChanged,
    required this.isEditMode,
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
  String _emdVerificationDone = 'no'; // yes or no

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
      _emdVerificationDone = sectionData['emd_verification_done'] ?? 'no';
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
        'emd_verification_done': _emdVerificationDone,
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
          const Text(
            'Bid Submission:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          FormDatePicker(
            label: 'Date',
            selectedDate: _submissionDate,
            onDateSelected: (date) {
              setState(() {
                _submissionDate = date;
                _notifyDataChanged();
              });
            },
            enabled: widget.isEditMode,
          ),
          const SizedBox(height: 24),

          const Text(
            '1. # of bidders tendered',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),

          TextFormField(
            controller: _biddersCountController,
            onChanged: (_) => _notifyDataChanged(),
            enabled: widget.isEditMode,
            decoration: const InputDecoration(
              hintText: 'Enter number',
              prefixIcon: Icon(Icons.people, size: 20),
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 24),

          const Text(
            '2. EMD verification done',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              Expanded(
                child: RadioListTile<String>(
                  title: const Text('Yes'),
                  value: 'yes',
                  groupValue: _emdVerificationDone,
                  onChanged: widget.isEditMode ? (value) {
                    setState(() {
                      _emdVerificationDone = value!;
                      _notifyDataChanged();
                    });
                  } : null,
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              Expanded(
                child: RadioListTile<String>(
                  title: const Text('No'),
                  value: 'no',
                  groupValue: _emdVerificationDone,
                  onChanged: widget.isEditMode ? (value) {
                    setState(() {
                      _emdVerificationDone = value!;
                      _notifyDataChanged();
                    });
                  } : null,
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),

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
