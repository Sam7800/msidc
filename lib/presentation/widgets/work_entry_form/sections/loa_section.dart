import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../section_common_fields.dart';
import '../form_date_picker.dart';
import '../critical_bell_icon.dart';

/// LOA Section - Letter of Acceptance
/// Radio: Issued/Not Issued with bell icon and conditional fields
class LOASection extends StatefulWidget {
  final int? projectId;
  final Map<String, dynamic> initialData;
  final Function(Map<String, dynamic>) onDataChanged;

  const LOASection({
    super.key,
    required this.projectId,
    required this.initialData,
    required this.onDataChanged,
  });

  @override
  State<LOASection> createState() => _LOASectionState();
}

class _LOASectionState extends State<LOASection> {
  late TextEditingController _personResponsibleController;
  late TextEditingController _postHeldController;
  late TextEditingController _pendingWithController;
  late TextEditingController _loaNoController;
  late TextEditingController _contractorNameController;
  late TextEditingController _amountController;
  late TextEditingController _reasonsController;

  String _issuedStatus = 'issued'; // issued or not_issued
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
    _loaNoController = TextEditingController();
    _contractorNameController = TextEditingController();
    _amountController = TextEditingController();
    _reasonsController = TextEditingController();
  }

  void _loadInitialData() {
    if (widget.initialData.isNotEmpty) {
      _personResponsibleController.text =
          widget.initialData['person_responsible'] ?? '';
      _postHeldController.text = widget.initialData['post_held'] ?? '';
      _pendingWithController.text = widget.initialData['pending_with'] ?? '';

      final sectionData = widget.initialData['section_data'] ?? {};
      _issuedStatus = sectionData['issued_status'] ?? 'issued';

      if (_issuedStatus == 'not_issued') {
        _reasonsController.text = sectionData['reasons'] ?? '';
      } else if (_issuedStatus == 'issued') {
        _loaNoController.text = sectionData['loa_no'] ?? '';
        _contractorNameController.text = sectionData['contractor_name'] ?? '';
        _amountController.text = sectionData['amount'] ?? '';
        if (sectionData['date_of_issue'] != null) {
          _dateOfIssue = DateTime.parse(sectionData['date_of_issue']);
        }
      }
    }
  }

  void _notifyDataChanged() {
    final sectionData = <String, dynamic>{
      'issued_status': _issuedStatus,
    };

    if (_issuedStatus == 'not_issued') {
      sectionData['reasons'] = _reasonsController.text;
    } else if (_issuedStatus == 'issued') {
      sectionData['loa_no'] = _loaNoController.text;
      sectionData['date_of_issue'] = _dateOfIssue?.toIso8601String();
      sectionData['contractor_name'] = _contractorNameController.text;
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
    _loaNoController.dispose();
    _contractorNameController.dispose();
    _amountController.dispose();
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
            'LOA:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          // a) Issued
          RadioListTile<String>(
            title: const Text('a) Issued'),
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

          // b) Not issued – Reasons
          Row(
            children: [
              Radio<String>(
                value: 'not_issued',
                groupValue: _issuedStatus,
                onChanged: (value) {
                  setState(() {
                    _issuedStatus = value!;
                    _notifyDataChanged();
                  });
                },
              ),
              const Text(
                'b) Not issued – Reasons',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(width: 8),
              CriticalBellIcon(
                projectId: widget.projectId,
                sectionName: 'LOA',
                optionName: 'Not issued – Reasons',
              ),
            ],
          ),

          // Show reasons text field when not issued is selected
          if (_issuedStatus == 'not_issued') ...[
            const SizedBox(height: 16),
            TextFormField(
              controller: _reasonsController,
              onChanged: (_) => _notifyDataChanged(),
              decoration: const InputDecoration(
                hintText: 'Enter reasons',
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
          ),
        ],
      ),
    );
  }
}
