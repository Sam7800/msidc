import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/project.dart';
import '../../../theme/app_colors.dart';
import 'sections/aa_section.dart';
import 'sections/dpr_section.dart';
import 'sections/boq_section.dart';
import 'sections/schedules_section.dart';
import 'sections/drawings_section.dart';
import 'sections/bid_documents_section.dart';
import 'sections/env_section.dart';
import 'sections/la_section.dart';
import 'sections/utility_shifting_section.dart';
import 'sections/ts_section.dart';
import 'sections/nit_section.dart';
import 'sections/pre_bid_section.dart';
import 'sections/csd_section.dart';
import 'sections/bid_submission_section.dart';
import 'sections/technical_evaluation_section.dart';
import 'sections/financial_bid_section.dart';
import 'sections/bid_acceptance_section.dart';
import 'sections/loa_section.dart';
import 'sections/pbg_section.dart';
import 'sections/work_order_section.dart';
import 'sections/agreement_amount_section.dart';
import 'sections/appointed_date_section.dart';
import 'sections/tender_period_section.dart';
import 'sections/milestone_section.dart';
import 'sections/ld_section.dart';
import 'sections/eot_section.dart';
import 'sections/cos_section.dart';
import 'sections/expenditure_section.dart';
import 'sections/audit_para_section.dart';
import 'sections/laq_section.dart';
import 'sections/technical_audit_section.dart';
import 'sections/rev_aa_section.dart';
import 'sections/supplementary_agreement_section.dart';

/// Main Work Entry Tab - Accordion-style with expandable sections
/// All sections on one page with search and edit functionality
class WorkEntryTab extends ConsumerStatefulWidget {
  final Project project;
  final Color categoryColor;

  const WorkEntryTab({
    super.key,
    required this.project,
    required this.categoryColor,
  });

  @override
  ConsumerState<WorkEntryTab> createState() => _WorkEntryTabState();
}

class _WorkEntryTabState extends ConsumerState<WorkEntryTab> {
  final TextEditingController _searchController = TextEditingController();
  final Map<String, bool> _expandedSections = {};
  final Map<String, Map<String, dynamic>> _sectionData = {};
  bool _isEditMode = false;
  String _searchQuery = '';

  // Define all 35 sections in correct sequence
  final List<Map<String, dynamic>> _sections = [
    {'id': 'aa', 'name': 'AA - Administrative Approval', 'subtitle': 'Awaited or Accorded with details', 'icon': Icons.approval, 'color': Colors.green},
    {'id': 'dpr', 'name': 'DPR - Detailed Project Report', 'subtitle': 'Status tracking with completion date', 'icon': Icons.description, 'color': Colors.blue},
    {'id': 'boq', 'name': 'BOQ - Bill of Quantities', 'subtitle': 'Items breakdown and amounts', 'icon': Icons.format_list_bulleted, 'color': Colors.orange},
    {'id': 'schedules', 'name': 'Schedules', 'subtitle': 'Schedule preparation status', 'icon': Icons.schedule, 'color': Colors.purple},
    {'id': 'drawings', 'name': 'Drawings', 'subtitle': 'Drawing preparation status', 'icon': Icons.architecture, 'color': Colors.teal},
    {'id': 'bid_documents', 'name': 'Bid Documents', 'subtitle': 'Bid document preparation', 'icon': Icons.document_scanner, 'color': Colors.indigo},
    {'id': 'env', 'name': 'ENV - Environmental Clearance', 'subtitle': 'Environmental clearance status', 'icon': Icons.eco, 'color': Colors.green},
    {'id': 'la', 'name': 'LA - Land Acquisition', 'subtitle': 'Land acquisition details', 'icon': Icons.landscape, 'color': Colors.brown},
    {'id': 'utility_shifting', 'name': 'Utility Shifting', 'subtitle': 'Utility relocation status', 'icon': Icons.construction, 'color': Colors.amber},
    {'id': 'ts', 'name': 'TS - Technical Sanction', 'subtitle': 'Technical sanction with items', 'icon': Icons.engineering, 'color': Colors.deepPurple},
    {'id': 'nit', 'name': 'NIT - Notice Inviting Tender', 'subtitle': 'NIT issuance with bidders and photos', 'icon': Icons.campaign, 'color': Colors.red},
    {'id': 'pre_bid', 'name': 'Pre-bid Meeting', 'subtitle': 'Pre-bid meeting details', 'icon': Icons.meeting_room, 'color': Colors.cyan},
    {'id': 'csd', 'name': 'CSD - Common Set of Deviations', 'subtitle': 'CSD submission status', 'icon': Icons.rule, 'color': Colors.pink},
    {'id': 'bid_submission', 'name': 'Bid Submission', 'subtitle': 'Bid submission date and count', 'icon': Icons.send, 'color': Colors.lightGreen},
    {'id': 'technical_evaluation', 'name': 'Technical Evaluation', 'subtitle': 'Technical evaluation status', 'icon': Icons.assessment, 'color': Colors.deepOrange},
    {'id': 'financial_bid', 'name': 'Financial Bid', 'subtitle': 'Financial bid opening details', 'icon': Icons.currency_rupee, 'color': Colors.green},
    {'id': 'bid_acceptance', 'name': 'Bid Acceptance', 'subtitle': 'Bid acceptance status', 'icon': Icons.done_all, 'color': Colors.lightBlue},
    {'id': 'loa', 'name': 'LOA - Letter of Acceptance', 'subtitle': 'LOA issuance details', 'icon': Icons.mail, 'color': Colors.blue},
    {'id': 'pbg', 'name': 'PBG - Performance Bank Guarantee', 'subtitle': 'PBG submission status', 'icon': Icons.account_balance, 'color': Colors.indigo},
    {'id': 'work_order', 'name': 'Work Order', 'subtitle': 'Work order issuance', 'icon': Icons.work, 'color': Colors.teal},
    {'id': 'agreement_amount', 'name': 'Agreement Amount', 'subtitle': 'Agreement amount in Lakhs', 'icon': Icons.currency_rupee, 'color': Colors.purple},
    {'id': 'appointed_date', 'name': 'Appointed Date', 'subtitle': 'Date of appointment', 'icon': Icons.calendar_today, 'color': Colors.deepPurple},
    {'id': 'tender_period', 'name': 'Tender Period', 'subtitle': 'Period in months', 'icon': Icons.calendar_month, 'color': Colors.indigo},
    {'id': 'ms1', 'name': 'MS-I - Milestone I', 'subtitle': 'First milestone tracking', 'icon': Icons.flag, 'color': Colors.orange},
    {'id': 'ms2', 'name': 'MS-II - Milestone II', 'subtitle': 'Second milestone tracking', 'icon': Icons.flag, 'color': Colors.deepOrange},
    {'id': 'ms3', 'name': 'MS-III - Milestone III', 'subtitle': 'Third milestone tracking', 'icon': Icons.flag, 'color': Colors.red},
    {'id': 'ms4', 'name': 'MS-IV - Milestone IV', 'subtitle': 'Fourth milestone tracking', 'icon': Icons.flag, 'color': Colors.pink},
    {'id': 'ms5', 'name': 'MS-V - Milestone V', 'subtitle': 'Fifth milestone tracking', 'icon': Icons.flag, 'color': Colors.purple},
    {'id': 'ld', 'name': 'LD - Liquidated Damages', 'subtitle': 'Liquidated damages status', 'icon': Icons.gavel, 'color': Colors.red},
    {'id': 'eot', 'name': 'EOT - Extension of Time', 'subtitle': 'Time extension details', 'icon': Icons.access_time, 'color': Colors.amber},
    {'id': 'cos', 'name': 'COS - Change of Scope', 'subtitle': 'Scope changes with items', 'icon': Icons.change_circle, 'color': Colors.blue},
    {'id': 'expenditure', 'name': 'Expenditure', 'subtitle': 'Cumulative expenditure tracking', 'icon': Icons.account_balance_wallet, 'color': Colors.green},
    {'id': 'audit_para', 'name': 'Audit Para', 'subtitle': 'Audit paras and compliance', 'icon': Icons.fact_check, 'color': Colors.orange},
    {'id': 'laq', 'name': 'LAQ - Legislative Questions', 'subtitle': 'Legislative assembly questions', 'icon': Icons.question_answer, 'color': Colors.indigo},
    {'id': 'technical_audit', 'name': 'Technical Audit', 'subtitle': 'Technical audit details', 'icon': Icons.checklist, 'color': Colors.teal},
    {'id': 'rev_aa', 'name': 'Rev AA - Revised Administrative Approval', 'subtitle': 'Revised AA details', 'icon': Icons.update, 'color': Colors.deepPurple},
    {'id': 'supplementary_agreement', 'name': 'Supplementary Agreement', 'subtitle': 'Supplementary agreement details', 'icon': Icons.post_add, 'color': Colors.cyan},
  ];

  @override
  void initState() {
    super.initState();
    // Initialize all sections as expanded
    for (var section in _sections) {
      _expandedSections[section['id']] = true;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredSections {
    if (_searchQuery.isEmpty) return _sections;
    return _sections.where((section) {
      final name = section['name'].toString().toLowerCase();
      final subtitle = section['subtitle'].toString().toLowerCase();
      final query = _searchQuery.toLowerCase();
      return name.contains(query) || subtitle.contains(query);
    }).toList();
  }

  void _onSectionDataChanged(String sectionId, Map<String, dynamic> data) {
    setState(() {
      _sectionData[sectionId] = data;
    });
  }

  Widget _buildSectionContent(String sectionId) {
    switch (sectionId) {
      case 'aa':
        return AASection(initialData: _sectionData['aa'] ?? {}, onDataChanged: (data) => _onSectionDataChanged('aa', data));
      case 'dpr':
        return DPRSection(initialData: _sectionData['dpr'] ?? {}, onDataChanged: (data) => _onSectionDataChanged('dpr', data));
      case 'boq':
        return BOQSection(initialData: _sectionData['boq'] ?? {}, onDataChanged: (data) => _onSectionDataChanged('boq', data));
      case 'schedules':
        return SchedulesSection(initialData: _sectionData['schedules'] ?? {}, onDataChanged: (data) => _onSectionDataChanged('schedules', data));
      case 'drawings':
        return DrawingsSection(initialData: _sectionData['drawings'] ?? {}, onDataChanged: (data) => _onSectionDataChanged('drawings', data));
      case 'bid_documents':
        return BidDocumentsSection(initialData: _sectionData['bid_documents'] ?? {}, onDataChanged: (data) => _onSectionDataChanged('bid_documents', data));
      case 'env':
        return ENVSection(initialData: _sectionData['env'] ?? {}, onDataChanged: (data) => _onSectionDataChanged('env', data));
      case 'la':
        return LASection(initialData: _sectionData['la'] ?? {}, onDataChanged: (data) => _onSectionDataChanged('la', data));
      case 'utility_shifting':
        return UtilityShiftingSection(initialData: _sectionData['utility_shifting'] ?? {}, onDataChanged: (data) => _onSectionDataChanged('utility_shifting', data));
      case 'ts':
        return TSSection(initialData: _sectionData['ts'] ?? {}, onDataChanged: (data) => _onSectionDataChanged('ts', data));
      case 'nit':
        return NITSection(initialData: _sectionData['nit'] ?? {}, onDataChanged: (data) => _onSectionDataChanged('nit', data));
      case 'pre_bid':
        return PreBidSection(initialData: _sectionData['pre_bid'] ?? {}, onDataChanged: (data) => _onSectionDataChanged('pre_bid', data));
      case 'csd':
        return CSDSection(initialData: _sectionData['csd'] ?? {}, onDataChanged: (data) => _onSectionDataChanged('csd', data));
      case 'bid_submission':
        return BidSubmissionSection(initialData: _sectionData['bid_submission'] ?? {}, onDataChanged: (data) => _onSectionDataChanged('bid_submission', data));
      case 'technical_evaluation':
        return TechnicalEvaluationSection(initialData: _sectionData['technical_evaluation'] ?? {}, onDataChanged: (data) => _onSectionDataChanged('technical_evaluation', data));
      case 'financial_bid':
        return FinancialBidSection(initialData: _sectionData['financial_bid'] ?? {}, onDataChanged: (data) => _onSectionDataChanged('financial_bid', data));
      case 'bid_acceptance':
        return BidAcceptanceSection(initialData: _sectionData['bid_acceptance'] ?? {}, onDataChanged: (data) => _onSectionDataChanged('bid_acceptance', data));
      case 'loa':
        return LOASection(initialData: _sectionData['loa'] ?? {}, onDataChanged: (data) => _onSectionDataChanged('loa', data));
      case 'pbg':
        return PBGSection(initialData: _sectionData['pbg'] ?? {}, onDataChanged: (data) => _onSectionDataChanged('pbg', data));
      case 'work_order':
        return WorkOrderSection(initialData: _sectionData['work_order'] ?? {}, onDataChanged: (data) => _onSectionDataChanged('work_order', data));
      case 'agreement_amount':
        return AgreementAmountSection(initialData: _sectionData['agreement_amount'] ?? {}, onDataChanged: (data) => _onSectionDataChanged('agreement_amount', data));
      case 'appointed_date':
        return AppointedDateSection(initialData: _sectionData['appointed_date'] ?? {}, onDataChanged: (data) => _onSectionDataChanged('appointed_date', data));
      case 'tender_period':
        return TenderPeriodSection(initialData: _sectionData['tender_period'] ?? {}, onDataChanged: (data) => _onSectionDataChanged('tender_period', data));
      case 'ms1':
        return MilestoneSection(milestoneName: 'MS-I', initialData: _sectionData['ms1'] ?? {}, onDataChanged: (data) => _onSectionDataChanged('ms1', data));
      case 'ms2':
        return MilestoneSection(milestoneName: 'MS-II', initialData: _sectionData['ms2'] ?? {}, onDataChanged: (data) => _onSectionDataChanged('ms2', data));
      case 'ms3':
        return MilestoneSection(milestoneName: 'MS-III', initialData: _sectionData['ms3'] ?? {}, onDataChanged: (data) => _onSectionDataChanged('ms3', data));
      case 'ms4':
        return MilestoneSection(milestoneName: 'MS-IV', initialData: _sectionData['ms4'] ?? {}, onDataChanged: (data) => _onSectionDataChanged('ms4', data));
      case 'ms5':
        return MilestoneSection(milestoneName: 'MS-V', initialData: _sectionData['ms5'] ?? {}, onDataChanged: (data) => _onSectionDataChanged('ms5', data));
      case 'ld':
        return LDSection(initialData: _sectionData['ld'] ?? {}, onDataChanged: (data) => _onSectionDataChanged('ld', data));
      case 'eot':
        return EOTSection(initialData: _sectionData['eot'] ?? {}, onDataChanged: (data) => _onSectionDataChanged('eot', data));
      case 'cos':
        return COSSection(initialData: _sectionData['cos'] ?? {}, onDataChanged: (data) => _onSectionDataChanged('cos', data));
      case 'expenditure':
        return ExpenditureSection(initialData: _sectionData['expenditure'] ?? {}, onDataChanged: (data) => _onSectionDataChanged('expenditure', data));
      case 'audit_para':
        return AuditParaSection(initialData: _sectionData['audit_para'] ?? {}, onDataChanged: (data) => _onSectionDataChanged('audit_para', data));
      case 'laq':
        return LAQSection(initialData: _sectionData['laq'] ?? {}, onDataChanged: (data) => _onSectionDataChanged('laq', data));
      case 'technical_audit':
        return TechnicalAuditSection(initialData: _sectionData['technical_audit'] ?? {}, onDataChanged: (data) => _onSectionDataChanged('technical_audit', data));
      case 'rev_aa':
        return RevAASection(initialData: _sectionData['rev_aa'] ?? {}, onDataChanged: (data) => _onSectionDataChanged('rev_aa', data));
      case 'supplementary_agreement':
        return SupplementaryAgreementSection(initialData: _sectionData['supplementary_agreement'] ?? {}, onDataChanged: (data) => _onSectionDataChanged('supplementary_agreement', data));
      default:
        return const Padding(padding: EdgeInsets.all(24), child: Text('Section coming soon...'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search Bar and Edit Button
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: AppColors.border),
            ),
          ),
          child: Row(
            children: [
              const Text(
                'Work Entry',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 24),
              // Search Bar
              Expanded(
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() => _searchQuery = value);
                    },
                    decoration: const InputDecoration(
                      hintText: 'Search sections...',
                      hintStyle: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Edit Button
              ElevatedButton.icon(
                onPressed: () {
                  setState(() => _isEditMode = !_isEditMode);
                },
                icon: Icon(
                  _isEditMode ? Icons.check : Icons.edit,
                  size: 18,
                ),
                label: Text(_isEditMode ? 'Done' : 'Edit'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isEditMode
                      ? widget.categoryColor
                      : AppColors.textPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ),

        // Expandable Sections List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: _filteredSections.length,
            itemBuilder: (context, index) {
              final section = _filteredSections[index];
              final sectionId = section['id'];
              final isExpanded = _expandedSections[sectionId] ?? false;

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isExpanded
                          ? widget.categoryColor
                          : AppColors.border,
                      width: isExpanded ? 1.5 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Section Header
                      InkWell(
                        onTap: () {
                          setState(() {
                            _expandedSections[sectionId] = !isExpanded;
                          });
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            children: [
                              // Icon
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: (section['color'] as Color)
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  section['icon'],
                                  color: section['color'],
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Title and Subtitle
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      section['name'],
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      section['subtitle'],
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Expand/Collapse Icon
                              Icon(
                                isExpanded
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down,
                                color: AppColors.textSecondary,
                                size: 24,
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Section Content (Expanded)
                      if (isExpanded) ...[
                        const Divider(height: 1),
                        _buildSectionContent(sectionId),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
