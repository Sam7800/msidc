import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../section_common_fields.dart';
import '../form_date_picker.dart';

/// Rev AA Section - Revised Administrative Approval
/// Radio: Not Required/Necessary with conditional fields
class RevAASection extends StatefulWidget {
  final Map<String, dynamic> initialData;
  final Function(Map<String, dynamic>) onDataChanged;

  const RevAASection({
    super.key,
    required this.initialData,
    required this.onDataChanged,
  });

  @override
  State<RevAASection> createState() => _RevAASectionState();
}

class _RevAASectionState extends State<RevAASection> {
  late TextEditingController _personResponsibleController;
  late TextEditingController _postHeldController;
  late TextEditingController _pendingWithController;
  late TextEditingController _revisedAmountController;
  late TextEditingController _revisionNoController;
  late TextEditingController _reasonController;

  String _requirement = 'not_required'; // not_required or necessary
  DateTime? _dateOfRevision;

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
    _revisedAmountController = TextEditingController();
    _revisionNoController = TextEditingController();
    _reasonController = TextEditingController();
  }

  void _loadInitialData() {
    if (widget.initialData.isNotEmpty) {
      _personResponsibleController.text =
          widget.initialData['person_responsible'] ?? '';
      _postHeldController.text = widget.initialData['post_held'] ?? '';
      _pendingWithController.text = widget.initialData['pending_with'] ?? '';

      final sectionData = widget.initialData['section_data'] ?? {};
      _requirement = sectionData['requirement'] ?? 'not_required';

      if (_requirement == 'necessary') {
        _revisedAmountController.text = sectionData['revised_amount'] ?? '';
        _revisionNoController.text = sectionData['revision_no'] ?? '';
        _reasonController.text = sectionData['reason'] ?? '';
        if (sectionData['date_of_revision'] != null) {
          _dateOfRevision = DateTime.parse(sectionData['date_of_revision']);
        }
      }
    }
  }

  void _notifyDataChanged() {
    final sectionData = <String, dynamic>{
      'requirement': _requirement,
    };

    if (_requirement == 'necessary') {
      sectionData['revised_amount'] = _revisedAmountController.text;
      sectionData['revision_no'] = _revisionNoController.text;
      sectionData['date_of_revision'] = _dateOfRevision?.toIso8601String();
      sectionData['reason'] = _reasonController.text;
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
    _revisedAmountController.dispose();
    _revisionNoController.dispose();
    _reasonController.dispose();
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
            'Requirement',
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
                  title: const Text('Not Required'),
                  value: 'not_required',
                  groupValue: _requirement,
                  onChanged: (value) {
                    setState(() {
                      _requirement = value!;
                      _notifyDataChanged();
                    });
                  },
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              Expanded(
                child: RadioListTile<String>(
                  title: const Text('Necessary'),
                  value: 'necessary',
                  groupValue: _requirement,
                  onChanged: (value) {
                    setState(() {
                      _requirement = value!;
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

          // Conditional Fields (if necessary)
          if (_requirement == 'necessary') ...[
            TextFormField(
              controller: _revisionNoController,
              onChanged: (_) => _notifyDataChanged(),
              decoration: const InputDecoration(
                labelText: 'Revision Number',
                hintText: 'e.g., "Rev AA/2026/001"',
                prefixIcon: Icon(Icons.confirmation_number, size: 20),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            FormDatePicker(
              label: 'Date of Revision',
              selectedDate: _dateOfRevision,
              onDateSelected: (date) {
                setState(() {
                  _dateOfRevision = date;
                  _notifyDataChanged();
                });
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _revisedAmountController,
              onChanged: (_) => _notifyDataChanged(),
              decoration: const InputDecoration(
                labelText: 'Revised Amount (in Crores/Lakhs)',
                hintText: 'e.g., "120 Cr"',
                prefixIcon: Icon(Icons.currency_rupee, size: 20),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _reasonController,
              onChanged: (_) => _notifyDataChanged(),
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Reason for Revision',
                hintText: 'Enter reason',
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
          ),
        ],
      ),
    );
  }
}
