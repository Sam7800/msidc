import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

/// Common fields that appear in every work entry section
/// - Person Responsible
/// - Pending With
/// - Held With
class SectionCommonFields extends StatelessWidget {
  final TextEditingController personResponsibleController;
  final TextEditingController pendingWithController;
  final TextEditingController heldWithController;

  const SectionCommonFields({
    super.key,
    required this.personResponsibleController,
    required this.pendingWithController,
    required this.heldWithController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 32, thickness: 1),

        // Section Title
        const Text(
          'Additional Information',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),

        // Person Responsible
        TextFormField(
          controller: personResponsibleController,
          decoration: const InputDecoration(
            labelText: 'Person Responsible',
            hintText: 'Enter person name',
            prefixIcon: Icon(Icons.person_outline, size: 20),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),

        // Pending With
        TextFormField(
          controller: pendingWithController,
          decoration: const InputDecoration(
            labelText: 'Pending With',
            hintText: 'Enter department/person',
            prefixIcon: Icon(Icons.pending_actions, size: 20),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),

        // Held With
        TextFormField(
          controller: heldWithController,
          decoration: const InputDecoration(
            labelText: 'Held With',
            hintText: 'Enter department/person',
            prefixIcon: Icon(Icons.bookmark_outline, size: 20),
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }
}
