import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../section_common_fields.dart';

/// Technical Audit Section
/// Radio: Not done/Carried Out with conditional fields
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
  late TextEditingController _findingsCountController;
  late TextEditingController _detailsOfFindingsController;
  late TextEditingController _responsibleEEController;
  late TextEditingController _complianceController;

  String _status = 'not_done'; // not_done or carried_out

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
    _findingsCountController = TextEditingController();
    _detailsOfFindingsController = TextEditingController();
    _responsibleEEController = TextEditingController();
    _complianceController = TextEditingController();
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
        _findingsCountController.text = sectionData['findings_count'] ?? '';
        _detailsOfFindingsController.text = sectionData['details_of_findings'] ?? '';
        _responsibleEEController.text = sectionData['responsible_ee'] ?? '';
        _complianceController.text = sectionData['compliance'] ?? '';
      }
    }
  }

  void _notifyDataChanged() {
    final sectionData = <String, dynamic>{
      'status': _status,
    };

    if (_status == 'carried_out') {
      sectionData['findings_count'] = _findingsCountController.text;
      sectionData['details_of_findings'] = _detailsOfFindingsController.text;
      sectionData['responsible_ee'] = _responsibleEEController.text;
      sectionData['compliance'] = _complianceController.text;
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
    _findingsCountController.dispose();
    _detailsOfFindingsController.dispose();
    _responsibleEEController.dispose();
    _complianceController.dispose();
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
            'Technical Audit:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          // Not done / Carried Out
          Row(
            children: [
              Expanded(
                child: RadioListTile<String>(
                  title: const Text('Not done'),
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

          // If Applicable (Carried Out)
          if (_status == 'carried_out') ...[
            const SizedBox(height: 16),

            // # of findings
            const Text(
              '# of findings',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _findingsCountController,
              onChanged: (_) => _notifyDataChanged(),
              decoration: const InputDecoration(
                hintText: 'Enter number',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            // Details of findings
            const Text(
              'Details of findings',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _detailsOfFindingsController,
              onChanged: (_) => _notifyDataChanged(),
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Enter details',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Responsible EE
            const Text(
              'Responsible EE',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _responsibleEEController,
              onChanged: (_) => _notifyDataChanged(),
              decoration: const InputDecoration(
                hintText: 'Enter name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Compliance Submitted: # and Dates
            const Text(
              'Compliance Submitted: # and Dates',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _complianceController,
              onChanged: (_) => _notifyDataChanged(),
              decoration: const InputDecoration(
                hintText: 'Enter details',
                border: OutlineInputBorder(),
              ),
            ),
          ],

          const SizedBox(height: 24),

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
