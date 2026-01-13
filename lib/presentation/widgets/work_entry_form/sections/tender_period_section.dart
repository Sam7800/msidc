import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../section_common_fields.dart';

/// Tender Period Section
class TenderPeriodSection extends StatefulWidget {
  final Map<String, dynamic> initialData;
  final Function(Map<String, dynamic>) onDataChanged;
  final bool isEditMode;

  const TenderPeriodSection({
    super.key,
    required this.initialData,
    required this.onDataChanged,
    required this.isEditMode,
  });

  @override
  State<TenderPeriodSection> createState() => _TenderPeriodSectionState();
}

class _TenderPeriodSectionState extends State<TenderPeriodSection> {
  late TextEditingController _personResponsibleController;
  late TextEditingController _postHeldController;
  late TextEditingController _pendingWithController;
  late TextEditingController _periodController;

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
    _periodController = TextEditingController();
  }

  void _loadInitialData() {
    if (widget.initialData.isNotEmpty) {
      _personResponsibleController.text =
          widget.initialData['person_responsible'] ?? '';
      _postHeldController.text = widget.initialData['post_held'] ?? '';
      _pendingWithController.text = widget.initialData['pending_with'] ?? '';

      final sectionData = widget.initialData['section_data'] ?? {};
      _periodController.text = sectionData['period_months']?.toString() ?? '';
    }
  }

  void _notifyDataChanged() {
    widget.onDataChanged({
      'person_responsible': _personResponsibleController.text,
      'post_held': _postHeldController.text,
      'pending_with': _pendingWithController.text,
      'section_data': {
        'period_months': _periodController.text,
      },
    });
  }

  @override
  void dispose() {
    _personResponsibleController.dispose();
    _postHeldController.dispose();
    _pendingWithController.dispose();
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
            controller: _periodController,
            onChanged: (_) => _notifyDataChanged(),
            enabled: widget.isEditMode,
            decoration: const InputDecoration(
              labelText: 'Tender Period (in months)',
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
            enabled: widget.isEditMode,
            onChanged: _notifyDataChanged,
          ),
        ],
      ),
    );
  }
}
