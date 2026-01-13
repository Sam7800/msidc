import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

/// Common fields that appear in every work entry section
/// - Person Responsible
/// - Post Held
/// - Pending with whom
class SectionCommonFields extends StatefulWidget {
  final TextEditingController personResponsibleController;
  final TextEditingController postHeldController;
  final TextEditingController pendingWithController;
  final bool enabled;
  final VoidCallback? onChanged;

  const SectionCommonFields({
    super.key,
    required this.personResponsibleController,
    required this.postHeldController,
    required this.pendingWithController,
    this.enabled = true,
    this.onChanged,
  });

  @override
  State<SectionCommonFields> createState() => _SectionCommonFieldsState();
}

class _SectionCommonFieldsState extends State<SectionCommonFields> {
  bool _isExpanded = true;

  Widget _buildFieldRow(String label, TextEditingController controller, String hint) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 200,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            child: TextFormField(
              controller: controller,
              enabled: widget.enabled,
              onChanged: (_) => widget.onChanged?.call(),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        const Divider(height: 1, thickness: 1),
        const SizedBox(height: 16),

        // Collapsible Header
        InkWell(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                const Icon(
                  Icons.people_outline,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Person Responsible & Tracking',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const Spacer(),
                Icon(
                  _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),

        // Expanded Content
        if (_isExpanded) ...[
          const SizedBox(height: 16),
          _buildFieldRow(
            'Person Responsible',
            widget.personResponsibleController,
            'Enter person responsible',
          ),
          _buildFieldRow(
            'Post Held',
            widget.postHeldController,
            'Enter post/designation',
          ),
          _buildFieldRow(
            'Pending with whom',
            widget.pendingWithController,
            'Chief Engineer',
          ),
        ],
      ],
    );
  }
}
