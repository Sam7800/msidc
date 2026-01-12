import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../../theme/app_colors.dart';
import '../providers/repository_providers.dart';

/// Critical Activities Screen
/// Shows all critical/alert activities across projects
/// Supports filtering by category/project and view switching (list/table)
class CriticalActivitiesScreen extends ConsumerStatefulWidget {
  final int? categoryId;
  final int? projectId;

  const CriticalActivitiesScreen({
    super.key,
    this.categoryId,
    this.projectId,
  });

  @override
  ConsumerState<CriticalActivitiesScreen> createState() =>
      _CriticalActivitiesScreenState();
}

class _CriticalActivitiesScreenState
    extends ConsumerState<CriticalActivitiesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isListView = true; // true = list view, false = table view
  List<Map<String, dynamic>> _criticalActivities = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCriticalActivities();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCriticalActivities() async {
    setState(() => _isLoading = true);

    final repo = ref.read(criticalSubsectionsRepositoryProvider);

    List<Map<String, dynamic>> activities;
    if (widget.projectId != null) {
      // Single project
      activities = await repo.getCriticalSubsectionsByProjectId(widget.projectId!);
    } else if (widget.categoryId != null) {
      // Category projects
      activities = await repo.getCriticalSubsectionsByCategory(widget.categoryId!);
    } else {
      // All projects
      activities = await repo.getAllCriticalSubsections();
    }

    if (mounted) {
      setState(() {
        _criticalActivities = activities;
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get _filteredActivities {
    if (_searchQuery.isEmpty) return _criticalActivities;

    return _criticalActivities.where((activity) {
      final projectName = (activity['project_name'] ?? '').toString().toLowerCase();
      final categoryName = (activity['category_name'] ?? '').toString().toLowerCase();
      final sectionName = (activity['section_name'] ?? '').toString().toLowerCase();
      final optionName = (activity['option_name'] ?? '').toString().toLowerCase();
      final personResponsible = (activity['person_responsible'] ?? '').toString().toLowerCase();
      final pendingWith = (activity['pending_with'] ?? '').toString().toLowerCase();

      final query = _searchQuery.toLowerCase();
      return projectName.contains(query) ||
          categoryName.contains(query) ||
          sectionName.contains(query) ||
          optionName.contains(query) ||
          personResponsible.contains(query) ||
          pendingWith.contains(query);
    }).toList();
  }

  Map<String, List<Map<String, dynamic>>> get _groupedActivities {
    final grouped = <String, List<Map<String, dynamic>>>{};
    for (final activity in _filteredActivities) {
      final projectName = activity['project_name'] ?? 'Unknown Project';
      if (!grouped.containsKey(projectName)) {
        grouped[projectName] = [];
      }
      grouped[projectName]!.add(activity);
    }
    return grouped;
  }

  Future<void> _toggleCritical(Map<String, dynamic> activity) async {
    final repo = ref.read(criticalSubsectionsRepositoryProvider);
    await repo.removeCritical(
      activity['project_id'] as int,
      activity['section_name'] as String,
      activity['option_name'] as String,
    );
    await _loadCriticalActivities();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Removed from Critical Activities'),
          duration: Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  String _getTitle() {
    if (widget.projectId != null) {
      return 'Critical Activities - Project';
    } else if (widget.categoryId != null) {
      return 'Critical Activities - Category';
    } else {
      return 'Critical Activities - All Projects';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_getTitle()),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: AppColors.border,
          ),
        ),
        actions: [
          // View Toggle
          IconButton(
            icon: Icon(_isListView ? Icons.table_chart : Icons.view_list),
            tooltip: _isListView ? 'Table View' : 'List View',
            onPressed: () {
              setState(() => _isListView = !_isListView);
            },
          ),
          // Export to PDF
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Export PDF',
            onPressed: _exportPDF,
          ),
          // Share via Email
          IconButton(
            icon: const Icon(Icons.email),
            tooltip: 'Share via Email',
            onPressed: _shareEmail,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
              decoration: InputDecoration(
                hintText: 'Search by project, section, person...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),

          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredActivities.isEmpty
                    ? _buildEmptyState()
                    : _isListView
                        ? _buildListView()
                        : _buildTableView(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty
                ? 'No Critical Activities'
                : 'No results found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isEmpty
                ? 'Mark sections as critical using bell icons'
                : 'Try a different search term',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListView() {
    final grouped = _groupedActivities;
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: grouped.length,
      itemBuilder: (context, index) {
        final projectName = grouped.keys.elementAt(index);
        final activities = grouped[projectName]!;
        final categoryName = activities.first['category_name'] ?? '';

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppColors.border),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              title: Text(
                projectName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              subtitle: Text(
                '$categoryName • ${activities.length} critical ${activities.length == 1 ? 'activity' : 'activities'}',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              children: activities.map((activity) {
                return _buildActivityCard(activity);
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActivityCard(Map<String, dynamic> activity) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bell Icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.notifications_active,
              color: Colors.deepOrange,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${activity['section_name']}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  activity['option_name'] ?? '',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (activity['person_responsible'] != null &&
                    activity['person_responsible'].toString().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.person, size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        activity['person_responsible'],
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
                if (activity['pending_with'] != null &&
                    activity['pending_with'].toString().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.hourglass_empty, size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        'Pending: ${activity['pending_with']}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Remove Button
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            color: Colors.grey[600],
            tooltip: 'Remove from critical',
            onPressed: () => _toggleCritical(activity),
          ),
        ],
      ),
    );
  }

  Widget _buildTableView() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: DataTable(
            headingRowColor: MaterialStateProperty.all(Colors.grey[100]),
            border: TableBorder.all(color: AppColors.border, width: 0.5),
            columns: const [
              DataColumn(label: Text('Project', style: TextStyle(fontWeight: FontWeight.w600))),
              DataColumn(label: Text('Category', style: TextStyle(fontWeight: FontWeight.w600))),
              DataColumn(label: Text('Section', style: TextStyle(fontWeight: FontWeight.w600))),
              DataColumn(label: Text('Status/Option', style: TextStyle(fontWeight: FontWeight.w600))),
              DataColumn(label: Text('Person Responsible', style: TextStyle(fontWeight: FontWeight.w600))),
              DataColumn(label: Text('Pending With', style: TextStyle(fontWeight: FontWeight.w600))),
              DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.w600))),
            ],
            rows: _filteredActivities.map((activity) {
              return DataRow(
                cells: [
                  DataCell(Text(activity['project_name'] ?? '')),
                  DataCell(Text(activity['category_name'] ?? '')),
                  DataCell(Text(activity['section_name'] ?? '')),
                  DataCell(Text(activity['option_name'] ?? '')),
                  DataCell(Text(activity['person_responsible'] ?? '-')),
                  DataCell(Text(activity['pending_with'] ?? '-')),
                  DataCell(
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 18),
                      color: Colors.red[400],
                      tooltip: 'Remove',
                      onPressed: () => _toggleCritical(activity),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Future<void> _exportPDF() async {
    try {
      final pdf = pw.Document();
      final dateFormat = DateFormat('dd-MM-yyyy');
      final now = DateTime.now();

      // Add page with landscape orientation
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4.landscape,
          margin: const pw.EdgeInsets.all(32),
          build: (context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Critical Activities Report',
                          style: pw.TextStyle(
                            fontSize: 20,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          _getTitle(),
                          style: const pw.TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          'Generated: ${dateFormat.format(now)}',
                          style: const pw.TextStyle(fontSize: 10),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'Total: ${_filteredActivities.length} activities',
                          style: const pw.TextStyle(fontSize: 10),
                        ),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 24),

                // Table
                if (_filteredActivities.isEmpty)
                  pw.Center(
                    child: pw.Text('No critical activities found'),
                  )
                else
                  pw.Table(
                    border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
                    columnWidths: {
                      0: const pw.FlexColumnWidth(2.5), // Project
                      1: const pw.FlexColumnWidth(1.5), // Category
                      2: const pw.FlexColumnWidth(1.5), // Section
                      3: const pw.FlexColumnWidth(2), // Status/Option
                      4: const pw.FlexColumnWidth(1.5), // Person Responsible
                      5: const pw.FlexColumnWidth(1.5), // Pending With
                    },
                    children: [
                      // Header Row
                      pw.TableRow(
                        decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                        children: [
                          _buildPdfCell('Project', isHeader: true),
                          _buildPdfCell('Category', isHeader: true),
                          _buildPdfCell('Section', isHeader: true),
                          _buildPdfCell('Status/Option', isHeader: true),
                          _buildPdfCell('Person Responsible', isHeader: true),
                          _buildPdfCell('Pending With', isHeader: true),
                        ],
                      ),
                      // Data Rows
                      ..._filteredActivities.map((activity) {
                        return pw.TableRow(
                          children: [
                            _buildPdfCell(activity['project_name'] ?? ''),
                            _buildPdfCell(activity['category_name'] ?? ''),
                            _buildPdfCell(activity['section_name'] ?? ''),
                            _buildPdfCell(activity['option_name'] ?? ''),
                            _buildPdfCell(activity['person_responsible'] ?? '-'),
                            _buildPdfCell(activity['pending_with'] ?? '-'),
                          ],
                        );
                      }).toList(),
                    ],
                  ),
              ],
            );
          },
        ),
      );

      // Show print dialog
      await Printing.layoutPdf(
        onLayout: (format) async => pdf.save(),
        name: 'Critical_Activities_${dateFormat.format(now)}.pdf',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating PDF: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  pw.Widget _buildPdfCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 9 : 8,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  Future<void> _shareEmail() async {
    try {
      final dateFormat = DateFormat('dd-MM-yyyy');
      final now = DateTime.now();

      // Build email body
      final buffer = StringBuffer();
      buffer.writeln('Critical Activities Report');
      buffer.writeln('Generated: ${dateFormat.format(now)}');
      buffer.writeln(_getTitle());
      buffer.writeln('Total Activities: ${_filteredActivities.length}');
      buffer.writeln('\n${'=' * 80}\n');

      if (_filteredActivities.isEmpty) {
        buffer.writeln('No critical activities found.');
      } else {
        // Group by project
        final grouped = _groupedActivities;
        for (final projectName in grouped.keys) {
          final activities = grouped[projectName]!;
          final categoryName = activities.first['category_name'] ?? '';

          buffer.writeln('\nProject: $projectName');
          buffer.writeln('Category: $categoryName');
          buffer.writeln('Critical Activities: ${activities.length}');
          buffer.writeln('-' * 80);

          for (var i = 0; i < activities.length; i++) {
            final activity = activities[i];
            buffer.writeln('${i + 1}. ${activity['section_name']} - ${activity['option_name']}');

            if (activity['person_responsible'] != null &&
                activity['person_responsible'].toString().isNotEmpty) {
              buffer.writeln('   Person Responsible: ${activity['person_responsible']}');
            }

            if (activity['pending_with'] != null &&
                activity['pending_with'].toString().isNotEmpty) {
              buffer.writeln('   Pending With: ${activity['pending_with']}');
            }

            buffer.writeln();
          }
        }
      }

      // Create email URI
      final subject = Uri.encodeComponent('Critical Activities Report - ${dateFormat.format(now)}');
      final body = Uri.encodeComponent(buffer.toString());
      final emailUri = Uri.parse('mailto:?subject=$subject&body=$body');

      // Launch email client
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        throw 'Could not launch email client';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sharing via email: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}
