import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../section_common_fields.dart';
import '../form_date_picker.dart';

/// Work Order Section
/// Contractor name + Radio: Issued/Not Issued with conditional fields
class WorkOrderSection extends StatefulWidget {
  final Map<String, dynamic> initialData;
  final Function(Map<String, dynamic>) onDataChanged;

  const WorkOrderSection({
    super.key,
    required this.initialData,
    required this.onDataChanged,
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

      if (_issuedStatus == 'issued') {
        _woNoController.text = sectionData['wo_no'] ?? '';
        _amountController.text = sectionData['amount'] ?? '';
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

    if (_issuedStatus == 'issued') {
      sectionData['wo_no'] = _woNoController.text;
      sectionData['date_of_issue'] = _dateOfIssue?.toIso8601String();
      sectionData['amount'] = _amountController.text;
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _contractorNameController,
            onChanged: (_) => _notifyDataChanged(),
            decoration: const InputDecoration(
              labelText: 'Contractor Name',
              hintText: 'Enter contractor name',
              prefixIcon: Icon(Icons.business, size: 20),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),

          const Text(
            'Work Order Status',
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
                  title: const Text('Not Issued'),
                  value: 'not_issued',
                  groupValue: _issuedStatus,
                  onChanged: (value) {
                    setState(() {
                      _issuedStatus = value!;
                      _notifyDataChanged();
                    });
                  },
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              Expanded(
                child: RadioListTile<String>(
                  title: const Text('Issued'),
                  value: 'issued',
                  groupValue: _issuedStatus,
                  onChanged: (value) {
                    setState(() {
                      _issuedStatus = value!;
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

          // Conditional Fields (if issued)
          if (_issuedStatus == 'issued') ...[
            TextFormField(
              controller: _woNoController,
              onChanged: (_) => _notifyDataChanged(),
              decoration: const InputDecoration(
                labelText: 'Work Order Number',
                hintText: 'e.g., "WO/2026/001"',
                prefixIcon: Icon(Icons.confirmation_number, size: 20),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            FormDatePicker(
              label: 'Date of Issue',
              selectedDate: _dateOfIssue,
              onDateSelected: (date) {
                setState(() {
                  _dateOfIssue = date;
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
                hintText: 'e.g., 450',
                prefixIcon: Icon(Icons.currency_rupee, size: 20),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
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
