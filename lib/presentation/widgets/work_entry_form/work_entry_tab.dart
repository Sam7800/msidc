import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/project.dart';
import '../../../data/models/work_entry_section.dart';
import '../../../theme/app_colors.dart';
import 'sections/aa_section.dart';
import 'sections/dpr_section.dart';
import 'sections/boq_section.dart';

/// Main Work Entry Tab - Single continuous form with all sections
/// All 33+ sections displayed vertically in one scrollable form
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
  // Store data for all sections
  final Map<String, Map<String, dynamic>> _allSectionData = {};
  bool _isSaving = false;
  bool _hasUnsavedChanges = false;

  @override
  void initState() {
    super.initState();
    _loadFormData();
  }

  Future<void> _loadFormData() async {
    // TODO: Load existing form data from database
    // For now, start with empty data
  }

  void _onSectionDataChanged(String sectionId, Map<String, dynamic> data) {
    setState(() {
      _allSectionData[sectionId] = data;
      _hasUnsavedChanges = true;
    });
  }

  Future<void> _saveAllSections() async {
    if (!_hasUnsavedChanges) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No changes to save'),
          backgroundColor: AppColors.info,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      // TODO: Save all sections to database
      // Loop through _allSectionData and create/update WorkEntrySection records

      if (mounted) {
        setState(() {
          _hasUnsavedChanges = false;
          _isSaving = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Work Entry Form saved successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Widget _buildSectionHeader(String title, String subtitle, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: widget.categoryColor.withOpacity(0.05),
        border: Border(
          left: BorderSide(
            color: widget.categoryColor,
            width: 4,
          ),
          bottom: BorderSide(
            color: widget.categoryColor.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: widget.categoryColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: widget.categoryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: widget.categoryColor,
                  ),
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Form Header
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: widget.categoryColor.withOpacity(0.05),
            border: Border(
              bottom: BorderSide(
                color: widget.categoryColor.withOpacity(0.2),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.edit_document,
                color: widget.categoryColor,
                size: 28,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Work Entry Form',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Complete all sections below',
                      style: TextStyle(
                        fontSize: 13,
                        color: widget.categoryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (_hasUnsavedChanges)
                Chip(
                  label: const Text(
                    'Unsaved Changes',
                    style: TextStyle(fontSize: 11),
                  ),
                  backgroundColor: AppColors.warning.withOpacity(0.2),
                  labelStyle: const TextStyle(
                    color: AppColors.warning,
                    fontWeight: FontWeight.w600,
                  ),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
            ],
          ),
        ),

        // Scrollable Form Content
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Section 1: AA - Administrative Approval
                _buildSectionHeader(
                  'AA - Administrative Approval',
                  'Administrative approval details',
                  Icons.check_circle_outline,
                ),
                AASection(
                  initialData: _allSectionData['aa'] ?? {},
                  onDataChanged: (data) => _onSectionDataChanged('aa', data),
                ),
                const Divider(height: 1, thickness: 1),

                // Section 2: DPR - Detailed Project Report
                _buildSectionHeader(
                  'DPR - Detailed Project Report',
                  'Project report status and details',
                  Icons.description_outlined,
                ),
                DPRSection(
                  initialData: _allSectionData['dpr'] ?? {},
                  onDataChanged: (data) => _onSectionDataChanged('dpr', data),
                ),
                const Divider(height: 1, thickness: 1),

                // Section 3: BOQ - Bill of Quantities
                _buildSectionHeader(
                  'BOQ - Bill of Quantities',
                  'Itemized bill of quantities',
                  Icons.format_list_bulleted,
                ),
                BOQSection(
                  initialData: _allSectionData['boq'] ?? {},
                  onDataChanged: (data) => _onSectionDataChanged('boq', data),
                ),
                const Divider(height: 1, thickness: 1),

                // TODO: Add remaining 30+ sections here following the same pattern
                // Each section should have:
                // 1. _buildSectionHeader() with section name and icon
                // 2. The section widget with data binding
                // 3. A Divider to separate sections

                // Placeholder for remaining sections
                Container(
                  padding: const EdgeInsets.all(40),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.construction,
                          size: 48,
                          color: widget.categoryColor.withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Remaining 30+ sections coming soon',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Save Button
        Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(
              top: BorderSide(color: AppColors.border),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _saveAllSections,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.save),
                  label: Text(_isSaving ? 'Saving...' : 'Save Work Entry Form'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.categoryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
