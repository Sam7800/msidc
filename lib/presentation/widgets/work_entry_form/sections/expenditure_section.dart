import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../section_common_fields.dart';

/// Expenditure Section
/// Cumulative amount + auto-calculated percentage
class ExpenditureSection extends StatefulWidget {
  final Map<String, dynamic> initialData;
  final Function(Map<String, dynamic>) onDataChanged;
  final double? agreementAmount; // From Agreement section for percentage calculation

  const ExpenditureSection({
    super.key,
    required this.initialData,
    required this.onDataChanged,
    this.agreementAmount,
  });

  @override
  State<ExpenditureSection> createState() => _ExpenditureSectionState();
}

class _ExpenditureSectionState extends State<ExpenditureSection> {
  late TextEditingController _personResponsibleController;
  late TextEditingController _postHeldController;
  late TextEditingController _pendingWithController;
  late TextEditingController _cumulativeAmountController;

  double? _percentageSpent;

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
    _cumulativeAmountController = TextEditingController();
  }

  void _loadInitialData() {
    if (widget.initialData.isNotEmpty) {
      _personResponsibleController.text =
          widget.initialData['person_responsible'] ?? '';
      _postHeldController.text = widget.initialData['post_held'] ?? '';
      _pendingWithController.text = widget.initialData['pending_with'] ?? '';

      final sectionData = widget.initialData['section_data'] ?? {};
      _cumulativeAmountController.text = sectionData['cumulative_amount']?.toString() ?? '';
      _percentageSpent = sectionData['percentage_spent'];
    }
  }

  void _calculatePercentage() {
    final cumulativeAmount = double.tryParse(_cumulativeAmountController.text) ?? 0;
    final agreementAmount = widget.agreementAmount ?? 0;

    if (agreementAmount > 0) {
      _percentageSpent = (cumulativeAmount / agreementAmount) * 100;
    } else {
      _percentageSpent = null;
    }
  }

  void _notifyDataChanged() {
    _calculatePercentage();

    widget.onDataChanged({
      'person_responsible': _personResponsibleController.text,
      'post_held': _postHeldController.text,
      'pending_with': _pendingWithController.text,
      'section_data': {
        'cumulative_amount': _cumulativeAmountController.text,
        'percentage_spent': _percentageSpent,
      },
    });
  }

  @override
  void dispose() {
    _personResponsibleController.dispose();
    _postHeldController.dispose();
    _pendingWithController.dispose();
    _cumulativeAmountController.dispose();
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
            controller: _cumulativeAmountController,
            onChanged: (_) => _notifyDataChanged(),
            decoration: const InputDecoration(
              labelText: 'Cumulative Expenditure (in Lakhs)',
              hintText: 'e.g., 300',
              prefixIcon: Icon(Icons.currency_rupee, size: 20),
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 24),

          // Percentage Display
          if (_percentageSpent != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue, width: 1),
              ),
              child: Row(
                children: [
                  const Icon(Icons.analytics, color: Colors.blue),
                  const SizedBox(width: 12),
                  Text(
                    'Expenditure: ${_percentageSpent!.toStringAsFixed(2)}% of Agreement Amount',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue.shade900,
                    ),
                  ),
                ],
              ),
            ),
          ] else if (widget.agreementAmount == null || widget.agreementAmount == 0) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange, width: 1),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.orange),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Agreement amount not available. Percentage cannot be calculated.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.orange.shade900,
                      ),
                    ),
                  ),
                ],
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
