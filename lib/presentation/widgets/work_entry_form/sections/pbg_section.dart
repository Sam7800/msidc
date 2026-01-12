import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../section_common_fields.dart';
import '../form_date_picker.dart';

/// PBG Section - Performance Bank Guarantee
/// Radio: Not Submitted/Submitted with conditional fields
class PBGSection extends StatefulWidget {
  final Map<String, dynamic> initialData;
  final Function(Map<String, dynamic>) onDataChanged;

  const PBGSection({
    super.key,
    required this.initialData,
    required this.onDataChanged,
  });

  @override
  State<PBGSection> createState() => _PBGSectionState();
}

class _PBGSectionState extends State<PBGSection> {
  late TextEditingController _personResponsibleController;
  late TextEditingController _postHeldController;
  late TextEditingController _pendingWithController;
  late TextEditingController _pbgNoController;
  late TextEditingController _amountController;
  late TextEditingController _bankNameController;

  String _submissionStatus = 'not_submitted'; // not_submitted or submitted
  DateTime? _dateOfSubmission;
  DateTime? _validityDate;

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
    _pbgNoController = TextEditingController();
    _amountController = TextEditingController();
    _bankNameController = TextEditingController();
  }

  void _loadInitialData() {
    if (widget.initialData.isNotEmpty) {
      _personResponsibleController.text =
          widget.initialData['person_responsible'] ?? '';
      _postHeldController.text = widget.initialData['post_held'] ?? '';
      _pendingWithController.text = widget.initialData['pending_with'] ?? '';

      final sectionData = widget.initialData['section_data'] ?? {};
      _submissionStatus = sectionData['submission_status'] ?? 'not_submitted';

      if (_submissionStatus == 'submitted') {
        _pbgNoController.text = sectionData['pbg_no'] ?? '';
        _amountController.text = sectionData['amount'] ?? '';
        _bankNameController.text = sectionData['bank_name'] ?? '';
        if (sectionData['date_of_submission'] != null) {
          _dateOfSubmission = DateTime.parse(sectionData['date_of_submission']);
        }
        if (sectionData['validity_date'] != null) {
          _validityDate = DateTime.parse(sectionData['validity_date']);
        }
      }
    }
  }

  void _notifyDataChanged() {
    final sectionData = <String, dynamic>{
      'submission_status': _submissionStatus,
    };

    if (_submissionStatus == 'submitted') {
      sectionData['pbg_no'] = _pbgNoController.text;
      sectionData['date_of_submission'] = _dateOfSubmission?.toIso8601String();
      sectionData['amount'] = _amountController.text;
      sectionData['bank_name'] = _bankNameController.text;
      sectionData['validity_date'] = _validityDate?.toIso8601String();
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
    _pbgNoController.dispose();
    _amountController.dispose();
    _bankNameController.dispose();
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
            'PBG Status',
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
                  title: const Text('Not Submitted'),
                  value: 'not_submitted',
                  groupValue: _submissionStatus,
                  onChanged: (value) {
                    setState(() {
                      _submissionStatus = value!;
                      _notifyDataChanged();
                    });
                  },
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              Expanded(
                child: RadioListTile<String>(
                  title: const Text('Submitted'),
                  value: 'submitted',
                  groupValue: _submissionStatus,
                  onChanged: (value) {
                    setState(() {
                      _submissionStatus = value!;
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

          // Conditional Fields (if submitted)
          if (_submissionStatus == 'submitted') ...[
            TextFormField(
              controller: _pbgNoController,
              onChanged: (_) => _notifyDataChanged(),
              decoration: const InputDecoration(
                labelText: 'PBG Number',
                hintText: 'e.g., "PBG/2026/001"',
                prefixIcon: Icon(Icons.confirmation_number, size: 20),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            FormDatePicker(
              label: 'Date of Submission',
              selectedDate: _dateOfSubmission,
              onDateSelected: (date) {
                setState(() {
                  _dateOfSubmission = date;
                  _notifyDataChanged();
                });
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _amountController,
              onChanged: (_) => _notifyDataChanged(),
              decoration: const InputDecoration(
                labelText: 'Amount (in Lakhs)',
                hintText: 'e.g., 45',
                prefixIcon: Icon(Icons.currency_rupee, size: 20),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _bankNameController,
              onChanged: (_) => _notifyDataChanged(),
              decoration: const InputDecoration(
                labelText: 'Bank Name',
                hintText: 'Enter bank name',
                prefixIcon: Icon(Icons.account_balance, size: 20),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            FormDatePicker(
              label: 'Validity Date',
              selectedDate: _validityDate,
              onDateSelected: (date) {
                setState(() {
                  _validityDate = date;
                  _notifyDataChanged();
                });
              },
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
