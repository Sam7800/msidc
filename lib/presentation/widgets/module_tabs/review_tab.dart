import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/project.dart';
import '../../../data/models/work_entry_section.dart';
import '../../../core/database/repositories/work_entry_repository.dart';
import '../../../core/database/repositories/critical_subsections_repository.dart';
import '../../../theme/app_colors.dart';

/// Review Tab - Compact read-only view fitting all activities in one screen
class ReviewTab extends ConsumerStatefulWidget {
  final Project project;
  final Color categoryColor;

  const ReviewTab({
    super.key,
    required this.project,
    required this.categoryColor,
  });

  @override
  ConsumerState<ReviewTab> createState() => _ReviewTabState();
}

class _ReviewTabState extends ConsumerState<ReviewTab> {
  late WorkEntryRepository _workEntryRepository;
  late CriticalSubsectionsRepository _criticalRepository;
  Map<String, WorkEntrySection> _sections = {};
  Set<String> _criticalSections = {};
  bool _isLoading = true;

  final Map<String, String> _sectionKeyToName = {
    'aa': 'AA',
    'dpr': 'DPR',
    'boq': 'BOQ',
    'schedules': 'Sch',
    'drawings': 'DWGs',
    'bid_documents': 'BID DOC',
    'env': 'ENV',
    'la': 'LA',
    'utility_shifting': 'Unity',
    'ts': 'TS',
    'nit': 'NIT',
    'pre_bid': 'Pre-Bid',
    'csd': 'CSD',
    'bid_submission': 'Bid Submit',
    'technical_evaluation': 'Tech Eval',
    'financial_bid': 'Fin Bid',
    'bid_acceptance': 'Bid Accept',
    'loa': 'LOA',
    'pbg': 'PBG',
    'work_order': 'Work Order',
    'agreement_amount': 'Agg Amt',
    'appointed_date': 'Appt Date',
    'tender_period': 'Tender',
    'ms1': 'MS-I',
    'ms2': 'MS-II',
    'ms3': 'MS-III',
    'ms4': 'MS-IV',
    'ms5': 'MS-V',
    'ld': 'LD',
    'eot': 'EOT',
    'cos': 'COS',
    'expenditure': 'Exp',
    'audit_para': 'Audit',
    'laq': 'LAQ',
    'technical_audit': 'Tech Audit',
    'rev_aa': 'Rev AA',
    'supplementary_agreement': 'Supp Agg',
  };

  final Map<String, List<String>> _sectionGroups = {
    'Pre-Tender & Approvals': [
      'aa', 'dpr', 'boq', 'schedules', 'drawings', 'bid_documents',
      'env', 'la', 'utility_shifting', 'ts'
    ],
    'Tender & Award': [
      'nit', 'pre_bid', 'csd', 'bid_submission', 'technical_evaluation',
      'financial_bid', 'bid_acceptance', 'loa', 'work_order', 'pbg'
    ],
    'Execution & Closure': [
      'agreement_amount', 'appointed_date', 'tender_period', 'ms1', 'ms2',
      'ms3', 'ms4', 'ms5', 'ld', 'eot', 'cos', 'expenditure', 'audit_para',
      'laq', 'technical_audit', 'rev_aa', 'supplementary_agreement'
    ],
  };

  @override
  void initState() {
    super.initState();
    _workEntryRepository = ref.read(workEntryRepositoryProvider);
    _criticalRepository = CriticalSubsectionsRepository();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final workEntry = await _workEntryRepository
          .getWorkEntryByProjectId(widget.project.id!);

      if (workEntry != null) {
        final sections = await _workEntryRepository
            .getSectionsByWorkEntryId(workEntry.id!);

        final nameToKey = <String, String>{};
        for (final entry in _sectionKeyToName.entries) {
          nameToKey[entry.value] = entry.key;
        }

        final sectionsMap = <String, WorkEntrySection>{};
        for (final section in sections) {
          final sectionKey = nameToKey[section.sectionName] ?? section.sectionName;
          sectionsMap[sectionKey] = section;
        }

        final criticals = await _criticalRepository
            .getCriticalSubsectionsByProjectId(widget.project.id!);

        final criticalSet = <String>{};
        for (final critical in criticals) {
          final sectionKey = nameToKey[critical['section_name']] ?? critical['section_name'];
          criticalSet.add(sectionKey);
        }

        setState(() {
          _sections = sectionsMap;
          _criticalSections = criticalSet;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Color _getStatusColor(String? sectionKey) {
    if (sectionKey == null) {
      return const Color(0xFFBDBDBD);
    }

    if (_criticalSections.contains(sectionKey)) {
      return const Color(0xFFEF5350);
    }

    if (!_sections.containsKey(sectionKey)) {
      return const Color(0xFFBDBDBD);
    }

    final section = _sections[sectionKey]!;
    final sectionData = section.sectionData;

    if (sectionData.isEmpty) {
      return const Color(0xFFBDBDBD);
    }

    final status = sectionData['status'] as String?;
    if (status == 'completed' || status == 'accorded' || status == 'accepted') {
      return const Color(0xFF66BB6A);
    } else if (status == 'in_progress' || status == 'submitted' || status == 'awaited') {
      return const Color(0xFFFF9800);
    }

    return const Color(0xFFBDBDBD);
  }

  void _showSectionDetails(String sectionKey) {
    final section = _sections[sectionKey];
    final sectionName = _sectionKeyToName[sectionKey] ?? sectionKey;
    final statusColor = _getStatusColor(sectionKey);
    final statusText = _getChipSecondaryText(sectionKey);

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 8,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800, maxHeight: 700),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
          ),
          child: Column(
            children: [
              // Modern Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [widget.categoryColor, widget.categoryColor.withOpacity(0.85)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                      color: widget.categoryColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getSectionIcon(sectionKey),
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            sectionName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: statusColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  statusText,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  widget.project.name,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.white70,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Material(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      child: InkWell(
                        onTap: () => Navigator.pop(context),
                        borderRadius: BorderRadius.circular(8),
                        child: const Padding(
                          padding: EdgeInsets.all(8),
                          child: Icon(Icons.close, size: 20, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: section == null || section.sectionData.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.inbox_outlined,
                                size: 56,
                                color: Colors.grey[400],
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No data available',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'This section has not been filled yet',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Tracking Info
                            if (section.personResponsible?.isNotEmpty == true ||
                                section.heldWith?.isNotEmpty == true ||
                                section.pendingWith?.isNotEmpty == true)
                              Container(
                                margin: const EdgeInsets.only(bottom: 20),
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Colors.blue.shade50, Colors.blue.shade50.withOpacity(0.5)],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.blue.shade200, width: 1.5),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.blue.shade100,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Icon(
                                            Icons.people_outline,
                                            size: 18,
                                            color: Colors.blue.shade700,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          'Tracking Information',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.blue.shade900,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    _buildDetailRow(
                                      Icons.person_outline,
                                      'Person Responsible',
                                      section.personResponsible ?? '-',
                                      Colors.blue.shade700,
                                    ),
                                    const SizedBox(height: 12),
                                    _buildDetailRow(
                                      Icons.badge_outlined,
                                      'Post Held',
                                      section.heldWith ?? '-',
                                      Colors.blue.shade700,
                                    ),
                                    const SizedBox(height: 12),
                                    _buildDetailRow(
                                      Icons.pending_actions,
                                      'Pending With',
                                      section.pendingWith ?? '-',
                                      Colors.blue.shade700,
                                    ),
                                  ],
                                ),
                              ),
                            // Section Data
                            if (section.sectionData.isNotEmpty) ...[
                              Row(
                                children: [
                                  Container(
                                    width: 4,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      color: widget.categoryColor,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Section Details',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: widget.categoryColor,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              ..._buildEnhancedSectionDataWidgets(section.sectionData),
                            ],
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getSectionIcon(String sectionKey) {
    const iconMap = {
      'aa': Icons.assignment_outlined,
      'dpr': Icons.description_outlined,
      'boq': Icons.calculate_outlined,
      'nit': Icons.gavel_outlined,
      'loa': Icons.done_all,
      'pbg': Icons.shield_outlined,
      'work_order': Icons.work_outline,
      'ms1': Icons.flag_outlined,
      'ms2': Icons.flag_outlined,
      'ms3': Icons.flag_outlined,
      'ms4': Icons.flag_outlined,
      'ms5': Icons.flag_outlined,
      'ld': Icons.warning_amber_outlined,
      'eot': Icons.schedule_outlined,
      'audit_para': Icons.fact_check_outlined,
    };
    return iconMap[sectionKey] ?? Icons.folder_outlined;
  }

  String _getChipSecondaryText(String sectionKey) {
    final section = _sections[sectionKey];

    if (section == null || section.sectionData.isEmpty) {
      return 'Not Started';
    }

    final sectionData = section.sectionData;

    // Priority 1: Check for status
    final status = sectionData['status'] as String?;
    if (status != null && status.isNotEmpty) {
      return _formatStatusText(status);
    }

    // Priority 2: Check for date fields
    for (final key in sectionData.keys) {
      if (key.toLowerCase().contains('date')) {
        final dateValue = sectionData[key];
        if (dateValue != null && dateValue.toString().isNotEmpty) {
          try {
            if (dateValue is String && dateValue.contains('T')) {
              final date = DateTime.parse(dateValue);
              return '${date.day}/${date.month}/${date.year}';
            }
            return dateValue.toString();
          } catch (_) {}
        }
      }
    }

    // Priority 3: Check for amount/value fields
    for (final key in ['amount', 'value', 'cost', 'expenditure']) {
      if (sectionData.containsKey(key) && sectionData[key] != null) {
        return sectionData[key].toString();
      }
    }

    // Priority 4: Return "In Progress" if any data exists
    return 'In Progress';
  }

  String _formatStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'accorded':
      case 'accepted':
        return 'Completed';
      case 'in_progress':
      case 'submitted':
      case 'awaited':
        return 'In Progress';
      case 'pending':
        return 'Pending';
      default:
        return status;
    }
  }

  Widget _buildDetailRow(IconData icon, String label, String value, Color iconColor) {
    return Row(
      children: [
        Icon(icon, size: 16, color: iconColor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildEnhancedSectionDataWidgets(Map<String, dynamic> data) {
    final widgets = <Widget>[];
    int index = 0;

    data.forEach((key, value) {
      if (value != null && value.toString().isNotEmpty && key != 'status') {
        String displayValue = value.toString();
        IconData fieldIcon = Icons.info_outline;

        // Format dates
        if (key.contains('date') && value is String && value.contains('T')) {
          try {
            final date = DateTime.parse(value);
            displayValue = '${date.day}/${date.month}/${date.year}';
            fieldIcon = Icons.calendar_today_outlined;
          } catch (_) {}
        }

        // Handle lists
        if (value is List) {
          displayValue = '${value.length} items';
          fieldIcon = Icons.list_alt;
        }

        // Handle maps
        if (value is Map) {
          displayValue = '${value.length} fields';
          fieldIcon = Icons.folder_outlined;
        }

        // Choose icon based on field name
        if (key.contains('amount') || key.contains('cost') || key.contains('expenditure')) {
          fieldIcon = Icons.currency_rupee;
        } else if (key.contains('person') || key.contains('responsible')) {
          fieldIcon = Icons.person_outline;
        } else if (key.contains('location') || key.contains('address')) {
          fieldIcon = Icons.location_on_outlined;
        } else if (key.contains('document') || key.contains('file')) {
          fieldIcon = Icons.description_outlined;
        }

        widgets.add(
          Container(
            margin: EdgeInsets.only(bottom: index < data.length - 1 ? 12 : 0),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade200, width: 1),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: widget.categoryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    fieldIcon,
                    size: 18,
                    color: widget.categoryColor,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatKey(key),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        displayValue,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
        index++;
      }
    });

    return widgets.isEmpty
        ? [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'No details available',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
              ),
            )
          ]
        : widgets;
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSectionDataRows(Map<String, dynamic> data) {
    final rows = <Widget>[];
    data.forEach((key, value) {
      if (value != null && value.toString().isNotEmpty && key != 'status') {
        String displayValue = value.toString();
        if (key.contains('date') && value is String && value.contains('T')) {
          try {
            final date = DateTime.parse(value);
            displayValue = '${date.day}/${date.month}/${date.year}';
          } catch (_) {}
        }
        if (value is List) displayValue = '${value.length} items';
        if (value is Map) displayValue = '${value.length} fields';

        rows.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                SizedBox(
                  width: 140,
                  child: Text(
                    _formatKey(key),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    displayValue,
                    style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    });
    return rows.isEmpty
        ? [const Text('No details', style: TextStyle(fontSize: 12, color: AppColors.textSecondary))]
        : rows;
  }

  String _formatKey(String key) {
    return key
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Status Legend - Centered
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade200, width: 1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem(const Color(0xFFEF5350), 'Critical'),
                const SizedBox(width: 16),
                _buildLegendItem(const Color(0xFF66BB6A), 'Completed'),
                const SizedBox(width: 16),
                _buildLegendItem(const Color(0xFFFF9800), 'In Progress'),
                const SizedBox(width: 16),
                _buildLegendItem(const Color(0xFFBDBDBD), 'Not Started'),
              ],
            ),
          ),

          // All Sections - Fit in one view
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Row 1: Pre-Tender & Approvals
                  Expanded(
                    child: _buildSectionCard(
                      'Pre-Tender & Approvals',
                      _sectionGroups['Pre-Tender & Approvals']!,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Row 2: Tender & Award
                  Expanded(
                    child: _buildSectionCard(
                      'Tender & Award',
                      _sectionGroups['Tender & Award']!,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Row 3: Execution & Closure
                  Expanded(
                    child: _buildSectionCard(
                      'Execution & Closure',
                      _sectionGroups['Execution & Closure']!,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(String title, List<String> activities) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Compact Card Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: widget.categoryColor.withOpacity(0.05),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              border: Border(
                bottom: BorderSide(color: widget.categoryColor.withOpacity(0.15), width: 1),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 3,
                  height: 12,
                  decoration: BoxDecoration(
                    color: widget.categoryColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: widget.categoryColor,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
          // Card Body with more space
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.start,
                  children: activities.map((key) => _buildActivityChip(key)).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityChip(String sectionKey) {
    final sectionName = _sectionKeyToName[sectionKey] ?? sectionKey;
    final statusColor = _getStatusColor(sectionKey);
    final hasData = _sections.containsKey(sectionKey);
    final secondaryText = _getChipSecondaryText(sectionKey);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showSectionDetails(sectionKey),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: statusColor.withOpacity(0.4), width: 1.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: statusColor.withOpacity(0.4),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sectionName,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: hasData ? AppColors.textPrimary : AppColors.textSecondary,
                      letterSpacing: 0.3,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    secondaryText,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                      letterSpacing: 0.2,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
