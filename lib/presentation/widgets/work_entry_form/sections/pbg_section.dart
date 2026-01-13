import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../section_common_fields.dart';
import '../form_date_picker.dart';
import '../critical_bell_icon.dart';

/// PBG Section - Performance Bank Guarantee
/// Radio: Not Submitted/Submitted with bell icon
class PBGSection extends StatefulWidget {
  final int? projectId;
  final Map<String, dynamic> initialData;
  final Function(Map<String, dynamic>) onDataChanged;
  final bool isEditMode;

  const PBGSection({
    super.key,
    required this.projectId,
    required this.initialData,
    required this.onDataChanged,
    required this.isEditMode,
  });

  @override
  State<PBGSection> createState() => _PBGSectionState();
}

class _PBGSectionState extends State<PBGSection> {
  late TextEditingController _personResponsibleController;
  late TextEditingController _postHeldController;
  late TextEditingController _pendingWithController;
  late TextEditingController _amountController;
  late TextEditingController _periodController;

  String _submissionStatus = 'not_submitted'; // not_submitted or submitted
  DateTime? _dateOfSubmission;

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
    _amountController = TextEditingController();
    _periodController = TextEditingController();
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
        _amountController.text = sectionData['amount'] ?? '';
        _periodController.text = sectionData['period'] ?? '';
        if (sectionData['date_of_submission'] != null) {
          _dateOfSubmission = DateTime.parse(sectionData['date_of_submission']);
        }
      }
    }
  }

  void _notifyDataChanged() {
    final sectionData = <String, dynamic>{
      'submission_status': _submissionStatus,
    };

    if (_submissionStatus == 'submitted') {
      sectionData['date_of_submission'] = _dateOfSubmission?.toIso8601String();
      sectionData['amount'] = _amountController.text;
      sectionData['period'] = _periodController.text;
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
    _amountController.dispose();
    _periodController.dispose();
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
            'PBG:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          // a) Not submitted
          Row(
            children: [
              Radio<String>(
                value: 'not_submitted',
                groupValue: _submissionStatus,
                onChanged: widget.isEditMode ? (value) {
                  setState(() {
                    _submissionStatus = value!;
                    _notifyDataChanged();
                  });
                } : null,
              ),
              const Text(
                'a) Not submitted',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(width: 8),
              CriticalBellIcon(
                projectId: widget.projectId,
                sectionName: 'PBG',
                optionName: 'Not submitted',
              ),
            ],
          ),

          // b) Submitted
          RadioListTile<String>(
            title: const Text('b) Submitted -'),
            value: 'submitted',
            groupValue: _submissionStatus,
            onChanged: widget.isEditMode ? (value) {
              setState(() {
                _submissionStatus = value!;
                _notifyDataChanged();
              });
            } : null,
            dense: true,
            contentPadding: EdgeInsets.zero,
          ),

          // Show fields when submitted is selected
          if (_submissionStatus == 'submitted') ...[
            const SizedBox(height: 16),

            // i) Date
            Row(
              children: [
                const SizedBox(width: 24),
                const Text(
                  'i) Date',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 8),
            FormDatePicker(
              label: '',
              selectedDate: _dateOfSubmission,
              onDateSelected: (date) {
                setState(() {
                  _dateOfSubmission = date;
                  _notifyDataChanged();
                });
              },
              enabled: widget.isEditMode,
            ),
            const SizedBox(height: 16),

            // ii) Amount
            Row(
              children: [
                const SizedBox(width: 24),
                const Text(
                  'ii) Amount',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _amountController,
              onChanged: (_) => _notifyDataChanged(),
              enabled: widget.isEditMode,
              decoration: const InputDecoration(
                hintText: 'Enter amount',
                prefixIcon: Icon(Icons.currency_rupee, size: 20),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 16),

            // iii) Period
            Row(
              children: [
                const SizedBox(width: 24),
                const Text(
                  'iii) Period',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _periodController,
              onChanged: (_) => _notifyDataChanged(),
              enabled: widget.isEditMode,
              decoration: const InputDecoration(
                hintText: 'Enter period',
                prefixIcon: Icon(Icons.calendar_today, size: 20),
                border: OutlineInputBorder(),
              ),
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
