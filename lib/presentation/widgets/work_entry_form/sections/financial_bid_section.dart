import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../section_common_fields.dart';
import '../form_date_picker.dart';

/// Financial Bid Section
/// Date + fields + dropdown
class FinancialBidSection extends StatefulWidget {
  final Map<String, dynamic> initialData;
  final Function(Map<String, dynamic>) onDataChanged;
  final bool isEditMode;

  const FinancialBidSection({
    super.key,
    required this.initialData,
    required this.onDataChanged,
    required this.isEditMode,
  });

  @override
  State<FinancialBidSection> createState() => _FinancialBidSectionState();
}

class _FinancialBidSectionState extends State<FinancialBidSection> {
  late TextEditingController _personResponsibleController;
  late TextEditingController _postHeldController;
  late TextEditingController _pendingWithController;
  late TextEditingController _qualifiedBiddersController;
  late TextEditingController _offerAmountController;
  late TextEditingController _percentageAboveBelowController;

  DateTime? _openingDate;
  String _l1h1Offer = 'L1'; // L1 or H1

  final List<String> _offerOptions = ['L1', 'H1'];

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
    _qualifiedBiddersController = TextEditingController();
    _offerAmountController = TextEditingController();
    _percentageAboveBelowController = TextEditingController();
  }

  void _loadInitialData() {
    if (widget.initialData.isNotEmpty) {
      _personResponsibleController.text =
          widget.initialData['person_responsible'] ?? '';
      _postHeldController.text = widget.initialData['post_held'] ?? '';
      _pendingWithController.text = widget.initialData['pending_with'] ?? '';

      final sectionData = widget.initialData['section_data'] ?? {};
      _qualifiedBiddersController.text = sectionData['qualified_bidders'] ?? '';
      _l1h1Offer = sectionData['l1h1_offer'] ?? 'L1';
      _offerAmountController.text = sectionData['offer_amount'] ?? '';
      _percentageAboveBelowController.text = sectionData['percentage_above_below'] ?? '';

      if (sectionData['opening_date'] != null) {
        _openingDate = DateTime.parse(sectionData['opening_date']);
      }
    }
  }

  void _notifyDataChanged() {
    widget.onDataChanged({
      'person_responsible': _personResponsibleController.text,
      'post_held': _postHeldController.text,
      'pending_with': _pendingWithController.text,
      'section_data': {
        'opening_date': _openingDate?.toIso8601String(),
        'qualified_bidders': _qualifiedBiddersController.text,
        'l1h1_offer': _l1h1Offer,
        'offer_amount': _offerAmountController.text,
        'percentage_above_below': _percentageAboveBelowController.text,
      },
    });
  }

  @override
  void dispose() {
    _personResponsibleController.dispose();
    _postHeldController.dispose();
    _pendingWithController.dispose();
    _qualifiedBiddersController.dispose();
    _offerAmountController.dispose();
    _percentageAboveBelowController.dispose();
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
            'Financial Bid:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          FormDatePicker(
            label: 'Date',
            selectedDate: _openingDate,
            onDateSelected: (date) {
              setState(() {
                _openingDate = date;
                _notifyDataChanged();
              });
            },
            enabled: widget.isEditMode,
          ),
          const SizedBox(height: 24),

          const Text(
            '1. # of qualified bidders participated',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),

          TextFormField(
            controller: _qualifiedBiddersController,
            onChanged: (_) => _notifyDataChanged(),
            enabled: widget.isEditMode,
            decoration: const InputDecoration(
              hintText: 'Enter number',
              prefixIcon: Icon(Icons.people, size: 20),
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 24),

          const Text(
            '2. Bids opened –',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          // i) L1 / H1 offer
          Row(
            children: [
              const SizedBox(width: 24),
              const Text(
                'i) L1 / H1 offer',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          DropdownButtonFormField<String>(
            value: _l1h1Offer,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: _offerOptions.map((option) {
              return DropdownMenuItem(
                value: option,
                child: Text(option),
              );
            }).toList(),
            onChanged: widget.isEditMode ? (value) {
              setState(() {
                _l1h1Offer = value!;
                _notifyDataChanged();
              });
            } : null,
          ),
          const SizedBox(height: 16),

          // ii) Offer amount
          Row(
            children: [
              const SizedBox(width: 24),
              const Expanded(
                child: Text(
                  'ii) Offer amount: Rs. Lakhs / Cr',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          TextFormField(
            controller: _offerAmountController,
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

          // iii) % above / below
          Row(
            children: [
              const SizedBox(width: 24),
              const Text(
                'iii) % above / below',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          TextFormField(
            controller: _percentageAboveBelowController,
            onChanged: (_) => _notifyDataChanged(),
            enabled: widget.isEditMode,
            decoration: const InputDecoration(
              hintText: 'e.g., +5% or -3%',
              prefixIcon: Icon(Icons.percent, size: 20),
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.text,
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
