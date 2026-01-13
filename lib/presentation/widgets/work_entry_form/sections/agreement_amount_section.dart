import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../section_common_fields.dart';

/// Agreement Amount Section
class AgreementAmountSection extends StatefulWidget {
  final Map<String, dynamic> initialData;
  final Function(Map<String, dynamic>) onDataChanged;
  final bool isEditMode;

  const AgreementAmountSection({
    super.key,
    required this.initialData,
    required this.onDataChanged,
    required this.isEditMode,
  });

  @override
  State<AgreementAmountSection> createState() => _AgreementAmountSectionState();
}

class _AgreementAmountSectionState extends State<AgreementAmountSection> {
  late TextEditingController _personResponsibleController;
  late TextEditingController _postHeldController;
  late TextEditingController _pendingWithController;
  late TextEditingController _amountController;

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
  }

  void _loadInitialData() {
    if (widget.initialData.isNotEmpty) {
      _personResponsibleController.text =
          widget.initialData['person_responsible'] ?? '';
      _postHeldController.text = widget.initialData['post_held'] ?? '';
      _pendingWithController.text = widget.initialData['pending_with'] ?? '';

      final sectionData = widget.initialData['section_data'] ?? {};
      _amountController.text = sectionData['amount'] ?? '';
    }
  }

  void _notifyDataChanged() {
    widget.onDataChanged({
      'person_responsible': _personResponsibleController.text,
      'post_held': _postHeldController.text,
      'pending_with': _pendingWithController.text,
      'section_data': {
        'amount': _amountController.text,
      },
    });
  }

  @override
  void dispose() {
    _personResponsibleController.dispose();
    _postHeldController.dispose();
    _pendingWithController.dispose();
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
            controller: _amountController,
            onChanged: (_) => _notifyDataChanged(),
            enabled: widget.isEditMode,
            decoration: const InputDecoration(
              labelText: 'Agreement Amount (in Lakhs)',
              hintText: 'e.g., 450',
              prefixIcon: Icon(Icons.currency_rupee, size: 20),
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
          ),

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
