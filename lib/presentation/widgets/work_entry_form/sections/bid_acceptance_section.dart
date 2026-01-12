import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../section_common_fields.dart';

/// Bid Acceptance Section
/// Status radio buttons (5 options)
class BidAcceptanceSection extends StatefulWidget {
  final Map<String, dynamic> initialData;
  final Function(Map<String, dynamic>) onDataChanged;

  const BidAcceptanceSection({
    super.key,
    required this.initialData,
    required this.onDataChanged,
  });

  @override
  State<BidAcceptanceSection> createState() => _BidAcceptanceSectionState();
}

class _BidAcceptanceSectionState extends State<BidAcceptanceSection> {
  late TextEditingController _personResponsibleController;
  late TextEditingController _postHeldController;
  late TextEditingController _pendingWithController;
  late TextEditingController _remarksController;

  String _selectedStatus = 'pending';

  final List<Map<String, String>> _statusOptions = [
    {'value': 'pending', 'label': 'Pending'},
    {'value': 'accepted', 'label': 'Accepted'},
    {'value': 'rejected', 'label': 'Rejected'},
    {'value': 'on_hold', 'label': 'On Hold'},
    {'value': 'cancelled', 'label': 'Cancelled'},
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
    _remarksController = TextEditingController();
  }

  void _loadInitialData() {
    if (widget.initialData.isNotEmpty) {
      _personResponsibleController.text =
          widget.initialData['person_responsible'] ?? '';
      _postHeldController.text = widget.initialData['post_held'] ?? '';
      _pendingWithController.text = widget.initialData['pending_with'] ?? '';

      final sectionData = widget.initialData['section_data'] ?? {};
      _selectedStatus = sectionData['status'] ?? 'pending';
      _remarksController.text = sectionData['remarks'] ?? '';
    }
  }

  void _notifyDataChanged() {
    widget.onDataChanged({
      'person_responsible': _personResponsibleController.text,
      'post_held': _postHeldController.text,
      'pending_with': _pendingWithController.text,
      'section_data': {
        'status': _selectedStatus,
        'remarks': _remarksController.text,
      },
    });
  }

  @override
  void dispose() {
    _personResponsibleController.dispose();
    _postHeldController.dispose();
    _pendingWithController.dispose();
    _remarksController.dispose();
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
            'Bid Acceptance Status',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),

          ..._statusOptions.map((option) {
            return RadioListTile<String>(
              title: Text(option['label']!),
              value: option['value']!,
              groupValue: _selectedStatus,
              onChanged: (value) {
                setState(() {
                  _selectedStatus = value!;
                  _notifyDataChanged();
                });
              },
              dense: true,
              contentPadding: EdgeInsets.zero,
            );
          }),

          const SizedBox(height: 24),

          TextFormField(
            controller: _remarksController,
            onChanged: (_) => _notifyDataChanged(),
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Remarks',
              hintText: 'Enter remarks',
              prefixIcon: Icon(Icons.notes, size: 20),
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
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
