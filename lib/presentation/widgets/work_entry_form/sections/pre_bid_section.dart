import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../section_common_fields.dart';
import '../form_date_picker.dart';

/// Pre-bid Section
/// Date + bidders count
class PreBidSection extends StatefulWidget {
  final Map<String, dynamic> initialData;
  final Function(Map<String, dynamic>) onDataChanged;

  const PreBidSection({
    super.key,
    required this.initialData,
    required this.onDataChanged,
  });

  @override
  State<PreBidSection> createState() => _PreBidSectionState();
}

class _PreBidSectionState extends State<PreBidSection> {
  late TextEditingController _personResponsibleController;
  late TextEditingController _postHeldController;
  late TextEditingController _pendingWithController;
  late TextEditingController _biddersCountController;

  DateTime? _preBidDate;

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
    _biddersCountController = TextEditingController();
  }

  void _loadInitialData() {
    if (widget.initialData.isNotEmpty) {
      _personResponsibleController.text =
          widget.initialData['person_responsible'] ?? '';
      _postHeldController.text = widget.initialData['post_held'] ?? '';
      _pendingWithController.text = widget.initialData['pending_with'] ?? '';

      final sectionData = widget.initialData['section_data'] ?? {};
      _biddersCountController.text = sectionData['bidders_count']?.toString() ?? '';
      if (sectionData['pre_bid_date'] != null) {
        _preBidDate = DateTime.parse(sectionData['pre_bid_date']);
      }
    }
  }

  void _notifyDataChanged() {
    widget.onDataChanged({
      'person_responsible': _personResponsibleController.text,
      'post_held': _postHeldController.text,
      'pending_with': _pendingWithController.text,
      'section_data': {
        'pre_bid_date': _preBidDate?.toIso8601String(),
        'bidders_count': _biddersCountController.text,
      },
    });
  }

  @override
  void dispose() {
    _personResponsibleController.dispose();
    _postHeldController.dispose();
    _pendingWithController.dispose();
    _biddersCountController.dispose();
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
            label: 'Pre-bid Meeting Date',
            selectedDate: _preBidDate,
            onDateSelected: (date) {
              setState(() {
                _preBidDate = date;
                _notifyDataChanged();
              });
            },
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _biddersCountController,
            onChanged: (_) => _notifyDataChanged(),
            decoration: const InputDecoration(
              labelText: 'Number of Bidders Attended',
              hintText: 'e.g., 5',
              prefixIcon: Icon(Icons.people, size: 20),
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
