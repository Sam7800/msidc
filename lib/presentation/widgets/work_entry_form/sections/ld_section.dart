import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../section_common_fields.dart';
import '../form_date_picker.dart';

/// LD Section - Liquidated Damages
/// Radio: N/A or Applicable with conditional fields
class LDSection extends StatefulWidget {
  final Map<String, dynamic> initialData;
  final Function(Map<String, dynamic>) onDataChanged;
  final bool isEditMode;

  const LDSection({
    super.key,
    required this.initialData,
    required this.onDataChanged,
    required this.isEditMode,
  });

  @override
  State<LDSection> createState() => _LDSectionState();
}

class _LDSectionState extends State<LDSection> {
  late TextEditingController _personResponsibleController;
  late TextEditingController _postHeldController;
  late TextEditingController _pendingWithController;
  late TextEditingController _amountImposedPerWeekController;
  late TextEditingController _amountRecoveredController;
  late TextEditingController _amountDepositedController;
  late TextEditingController _amountReleasedController;
  late TextEditingController _finalAmountRecoveredController;

  String _applicability = 'na'; // na or applicable

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
    _amountImposedPerWeekController = TextEditingController();
    _amountRecoveredController = TextEditingController();
    _amountDepositedController = TextEditingController();
    _amountReleasedController = TextEditingController();
    _finalAmountRecoveredController = TextEditingController();
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
        _amountImposedPerWeekController.text = sectionData['amount_imposed_per_week'] ?? '';
        _amountRecoveredController.text = sectionData['amount_recovered'] ?? '';
        _amountDepositedController.text = sectionData['amount_deposited'] ?? '';
        _amountReleasedController.text = sectionData['amount_released'] ?? '';
        _finalAmountRecoveredController.text = sectionData['final_amount_recovered'] ?? '';
      }
    }
  }

  void _notifyDataChanged() {
    final sectionData = <String, dynamic>{
      'applicability': _applicability,
    };

    if (_applicability == 'applicable') {
      sectionData['amount_imposed_per_week'] = _amountImposedPerWeekController.text;
      sectionData['amount_recovered'] = _amountRecoveredController.text;
      sectionData['amount_deposited'] = _amountDepositedController.text;
      sectionData['amount_released'] = _amountReleasedController.text;
      sectionData['final_amount_recovered'] = _finalAmountRecoveredController.text;
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
    _amountImposedPerWeekController.dispose();
    _amountRecoveredController.dispose();
    _amountDepositedController.dispose();
    _amountReleasedController.dispose();
    _finalAmountRecoveredController.dispose();
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
            'LD (Liquidated Damages):',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          // Not Applicable
          RadioListTile<String>(
            title: const Text('Not Applicable'),
            value: 'na',
            groupValue: _applicability,
            onChanged: widget.isEditMode ? (value) {
              setState(() {
                _applicability = value!;
                _notifyDataChanged();
              });
            } : null,
            dense: true,
            contentPadding: EdgeInsets.zero,
          ),

          // Applicable
          RadioListTile<String>(
            title: const Text('Applicable'),
            value: 'applicable',
            groupValue: _applicability,
            onChanged: widget.isEditMode ? (value) {
              setState(() {
                _applicability = value!;
                _notifyDataChanged();
              });
            } : null,
            dense: true,
            contentPadding: EdgeInsets.zero,
          ),

          // applicable fields
          if (_applicability == 'applicable') ...[
            const SizedBox(height: 16),

            // Amount imposed / per week
            const Text(
              'Amount imposed / per week',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _amountImposedPerWeekController,
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

            // Amount recovered
            const Text(
              'Amount recovered',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _amountRecoveredController,
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

            // Amount deposited in account
            const Text(
              'Amount deposited in account',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _amountDepositedController,
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

            // Amount released after achievement of progress
            const Text(
              'Amount released after achievement of progress',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _amountReleasedController,
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

            // Final amount recovered from Contractor
            const Text(
              'Final amount recovered from Contractor',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _finalAmountRecoveredController,
              onChanged: (_) => _notifyDataChanged(),
              enabled: widget.isEditMode,
              decoration: const InputDecoration(
                hintText: 'Enter amount',
                prefixIcon: Icon(Icons.currency_rupee, size: 20),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
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
