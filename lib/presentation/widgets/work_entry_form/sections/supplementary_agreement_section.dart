import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../section_common_fields.dart';
import '../form_date_picker.dart';

/// Supplementary Agreement Section
/// Radio: Not applicable or Applicable with conditional fields
class SupplementaryAgreementSection extends StatefulWidget {
  final Map<String, dynamic> initialData;
  final Function(Map<String, dynamic>) onDataChanged;

  const SupplementaryAgreementSection({
    super.key,
    required this.initialData,
    required this.onDataChanged,
  });

  @override
  State<SupplementaryAgreementSection> createState() =>
      _SupplementaryAgreementSectionState();
}

class _SupplementaryAgreementSectionState
    extends State<SupplementaryAgreementSection> {
  late TextEditingController _personResponsibleController;
  late TextEditingController _postHeldController;
  late TextEditingController _pendingWithController;
  late TextEditingController _necessityController;
  late TextEditingController _amountController;
  late TextEditingController _scopeOfWorkController;
  late TextEditingController _periodController;

  String _applicability = 'na'; // na or applicable
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
    _necessityController = TextEditingController();
    _amountController = TextEditingController();
    _scopeOfWorkController = TextEditingController();
    _periodController = TextEditingController();
  }

  void _loadInitialData() {
    if (widget.initialData.isNotEmpty) {
      _personResponsibleController.text =
          widget.initialData['person_responsible'] ?? '';
      _postHeldController.text = widget.initialData['post_held'] ?? '';
      _pendingWithController.text = widget.initialData['pending_with'] ?? '';

      final sectionData = widget.initialData['section_data'] ?? {};
      _applicability = sectionData['applicability'] ?? 'na';

      if (_applicability == 'applicable') {
        _necessityController.text = sectionData['necessity'] ?? '';
        _amountController.text = sectionData['amount'] ?? '';
        _scopeOfWorkController.text = sectionData['scope_of_work'] ?? '';
        _periodController.text = sectionData['period'] ?? '';
        if (sectionData['date'] != null) {
          _dateSelected = DateTime.parse(sectionData['date']);
        }
      }
    }
  }

  void _notifyDataChanged() {
    final sectionData = <String, dynamic>{
      'applicability': _applicability,
    };

    if (_applicability == 'applicable') {
      sectionData['necessity'] = _necessityController.text;
      sectionData['amount'] = _amountController.text;
      sectionData['date'] = _dateSelected?.toIso8601String();
      sectionData['scope_of_work'] = _scopeOfWorkController.text;
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
    _necessityController.dispose();
    _amountController.dispose();
    _scopeOfWorkController.dispose();
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
            'Supplementary Agreement:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          // Not applicable / Applicable
          Row(
            children: [
              Expanded(
                child: RadioListTile<String>(
                  title: const Text('Not applicable'),
                  value: 'na',
                  groupValue: _applicability,
                  onChanged: (value) {
                    setState(() {
                      _applicability = value!;
                      _notifyDataChanged();
                    });
                  },
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              Expanded(
                child: RadioListTile<String>(
                  title: const Text('Applicable'),
                  value: 'applicable',
                  groupValue: _applicability,
                  onChanged: (value) {
                    setState(() {
                      _applicability = value!;
                      _notifyDataChanged();
                    });
                  },
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),

          // If Applicable
          if (_applicability == 'applicable') ...[
            const SizedBox(height: 16),

            // Necessity
            const Text(
              'Necessity',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _necessityController,
              onChanged: (_) => _notifyDataChanged(),
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Enter necessity details',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Amount Rs. Lakhs
            const Text(
              'Amount Rs. Lakhs',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _amountController,
              onChanged: (_) => _notifyDataChanged(),
              decoration: const InputDecoration(
                hintText: 'Enter amount',
                prefixIcon: Icon(Icons.currency_rupee, size: 20),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
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
            ),
            const SizedBox(height: 16),

            // Scope of work
            const Text(
              'Scope of work',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _scopeOfWorkController,
              onChanged: (_) => _notifyDataChanged(),
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Enter scope of work',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Period – (Months)
            const Text(
              'Period – (Months)',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _periodController,
              onChanged: (_) => _notifyDataChanged(),
              decoration: const InputDecoration(
                hintText: 'Enter period in months',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
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
