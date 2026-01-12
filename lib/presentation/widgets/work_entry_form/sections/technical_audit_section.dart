import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../section_common_fields.dart';
import '../form_date_picker.dart';

/// Technical Audit Section
/// Radio: Not Done/Carried Out with conditional fields
class TechnicalAuditSection extends StatefulWidget {
  final Map<String, dynamic> initialData;
  final Function(Map<String, dynamic>) onDataChanged;

  const TechnicalAuditSection({
    super.key,
    required this.initialData,
    required this.onDataChanged,
  });

  @override
  State<TechnicalAuditSection> createState() => _TechnicalAuditSectionState();
}

class _TechnicalAuditSectionState extends State<TechnicalAuditSection> {
  late TextEditingController _personResponsibleController;
  late TextEditingController _postHeldController;
  late TextEditingController _pendingWithController;
  late TextEditingController _agencyController;
  late TextEditingController _findingsController;
  late TextEditingController _recommendationsController;

  String _status = 'not_done'; // not_done or carried_out
  DateTime? _auditDate;

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
    _agencyController = TextEditingController();
    _findingsController = TextEditingController();
    _recommendationsController = TextEditingController();
  }

  void _loadInitialData() {
    if (widget.initialData.isNotEmpty) {
      _personResponsibleController.text =
          widget.initialData['person_responsible'] ?? '';
      _postHeldController.text = widget.initialData['post_held'] ?? '';
      _pendingWithController.text = widget.initialData['pending_with'] ?? '';

      final sectionData = widget.initialData['section_data'] ?? {};
      _status = sectionData['status'] ?? 'not_done';

      if (_status == 'carried_out') {
        _agencyController.text = sectionData['agency'] ?? '';
        _findingsController.text = sectionData['findings'] ?? '';
        _recommendationsController.text = sectionData['recommendations'] ?? '';
        if (sectionData['audit_date'] != null) {
          _auditDate = DateTime.parse(sectionData['audit_date']);
        }
      }
    }
  }

  void _notifyDataChanged() {
    final sectionData = <String, dynamic>{
      'status': _status,
    };

    if (_status == 'carried_out') {
      sectionData['audit_date'] = _auditDate?.toIso8601String();
      sectionData['agency'] = _agencyController.text;
      sectionData['findings'] = _findingsController.text;
      sectionData['recommendations'] = _recommendationsController.text;
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
    _agencyController.dispose();
    _findingsController.dispose();
    _recommendationsController.dispose();
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
            'Audit Status',
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
                  title: const Text('Not Done'),
                  value: 'not_done',
                  groupValue: _status,
                  onChanged: (value) {
                    setState(() {
                      _status = value!;
                      _notifyDataChanged();
                    });
                  },
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              Expanded(
                child: RadioListTile<String>(
                  title: const Text('Carried Out'),
                  value: 'carried_out',
                  groupValue: _status,
                  onChanged: (value) {
                    setState(() {
                      _status = value!;
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

          // Conditional Fields (if carried out)
          if (_status == 'carried_out') ...[
            FormDatePicker(
              label: 'Audit Date',
              selectedDate: _auditDate,
              onDateSelected: (date) {
                setState(() {
                  _auditDate = date;
                  _notifyDataChanged();
                });
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _agencyController,
              onChanged: (_) => _notifyDataChanged(),
              decoration: const InputDecoration(
                labelText: 'Audit Agency',
                hintText: 'Enter agency name',
                prefixIcon: Icon(Icons.business, size: 20),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _findingsController,
              onChanged: (_) => _notifyDataChanged(),
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Key Findings',
                hintText: 'Enter audit findings',
                prefixIcon: Icon(Icons.find_in_page, size: 20),
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _recommendationsController,
              onChanged: (_) => _notifyDataChanged(),
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Recommendations',
                hintText: 'Enter recommendations',
                prefixIcon: Icon(Icons.recommend, size: 20),
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
