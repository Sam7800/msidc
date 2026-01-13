import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../section_common_fields.dart';
import '../form_date_picker.dart';
import '../critical_bell_icon.dart';

/// Work Order Section
/// Contractor name + Radio: Issued/Not Issued with bell icon
class WorkOrderSection extends StatefulWidget {
  final int? projectId;
  final Map<String, dynamic> initialData;
  final Function(Map<String, dynamic>) onDataChanged;
  final bool isEditMode;

  const WorkOrderSection({
    super.key,
    required this.projectId,
    required this.initialData,
    required this.onDataChanged,
    required this.isEditMode,
  });

  @override
  State<WorkOrderSection> createState() => _WorkOrderSectionState();
}

class _WorkOrderSectionState extends State<WorkOrderSection> {
  late TextEditingController _personResponsibleController;
  late TextEditingController _postHeldController;
  late TextEditingController _pendingWithController;
  late TextEditingController _contractorNameController;
  late TextEditingController _woNoController;
  late TextEditingController _amountController;
  late TextEditingController _percentageAboveBelowController;
  late TextEditingController _tenderPeriodController;
  late TextEditingController _reasonsController;

  String _issuedStatus = 'not_issued'; // not_issued or issued
  DateTime? _dateOfIssue;

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
    _contractorNameController = TextEditingController();
    _woNoController = TextEditingController();
    _amountController = TextEditingController();
    _percentageAboveBelowController = TextEditingController();
    _tenderPeriodController = TextEditingController();
    _reasonsController = TextEditingController();
  }

  void _loadInitialData() {
    if (widget.initialData.isNotEmpty) {
      _personResponsibleController.text =
          widget.initialData['person_responsible'] ?? '';
      _postHeldController.text = widget.initialData['post_held'] ?? '';
      _pendingWithController.text = widget.initialData['pending_with'] ?? '';

      final sectionData = widget.initialData['section_data'] ?? {};
      _contractorNameController.text = sectionData['contractor_name'] ?? '';
      _issuedStatus = sectionData['issued_status'] ?? 'not_issued';

      if (_issuedStatus == 'not_issued') {
        _reasonsController.text = sectionData['reasons'] ?? '';
      } else if (_issuedStatus == 'issued') {
        _woNoController.text = sectionData['wo_no'] ?? '';
        _amountController.text = sectionData['amount'] ?? '';
        _percentageAboveBelowController.text = sectionData['percentage_above_below'] ?? '';
        _tenderPeriodController.text = sectionData['tender_period'] ?? '';
        if (sectionData['date_of_issue'] != null) {
          _dateOfIssue = DateTime.parse(sectionData['date_of_issue']);
        }
      }
    }
  }

  void _notifyDataChanged() {
    final sectionData = <String, dynamic>{
      'contractor_name': _contractorNameController.text,
      'issued_status': _issuedStatus,
    };

    if (_issuedStatus == 'not_issued') {
      sectionData['reasons'] = _reasonsController.text;
    } else if (_issuedStatus == 'issued') {
      sectionData['date_of_issue'] = _dateOfIssue?.toIso8601String();
      sectionData['amount'] = _amountController.text;
      sectionData['percentage_above_below'] = _percentageAboveBelowController.text;
      sectionData['tender_period'] = _tenderPeriodController.text;
      sectionData['wo_no'] = _woNoController.text;
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
    _contractorNameController.dispose();
    _woNoController.dispose();
    _amountController.dispose();
    _percentageAboveBelowController.dispose();
    _tenderPeriodController.dispose();
    _reasonsController.dispose();
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
            'Work Order: Name of Contractor',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _contractorNameController,
            onChanged: (_) => _notifyDataChanged(),
            enabled: widget.isEditMode,
            decoration: const InputDecoration(
              hintText: 'Enter contractor name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),

          // a) Not Issued – Reasons
          Row(
            children: [
              Radio<String>(
                value: 'not_issued',
                groupValue: _issuedStatus,
                onChanged: widget.isEditMode ? (value) {
                  setState(() {
                    _issuedStatus = value!;
                    _notifyDataChanged();
                  });
                } : null,
              ),
              const Text(
                'a) Not Issued – Reasons',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(width: 8),
              CriticalBellIcon(
                projectId: widget.projectId,
                sectionName: 'Work Order',
                optionName: 'Not Issued – Reasons',
              ),
            ],
          ),

          // Show reasons text field when not issued is selected
          if (_issuedStatus == 'not_issued') ...[
            const SizedBox(height: 16),
            TextFormField(
              controller: _reasonsController,
              onChanged: (_) => _notifyDataChanged(),
              enabled: widget.isEditMode,
              decoration: const InputDecoration(
                hintText: 'Enter reasons',
                border: OutlineInputBorder(),
              ),
            ),
          ],

          const SizedBox(height: 16),

          // b) Issued – Details
          RadioListTile<String>(
            title: const Text('b) Issued – Details –'),
            value: 'issued',
            groupValue: _issuedStatus,
            onChanged: widget.isEditMode ? (value) {
              setState(() {
                _issuedStatus = value!;
                _notifyDataChanged();
              });
            } : null,
            dense: true,
            contentPadding: EdgeInsets.zero,
          ),

          // Show fields when issued is selected
          if (_issuedStatus == 'issued') ...[
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
              selectedDate: _dateOfIssue,
              onDateSelected: (date) {
                setState(() {
                  _dateOfIssue = date;
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

            // iii) % above / Below
            Row(
              children: [
                const SizedBox(width: 24),
                const Text(
                  'iii) % above / Below',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _percentageAboveBelowController,
              onChanged: (_) => _notifyDataChanged(),
              enabled: widget.isEditMode,
              decoration: const InputDecoration(
                hintText: 'e.g., +5% or -3%',
                prefixIcon: Icon(Icons.percent, size: 20),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // iv) Tender period
            Row(
              children: [
                const SizedBox(width: 24),
                const Text(
                  'iv) Tender period',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _tenderPeriodController,
              onChanged: (_) => _notifyDataChanged(),
              enabled: widget.isEditMode,
              decoration: const InputDecoration(
                hintText: 'Enter tender period',
                prefixIcon: Icon(Icons.calendar_today, size: 20),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // v) WO No.
            Row(
              children: [
                const SizedBox(width: 24),
                const Text(
                  'v) WO No.',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _woNoController,
              onChanged: (_) => _notifyDataChanged(),
              enabled: widget.isEditMode,
              decoration: const InputDecoration(
                hintText: 'Enter WO number',
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
