import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../section_common_fields.dart';
import '../form_date_picker.dart';

/// Financial Bid Section
/// Date + fields + dropdown
class FinancialBidSection extends StatefulWidget {
  final Map<String, dynamic> initialData;
  final Function(Map<String, dynamic>) onDataChanged;

  const FinancialBidSection({
    super.key,
    required this.initialData,
    required this.onDataChanged,
  });

  @override
  State<FinancialBidSection> createState() => _FinancialBidSectionState();
}

class _FinancialBidSectionState extends State<FinancialBidSection> {
  late TextEditingController _personResponsibleController;
  late TextEditingController _postHeldController;
  late TextEditingController _pendingWithController;
  late TextEditingController _l1BidderController;
  late TextEditingController _l1AmountController;

  DateTime? _openingDate;
  String _recommendedBidder = 'l1'; // l1, l2, l3, other

  final List<Map<String, String>> _bidderOptions = [
    {'value': 'l1', 'label': 'L1 Bidder'},
    {'value': 'l2', 'label': 'L2 Bidder'},
    {'value': 'l3', 'label': 'L3 Bidder'},
    {'value': 'other', 'label': 'Other'},
  ];

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
    _l1BidderController = TextEditingController();
    _l1AmountController = TextEditingController();
  }

  void _loadInitialData() {
    if (widget.initialData.isNotEmpty) {
      _personResponsibleController.text =
          widget.initialData['person_responsible'] ?? '';
      _postHeldController.text = widget.initialData['post_held'] ?? '';
      _pendingWithController.text = widget.initialData['pending_with'] ?? '';

      final sectionData = widget.initialData['section_data'] ?? {};
      _l1BidderController.text = sectionData['l1_bidder'] ?? '';
      _l1AmountController.text = sectionData['l1_amount'] ?? '';
      _recommendedBidder = sectionData['recommended_bidder'] ?? 'l1';

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
        'l1_bidder': _l1BidderController.text,
        'l1_amount': _l1AmountController.text,
        'recommended_bidder': _recommendedBidder,
      },
    });
  }

  @override
  void dispose() {
    _personResponsibleController.dispose();
    _postHeldController.dispose();
    _pendingWithController.dispose();
    _l1BidderController.dispose();
    _l1AmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FormDatePicker(
            label: 'Financial Bid Opening Date',
            selectedDate: _openingDate,
            onDateSelected: (date) {
              setState(() {
                _openingDate = date;
                _notifyDataChanged();
              });
            },
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _l1BidderController,
            onChanged: (_) => _notifyDataChanged(),
            decoration: const InputDecoration(
              labelText: 'L1 Bidder Name',
              hintText: 'Enter bidder name',
              prefixIcon: Icon(Icons.business, size: 20),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _l1AmountController,
            onChanged: (_) => _notifyDataChanged(),
            decoration: const InputDecoration(
              labelText: 'L1 Bid Amount (in Lakhs)',
              hintText: 'e.g., 450',
              prefixIcon: Icon(Icons.currency_rupee, size: 20),
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 24),

          const Text(
            'Recommended Bidder',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),

          DropdownButtonFormField<String>(
            value: _recommendedBidder,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.recommend, size: 20),
            ),
            items: _bidderOptions.map((option) {
              return DropdownMenuItem(
                value: option['value'],
                child: Text(option['label']!),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _recommendedBidder = value!;
                _notifyDataChanged();
              });
            },
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
