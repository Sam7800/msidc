import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../section_common_fields.dart';
import '../form_date_picker.dart';
import '../dynamic_table_widget.dart';
import '../critical_bell_icon.dart';

/// NIT Section - Notice Inviting Tender
/// Radio: Not Issued/Issued with status checkboxes and tables
class NITSection extends StatefulWidget {
  final int? projectId;
  final Map<String, dynamic> initialData;
  final Function(Map<String, dynamic>) onDataChanged;

  const NITSection({
    super.key,
    required this.projectId,
    required this.initialData,
    required this.onDataChanged,
  });

  @override
  State<NITSection> createState() => _NITSectionState();
}

class _NITSectionState extends State<NITSection> {
  late TextEditingController _personResponsibleController;
  late TextEditingController _postHeldController;
  late TextEditingController _pendingWithController;
  late TextEditingController _amountController;
  late TextEditingController _biddersParticipatedController;
  late TextEditingController _writtenApplicationsController;

  String _issuedStatus = 'not_issued'; // not_issued or issued
  DateTime? _likelyDateOfIssue;
  DateTime? _dateOfIssue;
  DateTime? _dateOfPreBid;
  DateTime? _dateOfSubmission;
  List<Map<String, String>> _broadItemsRows = [];
  List<Map<String, String>> _emdAmountsRows = [];

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
    _biddersParticipatedController = TextEditingController();
    _writtenApplicationsController = TextEditingController();
  }

  void _loadInitialData() {
    if (widget.initialData.isNotEmpty) {
      _personResponsibleController.text =
          widget.initialData['person_responsible'] ?? '';
      _postHeldController.text = widget.initialData['post_held'] ?? '';
      _pendingWithController.text = widget.initialData['pending_with'] ?? '';

      final sectionData = widget.initialData['section_data'] ?? {};
      _issuedStatus = sectionData['issued_status'] ?? 'not_issued';

      if (_issuedStatus == 'not_issued') {
        if (sectionData['likely_date_of_issue'] != null) {
          _likelyDateOfIssue = DateTime.parse(sectionData['likely_date_of_issue']);
        }
      } else if (_issuedStatus == 'issued') {
        _amountController.text = sectionData['amount'] ?? '';
        _biddersParticipatedController.text = sectionData['bidders_participated'] ?? '';
        _writtenApplicationsController.text = sectionData['written_applications'] ?? '';
        if (sectionData['date_of_issue'] != null) {
          _dateOfIssue = DateTime.parse(sectionData['date_of_issue']);
        }
        if (sectionData['date_of_pre_bid'] != null) {
          _dateOfPreBid = DateTime.parse(sectionData['date_of_pre_bid']);
        }
        if (sectionData['date_of_submission'] != null) {
          _dateOfSubmission = DateTime.parse(sectionData['date_of_submission']);
        }
        if (sectionData['broad_items'] is List) {
          _broadItemsRows = (sectionData['broad_items'] as List)
              .map((item) => Map<String, String>.from(item))
              .toList();
        }
        if (sectionData['emd_amounts'] is List) {
          _emdAmountsRows = (sectionData['emd_amounts'] as List)
              .map((item) => Map<String, String>.from(item))
              .toList();
        }
      }
    }
  }

  void _notifyDataChanged() {
    final sectionData = <String, dynamic>{
      'issued_status': _issuedStatus,
    };

    if (_issuedStatus == 'not_issued') {
      sectionData['likely_date_of_issue'] = _likelyDateOfIssue?.toIso8601String();
    } else if (_issuedStatus == 'issued') {
      sectionData['date_of_issue'] = _dateOfIssue?.toIso8601String();
      sectionData['amount'] = _amountController.text;
      sectionData['broad_items'] = _broadItemsRows;
      sectionData['date_of_pre_bid'] = _dateOfPreBid?.toIso8601String();
      sectionData['bidders_participated'] = _biddersParticipatedController.text;
      sectionData['written_applications'] = _writtenApplicationsController.text;
      sectionData['date_of_submission'] = _dateOfSubmission?.toIso8601String();
      sectionData['emd_amounts'] = _emdAmountsRows;
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
    _biddersParticipatedController.dispose();
    _writtenApplicationsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Issued Status Selection
          const Text(
            'NIT Status',
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

          // Conditional Fields (if not issued)
          if (_issuedStatus == 'not_issued') ...[
            // Likely Date with bell icon
            Row(
              children: [
                Expanded(
                  child: FormDatePicker(
                    label: 'Likely Date of issue',
                    selectedDate: _likelyDateOfIssue,
                    onDateSelected: (date) {
                      setState(() {
                        _likelyDateOfIssue = date;
                        _notifyDataChanged();
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                CriticalBellIcon(
                  projectId: widget.projectId,
                  sectionName: 'NIT',
                  optionName: 'Likely Date of issue',
                ),
              ],
            ),
          ],

          // Conditional Fields (if issued)
          if (_issuedStatus == 'issued') ...[
            // Date and Amount in a Row
            Row(
              children: [
                Expanded(
                  child: FormDatePicker(
                    label: 'Date',
                    selectedDate: _dateOfIssue,
                    onDateSelected: (date) {
                      setState(() {
                        _dateOfIssue = date;
                        _notifyDataChanged();
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _amountController,
                    onChanged: (_) => _notifyDataChanged(),
                    decoration: const InputDecoration(
                      labelText: 'Amount Rs. Crore / Lakhs',
                      hintText: 'e.g., 450 Lakhs',
                      prefixIcon: Icon(Icons.currency_rupee, size: 20),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Broad Items Table
            const Text(
              'For How Many Broad Items with amounts',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            DynamicTableWidget(
              columnHeaders: const ['Sr. No.', 'Broad Items', 'Amount'],
              rows: _broadItemsRows,
              onRowsChanged: (rows) {
                setState(() {
                  _broadItemsRows = rows;
                  _notifyDataChanged();
                });
              },
              addButtonLabel: 'Add Item',
            ),
            const SizedBox(height: 24),

            // Details Section
            const Text(
              'Details',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),

            FormDatePicker(
              label: 'i) Date of Pre-Bid',
              selectedDate: _dateOfPreBid,
              onDateSelected: (date) {
                setState(() {
                  _dateOfPreBid = date;
                  _notifyDataChanged();
                });
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _biddersParticipatedController,
              onChanged: (_) => _notifyDataChanged(),
              decoration: const InputDecoration(
                labelText: 'No. of Bidders participated',
                hintText: 'Enter number',
                prefixIcon: Icon(Icons.people, size: 20),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _writtenApplicationsController,
              onChanged: (_) => _notifyDataChanged(),
              decoration: const InputDecoration(
                labelText: '# of written applications submitted',
                hintText: 'Enter number',
                prefixIcon: Icon(Icons.description, size: 20),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            FormDatePicker(
              label: 'ii) Date of Submission',
              selectedDate: _dateOfSubmission,
              onDateSelected: (date) {
                setState(() {
                  _dateOfSubmission = date;
                  _notifyDataChanged();
                });
              },
            ),
            const SizedBox(height: 24),

            // EMD Amounts Table
            const Text(
              'iii) EMD Amounts',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            DynamicTableWidget(
              columnHeaders: const ['Sr. No.', 'Broad Items', 'Amount'],
              rows: _emdAmountsRows,
              onRowsChanged: (rows) {
                setState(() {
                  _emdAmountsRows = rows;
                  _notifyDataChanged();
                });
              },
              addButtonLabel: 'Add EMD Amount',
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
