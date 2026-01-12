import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../section_common_fields.dart';
import '../form_date_picker.dart';
import '../dynamic_table_widget.dart';

/// NIT Section - Notice Inviting Tender
/// Radio: Not Issued/Issued with 2 tables and photo upload
class NITSection extends StatefulWidget {
  final Map<String, dynamic> initialData;
  final Function(Map<String, dynamic>) onDataChanged;

  const NITSection({
    super.key,
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
  late TextEditingController _nitNoController;

  String _issuedStatus = 'not_issued'; // not_issued or issued
  DateTime? _dateOfIssue;
  List<Map<String, String>> _itemsTableRows = [];
  List<Map<String, String>> _biddersTableRows = [];
  List<String> _uploadedPhotos = [];

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
    _nitNoController = TextEditingController();
  }

  void _loadInitialData() {
    if (widget.initialData.isNotEmpty) {
      _personResponsibleController.text =
          widget.initialData['person_responsible'] ?? '';
      _postHeldController.text = widget.initialData['post_held'] ?? '';
      _pendingWithController.text = widget.initialData['pending_with'] ?? '';

      final sectionData = widget.initialData['section_data'] ?? {};
      _issuedStatus = sectionData['issued_status'] ?? 'not_issued';

      if (_issuedStatus == 'issued') {
        _nitNoController.text = sectionData['nit_no'] ?? '';
        _amountController.text = sectionData['amount'] ?? '';
        if (sectionData['date_of_issue'] != null) {
          _dateOfIssue = DateTime.parse(sectionData['date_of_issue']);
        }
        if (sectionData['items'] is List) {
          _itemsTableRows = (sectionData['items'] as List)
              .map((item) => Map<String, String>.from(item))
              .toList();
        }
        if (sectionData['bidders'] is List) {
          _biddersTableRows = (sectionData['bidders'] as List)
              .map((item) => Map<String, String>.from(item))
              .toList();
        }
        if (sectionData['photos'] is List) {
          _uploadedPhotos = List<String>.from(sectionData['photos']);
        }
      }
    }
  }

  void _notifyDataChanged() {
    final sectionData = <String, dynamic>{
      'issued_status': _issuedStatus,
    };

    if (_issuedStatus == 'issued') {
      sectionData['nit_no'] = _nitNoController.text;
      sectionData['date_of_issue'] = _dateOfIssue?.toIso8601String();
      sectionData['amount'] = _amountController.text;
      sectionData['items'] = _itemsTableRows;
      sectionData['bidders'] = _biddersTableRows;
      sectionData['photos'] = _uploadedPhotos;
    }

    widget.onDataChanged({
      'person_responsible': _personResponsibleController.text,
      'post_held': _postHeldController.text,
      'pending_with': _pendingWithController.text,
      'section_data': sectionData,
    });
  }

  void _addPhoto() {
    // TODO: Implement file picker for photo upload
    setState(() {
      _uploadedPhotos.add('photo_${DateTime.now().millisecondsSinceEpoch}.jpg');
      _notifyDataChanged();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Photo upload feature - Coming soon')),
    );
  }

  void _removePhoto(int index) {
    setState(() {
      _uploadedPhotos.removeAt(index);
      _notifyDataChanged();
    });
  }

  @override
  void dispose() {
    _personResponsibleController.dispose();
    _postHeldController.dispose();
    _pendingWithController.dispose();
    _amountController.dispose();
    _nitNoController.dispose();
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

          // Conditional Fields (if issued)
          if (_issuedStatus == 'issued') ...[
            TextFormField(
              controller: _nitNoController,
              onChanged: (_) => _notifyDataChanged(),
              decoration: const InputDecoration(
                labelText: 'NIT Number',
                hintText: 'e.g., "NIT/2026/001"',
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
                labelText: 'Estimated Amount (in Lakhs)',
                hintText: 'e.g., "500"',
                prefixIcon: Icon(Icons.currency_rupee, size: 20),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 24),

            // Items Table
            const Text(
              'Work Items',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            DynamicTableWidget(
              columnHeaders: const ['Sr. No.', 'Item Name', 'Amount (Lakhs)', 'EMD'],
              rows: _itemsTableRows,
              onRowsChanged: (rows) {
                setState(() {
                  _itemsTableRows = rows;
                  _notifyDataChanged();
                });
              },
              addButtonLabel: 'Add Item',
            ),
            const SizedBox(height: 24),

            // Bidders Table
            const Text(
              'Interested Bidders',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            DynamicTableWidget(
              columnHeaders: const ['Sr. No.', 'Bidder Name', 'Contact'],
              rows: _biddersTableRows,
              onRowsChanged: (rows) {
                setState(() {
                  _biddersTableRows = rows;
                  _notifyDataChanged();
                });
              },
              addButtonLabel: 'Add Bidder',
            ),
            const SizedBox(height: 24),

            // Photo Upload Section
            const Text(
              'Photos',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            if (_uploadedPhotos.isNotEmpty) ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _uploadedPhotos.asMap().entries.map((entry) {
                  return Chip(
                    label: Text('Photo ${entry.key + 1}'),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () => _removePhoto(entry.key),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
            ],
            OutlinedButton.icon(
              onPressed: _addPhoto,
              icon: const Icon(Icons.add_a_photo, size: 18),
              label: const Text('Add Photo'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
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
