import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../section_common_fields.dart';
import '../form_date_picker.dart';

/// EOT Section - Extension of Time
/// Radio: N/A or Applicable with checkboxes and conditional fields
class EOTSection extends StatefulWidget {
  final Map<String, dynamic> initialData;
  final Function(Map<String, dynamic>) onDataChanged;

  const EOTSection({
    super.key,
    required this.initialData,
    required this.onDataChanged,
  });

  @override
  State<EOTSection> createState() => _EOTSectionState();
}

class _EOTSectionState extends State<EOTSection> {
  late TextEditingController _personResponsibleController;
  late TextEditingController _postHeldController;
  late TextEditingController _pendingWithController;
  late TextEditingController _periodController;
  late TextEditingController _reasonController;

  String _applicability = 'na'; // na or applicable
  bool _isRequested = false;
  bool _isApproved = false;
  DateTime? _requestDate;
  DateTime? _approvalDate;

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
    _reasonController = TextEditingController();
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
        _isRequested = sectionData['is_requested'] ?? false;
        _isApproved = sectionData['is_approved'] ?? false;
        _periodController.text = sectionData['period_months']?.toString() ?? '';
        _reasonController.text = sectionData['reason'] ?? '';
        if (sectionData['request_date'] != null) {
          _requestDate = DateTime.parse(sectionData['request_date']);
        }
        if (sectionData['approval_date'] != null) {
          _approvalDate = DateTime.parse(sectionData['approval_date']);
        }
      }
    }
  }

  void _notifyDataChanged() {
    final sectionData = <String, dynamic>{
      'applicability': _applicability,
    };

    if (_applicability == 'applicable') {
      sectionData['is_requested'] = _isRequested;
      sectionData['is_approved'] = _isApproved;
      sectionData['period_months'] = _periodController.text;
      sectionData['reason'] = _reasonController.text;
      sectionData['request_date'] = _requestDate?.toIso8601String();
      sectionData['approval_date'] = _approvalDate?.toIso8601String();
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
    _periodController.dispose();
    _reasonController.dispose();
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
            'Applicability',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: RadioListTile<String>(
                  title: const Text('N/A'),
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
          const SizedBox(height: 24),

          // Conditional Fields (if applicable)
          if (_applicability == 'applicable') ...[
            // Status Checkboxes
            CheckboxListTile(
              title: const Text('Requested'),
              value: _isRequested,
              onChanged: (value) {
                setState(() {
                  _isRequested = value ?? false;
                  _notifyDataChanged();
                });
              },
              dense: true,
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
            ),

            CheckboxListTile(
              title: const Text('Approved'),
              value: _isApproved,
              onChanged: (value) {
                setState(() {
                  _isApproved = value ?? false;
                  _notifyDataChanged();
                });
              },
              dense: true,
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _periodController,
              onChanged: (_) => _notifyDataChanged(),
              decoration: const InputDecoration(
                labelText: 'Extension Period (in months)',
                hintText: 'e.g., 3',
                prefixIcon: Icon(Icons.calendar_month, size: 20),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            FormDatePicker(
              label: 'Request Date',
              selectedDate: _requestDate,
              onDateSelected: (date) {
                setState(() {
                  _requestDate = date;
                  _notifyDataChanged();
                });
              },
            ),
            const SizedBox(height: 16),

            if (_isApproved) ...[
              FormDatePicker(
                label: 'Approval Date',
                selectedDate: _approvalDate,
                onDateSelected: (date) {
                  setState(() {
                    _approvalDate = date;
                    _notifyDataChanged();
                  });
                },
              ),
              const SizedBox(height: 16),
            ],

            TextFormField(
              controller: _reasonController,
              onChanged: (_) => _notifyDataChanged(),
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Reason for EOT',
                hintText: 'Enter reason',
                prefixIcon: Icon(Icons.notes, size: 20),
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
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
