import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/project.dart';
import '../../../data/models/work_entry_section.dart';
import '../../../theme/app_colors.dart';
import '../../providers/work_entry_provider.dart';
import 'sections/aa_section.dart';
import 'sections/dpr_section.dart';
import 'sections/boq_section.dart';

/// Section Detail Screen - Shows the form for a specific section
/// Handles loading, editing, and saving section data
class SectionDetailScreen extends ConsumerStatefulWidget {
  final Project project;
  final String sectionId;
  final String sectionName;
  final Color categoryColor;

  const SectionDetailScreen({
    super.key,
    required this.project,
    required this.sectionId,
    required this.sectionName,
    required this.categoryColor,
  });

  @override
  ConsumerState<SectionDetailScreen> createState() =>
      _SectionDetailScreenState();
}

class _SectionDetailScreenState extends ConsumerState<SectionDetailScreen> {
  Map<String, dynamic> _sectionData = {};
  bool _isSaving = false;
  bool _hasUnsavedChanges = false;

  @override
  void initState() {
    super.initState();
    _loadSectionData();
  }

  Future<void> _loadSectionData() async {
    // TODO: Load existing section data from database
    // For now, start with empty data
    setState(() {
      _sectionData = {};
    });
  }

  void _onDataChanged(Map<String, dynamic> data) {
    setState(() {
      _sectionData = data;
      _hasUnsavedChanges = true;
    });
  }

  Future<void> _saveSection() async {
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
      // Create section object
      final section = WorkEntrySection(
        workEntryId: widget.project.id!, // TODO: Use work entry ID
        sectionName: widget.sectionId,
        sectionData: _sectionData['section_data'] ?? {},
        personResponsible: _sectionData['person_responsible'],
        pendingWith: _sectionData['pending_with'],
        heldWith: _sectionData['held_with'],
        tabImprint: _sectionData['tab_imprint'],
        status: 'in_progress',
      );

      // Save to database
      // TODO: Implement save via work entry provider
      // await ref.read(workEntryProvider.notifier).upsertSection(section);

      if (mounted) {
        setState(() {
          _hasUnsavedChanges = false;
          _isSaving = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.sectionName} saved successfully'),
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

  Widget _buildSectionForm() {
    switch (widget.sectionId) {
      case 'aa':
        return AASection(
          isEditMode: true,
          initialData: _sectionData,
          onDataChanged: _onDataChanged,
        );
      case 'dpr':
        return DPRSection(
          projectId: widget.project.id,
          isEditMode: true,
          initialData: _sectionData,
          onDataChanged: _onDataChanged,
        );
      case 'boq':
        return BOQSection(
          projectId: widget.project.id,
          isEditMode: true,
          initialData: _sectionData,
          onDataChanged: _onDataChanged,
        );
      default:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.construction,
                size: 64,
                color: widget.categoryColor.withOpacity(0.3),
              ),
              const SizedBox(height: 16),
              const Text(
                'Section Coming Soon',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_hasUnsavedChanges) {
          final shouldPop = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Unsaved Changes'),
              content: const Text(
                  'You have unsaved changes. Do you want to discard them?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Discard'),
                ),
              ],
            ),
          );
          return shouldPop ?? false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          scrolledUnderElevation: 0,
          iconTheme: const IconThemeData(
            color: AppColors.textPrimary,
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.sectionName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                widget.project.name,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: widget.categoryColor,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          actions: [
            if (_hasUnsavedChanges)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Chip(
                  label: const Text(
                    'Unsaved',
                    style: TextStyle(fontSize: 11),
                  ),
                  backgroundColor: AppColors.warning.withOpacity(0.2),
                  labelStyle: const TextStyle(
                    color: AppColors.warning,
                    fontWeight: FontWeight.w600,
                  ),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            const SizedBox(width: 8),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(3),
            child: Container(
              height: 3,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    widget.categoryColor.withOpacity(0.3),
                    widget.categoryColor
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
          ),
        ),
        body: Column(
          children: [
            // Form Content
            Expanded(
              child: _buildSectionForm(),
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
                      onPressed: _isSaving ? null : _saveSection,
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
                      label: Text(_isSaving ? 'Saving...' : 'Save Section'),
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
        ),
      ),
    );
  }
}
