import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../section_common_fields.dart';
import '../form_date_picker.dart';

/// AA Section - Administrative Approval
/// Radio buttons: Awaited / Accorded with conditional fields
class AASection extends StatefulWidget {
  final bool isEditMode;
  final Map<String, dynamic> initialData;
  final Function(Map<String, dynamic>) onDataChanged;

  const AASection({
    super.key,
    required this.isEditMode,
    required this.initialData,
    required this.onDataChanged,
  });

  @override
  State<AASection> createState() => _AASectionState();
}

class _AASectionState extends State<AASection> {
  late TextEditingController _personResponsibleController;
  late TextEditingController _postHeldController;
  late TextEditingController _pendingWithController;

  // AA specific controllers
  late TextEditingController _proposedAmountController;
  late TextEditingController _pendingWithWhomController;
  late TextEditingController _amountController;
  late TextEditingController _aaNoController;
  late TextEditingController _broadScopeController;

  String _selectedType = 'awaited'; // awaited or accorded
  DateTime? _dateOfProposal;
  DateTime? _dateAccorded;

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
    _proposedAmountController = TextEditingController();
    _pendingWithWhomController = TextEditingController();
    _amountController = TextEditingController();
    _aaNoController = TextEditingController();
    _broadScopeController = TextEditingController();
  }

  void _loadInitialData() {
    if (widget.initialData.isNotEmpty) {
      _personResponsibleController.text =
          widget.initialData['person_responsible'] ?? '';
      _postHeldController.text = widget.initialData['post_held'] ?? '';
      _pendingWithController.text = widget.initialData['pending_with'] ?? '';

      final sectionData = widget.initialData['section_data'] ?? {};
      _selectedType = sectionData['type'] ?? 'awaited';

      if (_selectedType == 'awaited') {
        _proposedAmountController.text = sectionData['proposed_amount'] ?? '';
        _pendingWithWhomController.text =
            sectionData['pending_with_whom'] ?? '';
        if (sectionData['date_of_proposal'] != null) {
          _dateOfProposal = DateTime.parse(sectionData['date_of_proposal']);
        }
      } else {
        _amountController.text = sectionData['amount_crore_lakhs'] ?? '';
        _aaNoController.text = sectionData['aa_no'] ?? '';
        _broadScopeController.text = sectionData['broad_scope'] ?? '';
        if (sectionData['date'] != null) {
          _dateAccorded = DateTime.parse(sectionData['date']);
        }
      }
    }
  }

  Map<String, dynamic> _buildSectionData() {
    if (_selectedType == 'awaited') {
      return {
        'type': 'awaited',
        'proposed_amount': _proposedAmountController.text,
        'date_of_proposal': _dateOfProposal?.toIso8601String(),
        'pending_with_whom': _pendingWithWhomController.text,
      };
    } else {
      return {
        'type': 'accorded',
        'amount_crore_lakhs': _amountController.text,
        'aa_no': _aaNoController.text,
        'date': _dateAccorded?.toIso8601String(),
        'broad_scope': _broadScopeController.text,
      };
    }
  }

  void _notifyDataChanged() {
    widget.onDataChanged({
      'person_responsible': _personResponsibleController.text,
      'post_held': _postHeldController.text,
      'pending_with': _pendingWithController.text,
      'section_data': _buildSectionData(),
    });
  }

  @override
  void dispose() {
    _personResponsibleController.dispose();
    _postHeldController.dispose();
    _pendingWithController.dispose();
    _proposedAmountController.dispose();
    _pendingWithWhomController.dispose();
    _amountController.dispose();
    _aaNoController.dispose();
    _broadScopeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Type Selection (Radio Buttons)
          const Text(
            'Status',
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
                  title: const Text('Awaited'),
                  value: 'awaited',
                  groupValue: _selectedType,
                  onChanged: widget.isEditMode
                      ? (value) {
                          setState(() {
                            _selectedType = value!;
                            _notifyDataChanged();
                          });
                        }
                      : null,
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              Expanded(
                child: RadioListTile<String>(
                  title: const Text('Accorded'),
                  value: 'accorded',
                  groupValue: _selectedType,
                  onChanged: widget.isEditMode
                      ? (value) {
                          setState(() {
                            _selectedType = value!;
                            _notifyDataChanged();
                          });
                        }
                      : null,
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Conditional Fields based on type
          if (_selectedType == 'awaited') ...[
            // Awaited Fields
            TextFormField(
              controller: _proposedAmountController,
              enabled: widget.isEditMode,
              onChanged: (_) => _notifyDataChanged(),
              decoration: const InputDecoration(
                labelText: 'Proposed Amount (in Crores/Lakhs)',
                hintText: 'e.g., "100 Cr"',
                prefixIcon: Icon(Icons.currency_rupee, size: 20),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            FormDatePicker(
              label: 'Date of Proposal',
              selectedDate: _dateOfProposal,
              enabled: widget.isEditMode,
              onDateSelected: (date) {
                setState(() {
                  _dateOfProposal = date;
                  _notifyDataChanged();
                });
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _pendingWithWhomController,
              enabled: widget.isEditMode,
              onChanged: (_) => _notifyDataChanged(),
              decoration: const InputDecoration(
                labelText: 'Pending With Whom',
                hintText: 'e.g., "Director"',
                prefixIcon: Icon(Icons.person_search, size: 20),
                border: OutlineInputBorder(),
              ),
            ),
          ] else ...[
            // Accorded Fields
            TextFormField(
              controller: _amountController,
              enabled: widget.isEditMode,
              onChanged: (_) => _notifyDataChanged(),
              decoration: const InputDecoration(
                labelText: 'Amount (in Crores/Lakhs)',
                hintText: 'e.g., "100 Cr"',
                prefixIcon: Icon(Icons.currency_rupee, size: 20),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _aaNoController,
              enabled: widget.isEditMode,
              onChanged: (_) => _notifyDataChanged(),
              decoration: const InputDecoration(
                labelText: 'AA Number',
                hintText: 'e.g., "AA/2026/001"',
                prefixIcon: Icon(Icons.confirmation_number, size: 20),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            FormDatePicker(
              label: 'Date',
              selectedDate: _dateAccorded,
              enabled: widget.isEditMode,
              onDateSelected: (date) {
                setState(() {
                  _dateAccorded = date;
                  _notifyDataChanged();
                });
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _broadScopeController,
              enabled: widget.isEditMode,
              onChanged: (_) => _notifyDataChanged(),
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Broad Scope',
                hintText: 'Enter project scope details',
                prefixIcon: Icon(Icons.description, size: 20),
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
            enabled: widget.isEditMode,
            onChanged: _notifyDataChanged,
          ),
        ],
      ),
    );
  }
}
