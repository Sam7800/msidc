import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../section_common_fields.dart';
import '../form_date_picker.dart';
import '../critical_bell_icon.dart';

/// EOT Section - Extension of Time
/// Radio: N/A or Applicable with checkboxes and conditional fields
class EOTSection extends StatefulWidget {
  final int? projectId;
  final Map<String, dynamic> initialData;
  final Function(Map<String, dynamic>) onDataChanged;
  final bool isEditMode;

  const EOTSection({
    super.key,
    required this.projectId,
    required this.initialData,
    required this.onDataChanged,
    required this.isEditMode,
  });

  @override
  State<EOTSection> createState() => _EOTSectionState();
}

class _EOTSectionState extends State<EOTSection> {
  late TextEditingController _personResponsibleController;
  late TextEditingController _postHeldController;
  late TextEditingController _pendingWithController;
  late TextEditingController _periodUnderConsiderationController;
  late TextEditingController _approvedPeriodController;
  late TextEditingController _compensationClaimedController;
  late TextEditingController _compensationAdmittedController;

  String _applicability = 'na'; // na or applicable
  String _proposalStatus = 'not_started'; // not_started, under_consideration, submitted
  DateTime? _submittedDate;
  String _escalationStatus = 'with_escalation'; // with_escalation, without_escalation
  bool _byFreezingIndices = false;
  String _ldStatus = 'without_ld'; // without_ld, with_ld
  String _compensationPayable = 'no'; // yes or no

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
    _periodUnderConsiderationController = TextEditingController();
    _approvedPeriodController = TextEditingController();
    _compensationClaimedController = TextEditingController();
    _compensationAdmittedController = TextEditingController();
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
        _proposalStatus = sectionData['proposal_status'] ?? 'not_started';
        _periodUnderConsiderationController.text = sectionData['period_under_consideration'] ?? '';
        if (sectionData['submitted_date'] != null) {
          _submittedDate = DateTime.parse(sectionData['submitted_date']);
        }
        _approvedPeriodController.text = sectionData['approved_period'] ?? '';
        _escalationStatus = sectionData['escalation_status'] ?? 'with_escalation';
        _byFreezingIndices = sectionData['by_freezing_indices'] ?? false;
        _ldStatus = sectionData['ld_status'] ?? 'without_ld';
        _compensationPayable = sectionData['compensation_payable'] ?? 'no';
        _compensationClaimedController.text = sectionData['compensation_claimed'] ?? '';
        _compensationAdmittedController.text = sectionData['compensation_admitted'] ?? '';
      }
    }
  }

  void _notifyDataChanged() {
    final sectionData = <String, dynamic>{
      'applicability': _applicability,
    };

    if (_applicability == 'applicable') {
      sectionData['proposal_status'] = _proposalStatus;
      sectionData['period_under_consideration'] = _periodUnderConsiderationController.text;
      sectionData['submitted_date'] = _submittedDate?.toIso8601String();
      sectionData['approved_period'] = _approvedPeriodController.text;
      sectionData['escalation_status'] = _escalationStatus;
      sectionData['by_freezing_indices'] = _byFreezingIndices;
      sectionData['ld_status'] = _ldStatus;
      sectionData['compensation_payable'] = _compensationPayable;
      sectionData['compensation_claimed'] = _compensationClaimedController.text;
      sectionData['compensation_admitted'] = _compensationAdmittedController.text;
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
    _periodUnderConsiderationController.dispose();
    _approvedPeriodController.dispose();
    _compensationClaimedController.dispose();
    _compensationAdmittedController.dispose();
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
            'EOT (Extension of Time):',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          // Not Applicable / Applicable
          Row(
            children: [
              Expanded(
                child: RadioListTile<String>(
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
              ),
              Expanded(
                child: RadioListTile<String>(
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
              ),
            ],
          ),

          // If Applicable
          if (_applicability == 'applicable') ...[
            const SizedBox(height: 16),

            // Proposal Not started
            RadioListTile<String>(
              title: const Text('Proposal Not started'),
              value: 'not_started',
              groupValue: _proposalStatus,
              onChanged: widget.isEditMode ? (value) {
                setState(() {
                  _proposalStatus = value!;
                  _notifyDataChanged();
                });
              } : null,
              dense: true,
              contentPadding: EdgeInsets.zero,
            ),

            // Proposal under Consideration – Period (Months)
            RadioListTile<String>(
              title: const Text('Proposal under Consideration – Period (Months)'),
              value: 'under_consideration',
              groupValue: _proposalStatus,
              onChanged: widget.isEditMode ? (value) {
                setState(() {
                  _proposalStatus = value!;
                  _notifyDataChanged();
                });
              } : null,
              dense: true,
              contentPadding: EdgeInsets.zero,
            ),
            if (_proposalStatus == 'under_consideration') ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 24),
                child: TextFormField(
                  controller: _periodUnderConsiderationController,
                  onChanged: (_) => _notifyDataChanged(),
                  enabled: widget.isEditMode,
                  decoration: const InputDecoration(
                    hintText: 'Enter period in months',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
            const SizedBox(height: 8),

            // Proposal Submitted: Date (with bell icon)
            Row(
              children: [
                Radio<String>(
                  value: 'submitted',
                  groupValue: _proposalStatus,
                  onChanged: widget.isEditMode ? (value) {
                    setState(() {
                      _proposalStatus = value!;
                      _notifyDataChanged();
                    });
                  } : null,
                ),
                const Text(
                  'Proposal Submitted: Date',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(width: 8),
                CriticalBellIcon(
                  projectId: widget.projectId,
                  sectionName: 'EOT',
                  optionName: 'Proposal Submitted',
                ),
              ],
            ),
            if (_proposalStatus == 'submitted') ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 24),
                child: FormDatePicker(
                  label: '',
                  selectedDate: _submittedDate,
                  onDateSelected: (date) {
                    setState(() {
                      _submittedDate = date;
                      _notifyDataChanged();
                    });
                  },
                  enabled: widget.isEditMode,
                ),
              ),
            ],
            const SizedBox(height: 16),

            // EOT Approved – Period (Months)
            const Text(
              'EOT Approved – Period (Months)',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _approvedPeriodController,
              onChanged: (_) => _notifyDataChanged(),
              enabled: widget.isEditMode,
              decoration: const InputDecoration(
                hintText: 'Enter approved period in months',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            // With Escalation / Without Escalation
            const Text(
              'Escalation:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            RadioListTile<String>(
              title: const Text('With Escalation'),
              value: 'with_escalation',
              groupValue: _escalationStatus,
              onChanged: widget.isEditMode ? (value) {
                setState(() {
                  _escalationStatus = value!;
                  _notifyDataChanged();
                });
              } : null,
              dense: true,
              contentPadding: EdgeInsets.zero,
            ),
            RadioListTile<String>(
              title: const Text('Without Escalation'),
              value: 'without_escalation',
              groupValue: _escalationStatus,
              onChanged: widget.isEditMode ? (value) {
                setState(() {
                  _escalationStatus = value!;
                  _notifyDataChanged();
                });
              } : null,
              dense: true,
              contentPadding: EdgeInsets.zero,
            ),

            // By freezing Indices
            CheckboxListTile(
              title: const Text('By freezing Indices'),
              value: _byFreezingIndices,
              onChanged: widget.isEditMode ? (value) {
                setState(() {
                  _byFreezingIndices = value ?? false;
                  _notifyDataChanged();
                });
              } : null,
              dense: true,
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
            ),

            const SizedBox(height: 8),

            // Without LD / With LD
            RadioListTile<String>(
              title: const Text('Without LD'),
              value: 'without_ld',
              groupValue: _ldStatus,
              onChanged: widget.isEditMode ? (value) {
                setState(() {
                  _ldStatus = value!;
                  _notifyDataChanged();
                });
              } : null,
              dense: true,
              contentPadding: EdgeInsets.zero,
            ),
            RadioListTile<String>(
              title: const Text('With LD'),
              value: 'with_ld',
              groupValue: _ldStatus,
              onChanged: widget.isEditMode ? (value) {
                setState(() {
                  _ldStatus = value!;
                  _notifyDataChanged();
                });
              } : null,
              dense: true,
              contentPadding: EdgeInsets.zero,
            ),

            const SizedBox(height: 16),

            // Compensation payable
            const Text(
              'Compensation payable',
              style: TextStyle(fontSize: 14),
            ),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Yes'),
                    value: 'yes',
                    groupValue: _compensationPayable,
                    onChanged: widget.isEditMode ? (value) {
                      setState(() {
                        _compensationPayable = value!;
                        _notifyDataChanged();
                      });
                    } : null,
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('No'),
                    value: 'no',
                    groupValue: _compensationPayable,
                    onChanged: widget.isEditMode ? (value) {
                      setState(() {
                        _compensationPayable = value!;
                        _notifyDataChanged();
                      });
                    } : null,
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),

            // Show compensation fields when Yes
            if (_compensationPayable == 'yes') ...[
              const SizedBox(height: 16),

              // Amount of compensation Claimed
              const Text(
                'Amount of compensation Claimed',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _compensationClaimedController,
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

              // Compensation admitted - Amount
              const Text(
                'Compensation admitted - Amount',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _compensationAdmittedController,
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
