import 'package:flutter/material.dart';
import '../../../data/models/project.dart';
import '../../../theme/app_colors.dart';

/// Work Entry Tab - Placeholder for 33+ section work entry form
///
/// This will be replaced with the full work entry form implementation
/// containing all 33+ sections from the Work_entry_form_v2.docx
class WorkEntryTabPlaceholder extends StatelessWidget {
  final Project project;
  final Color categoryColor;

  const WorkEntryTabPlaceholder({
    super.key,
    required this.project,
    required this.categoryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(48.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: categoryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: categoryColor.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.edit_document,
                  size: 64,
                  color: categoryColor,
                ),
              ),

              const SizedBox(height: 32),

              // Title
              Text(
                'Work Entry Form',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: categoryColor,
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: 12),

              // Subtitle
              const Text(
                '33+ Section Work Entry System',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 32),

              // Description Card
              Container(
                constraints: const BoxConstraints(maxWidth: 600),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.border,
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 20,
                          color: categoryColor,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Coming Soon',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'The comprehensive work entry form will include:',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ..._buildFeatureList([
                      '33+ specialized sections (AA, DPR, BOQ, NIT, etc.)',
                      'Dynamic tables with add/remove row functionality',
                      'Conditional field rendering based on selections',
                      'Photo upload capability for documentation',
                      'Person Responsible, Pending With, Held With fields',
                      'Tab imprint for quick summary view',
                      'Manual save functionality',
                      'Status tracking per section',
                    ]),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Info Banner
              Container(
                constraints: const BoxConstraints(maxWidth: 600),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: categoryColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: categoryColor.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      size: 20,
                      color: categoryColor,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'This placeholder will be replaced with the full form implementation in the next phase',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildFeatureList(List<String> features) {
    return features.map((feature) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.check_circle,
              size: 16,
              color: categoryColor,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                feature,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textPrimary,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}
