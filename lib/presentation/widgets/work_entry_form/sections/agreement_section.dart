import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../section_common_fields.dart';
import '../form_date_picker.dart';

/// Agreement Section
/// Amount + date + period
class AgreementSection extends StatefulWidget {
  final Map<String, dynamic> initialData;
  final Function(Map<String, dynamic>) onDataChanged;

  const AgreementSection({
    super.key,
    required this.initialData,
    required this.onDataChanged,
  });

  @override
  State<AgreementSection> createState() => _AgreementSectionState();
}

class _AgreementSectionState extends State<AgreementSection> {
  late TextEditingController _personResponsibleController;
  late TextEditingController _postHeldController;
  late TextEditingController _pendingWithController;
  late TextEditingController _amountController;
  late TextEditingController _periodController;

  DateTime? _agreementDate;

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
      _amountController.text = sectionData['amount'] ?? '';
      _periodController.text = sectionData['period_months']?.toString() ?? '';
      if (sectionData['agreement_date'] != null) {
        _agreementDate = DateTime.parse(sectionData['agreement_date']);
      }
    }
  }

  void _notifyDataChanged() {
    widget.onDataChanged({
      'person_responsible': _personResponsibleController.text,
      'post_held': _postHeldController.text,
      'pending_with': _pendingWithController.text,
      'section_data': {
        'amount': _amountController.text,
        'agreement_date': _agreementDate?.toIso8601String(),
        'period_months': _periodController.text,
      },
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
          TextFormField(
            controller: _amountController,
            onChanged: (_) => _notifyDataChanged(),
            decoration: const InputDecoration(
              labelText: 'Agreement Amount (in Lakhs)',
              hintText: 'e.g., 450',
              prefixIcon: Icon(Icons.currency_rupee, size: 20),
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 16),

          FormDatePicker(
            label: 'Agreement Date',
            selectedDate: _agreementDate,
            onDateSelected: (date) {
              setState(() {
                _agreementDate = date;
                _notifyDataChanged();
              });
            },
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _periodController,
            onChanged: (_) => _notifyDataChanged(),
            decoration: const InputDecoration(
              labelText: 'Period (in months)',
              hintText: 'e.g., 18',
              prefixIcon: Icon(Icons.calendar_month, size: 20),
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),

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
