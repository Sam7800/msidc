import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../section_common_fields.dart';
import '../form_date_picker.dart';
import '../critical_bell_icon.dart';

/// Rev AA Section - Revised Administrative Approval
/// Radio: Not Required/Necessary with conditional fields
class RevAASection extends StatefulWidget {
  final int? projectId;
  final Map<String, dynamic> initialData;
  final Function(Map<String, dynamic>) onDataChanged;
  final bool isEditMode;

  const RevAASection({
    super.key,
    required this.projectId,
    required this.initialData,
    required this.onDataChanged,
    required this.isEditMode,
  });

  @override
  State<RevAASection> createState() => _RevAASectionState();
}

class _RevAASectionState extends State<RevAASection> {
  late TextEditingController _personResponsibleController;
  late TextEditingController _postHeldController;
  late TextEditingController _pendingWithController;
  late TextEditingController _reasonsController;
  late TextEditingController _amountProposedController;
  late TextEditingController _revisedAANoController;
  late TextEditingController _raaTableController;

  String _requirement = 'not_required'; // not_required or necessary
  String _status = 'in_progress'; // in_progress, submitted, approved, board_approval, revised_aa_accorded
  DateTime? _dateSelected;

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
    _reasonsController = TextEditingController();
    _amountProposedController = TextEditingController();
    _revisedAANoController = TextEditingController();
    _raaTableController = TextEditingController();
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
        _reasonsController.text = sectionData['reasons'] ?? '';
        _amountProposedController.text = sectionData['amount_proposed'] ?? '';
        _status = sectionData['status'] ?? 'in_progress';
        _revisedAANoController.text = sectionData['revised_aa_no'] ?? '';
        _raaTableController.text = sectionData['raa_table'] ?? '';
        if (sectionData['date'] != null) {
          _dateSelected = DateTime.parse(sectionData['date']);
        }
      }
    }
  }

  void _notifyDataChanged() {
    final sectionData = <String, dynamic>{
      'requirement': _requirement,
    };

    if (_requirement == 'necessary') {
      sectionData['reasons'] = _reasonsController.text;
      sectionData['amount_proposed'] = _amountProposedController.text;
      sectionData['status'] = _status;
      sectionData['revised_aa_no'] = _revisedAANoController.text;
      sectionData['date'] = _dateSelected?.toIso8601String();
      sectionData['raa_table'] = _raaTableController.text;
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
    _reasonsController.dispose();
    _amountProposedController.dispose();
    _revisedAANoController.dispose();
    _raaTableController.dispose();
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
            'Rev AA:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          // Not Required / Necessary
          Row(
            children: [
              Expanded(
                child: RadioListTile<String>(
                  title: const Text('Not Required'),
                  value: 'not_required',
                  groupValue: _requirement,
                  onChanged: widget.isEditMode ? (value) {
                    setState(() {
                      _requirement = value!;
                      _notifyDataChanged();
                    });
                  } : null,
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              Expanded(
                child: RadioListTile<String>(
                  title: const Text('Necessary'),
                  value: 'necessary',
                  groupValue: _requirement,
                  onChanged: widget.isEditMode ? (value) {
                    setState(() {
                      _requirement = value!;
                      _notifyDataChanged();
                    });
                  } : null,
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),

          // If Necessary
          if (_requirement == 'necessary') ...[
            const SizedBox(height: 16),

            // Reasons
            const Text(
              'Reasons',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _reasonsController,
              onChanged: (_) => _notifyDataChanged(),
              enabled: widget.isEditMode,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Enter reasons',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Amount Proposed Rs. Crore / Lakhs
            const Text(
              'Amount Proposed Rs. Crore / Lakhs',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _amountProposedController,
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

            // Status
            const Text(
              'Status:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),

            // In progress
            RadioListTile<String>(
              title: const Text('In progress'),
              value: 'in_progress',
              groupValue: _status,
              onChanged: widget.isEditMode ? (value) {
                setState(() {
                  _status = value!;
                  _notifyDataChanged();
                });
              } : null,
              dense: true,
              contentPadding: EdgeInsets.zero,
            ),

            // Submitted (with bell icon)
            Row(
              children: [
                Radio<String>(
                  value: 'submitted',
                  groupValue: _status,
                  onChanged: widget.isEditMode ? (value) {
                    setState(() {
                      _status = value!;
                      _notifyDataChanged();
                    });
                  } : null,
                ),
                const Expanded(
                  child: Text(
                    'Submitted',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
                CriticalBellIcon(
                  projectId: widget.projectId,
                  sectionName: 'Rev AA',
                  optionName: 'Submitted',
                ),
              ],
            ),

            // Approved
            RadioListTile<String>(
              title: const Text('Approved'),
              value: 'approved',
              groupValue: _status,
              onChanged: widget.isEditMode ? (value) {
                setState(() {
                  _status = value!;
                  _notifyDataChanged();
                });
              } : null,
              dense: true,
              contentPadding: EdgeInsets.zero,
            ),

            // Board Approval
            RadioListTile<String>(
              title: const Text('Board Approval'),
              value: 'board_approval',
              groupValue: _status,
              onChanged: widget.isEditMode ? (value) {
                setState(() {
                  _status = value!;
                  _notifyDataChanged();
                });
              } : null,
              dense: true,
              contentPadding: EdgeInsets.zero,
            ),

            // Revised AA Accorded
            RadioListTile<String>(
              title: const Text('Revised AA Accorded'),
              value: 'revised_aa_accorded',
              groupValue: _status,
              onChanged: widget.isEditMode ? (value) {
                setState(() {
                  _status = value!;
                  _notifyDataChanged();
                });
              } : null,
              dense: true,
              contentPadding: EdgeInsets.zero,
            ),

            const SizedBox(height: 16),

            // Revised AA No.
            const Text(
              'Revised AA No.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _revisedAANoController,
              onChanged: (_) => _notifyDataChanged(),
              enabled: widget.isEditMode,
              decoration: const InputDecoration(
                hintText: 'Enter revised AA number',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Date
            FormDatePicker(
              label: 'Date',
              selectedDate: _dateSelected,
              onDateSelected: (date) {
                setState(() {
                  _dateSelected = date;
                  _notifyDataChanged();
                });
              },
              enabled: widget.isEditMode,
            ),
            const SizedBox(height: 16),

            // RAA Table of Recap Sheet
            const Text(
              'RAA Table of Recap Sheet',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _raaTableController,
              onChanged: (_) => _notifyDataChanged(),
              enabled: widget.isEditMode,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Enter details',
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
