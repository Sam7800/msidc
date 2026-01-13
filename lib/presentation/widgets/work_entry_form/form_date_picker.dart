import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../theme/app_colors.dart';

/// Reusable date picker widget for work entry forms
class FormDatePicker extends StatelessWidget {
  final String label;
  final DateTime? selectedDate;
  final Function(DateTime?) onDateSelected;
  final bool isRequired;
  final bool enabled;

  const FormDatePicker({
    super.key,
    required this.label,
    required this.selectedDate,
    required this.onDateSelected,
    this.isRequired = false,
    this.enabled = true,
  });

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      onDateSelected(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? () => _selectDate(context) : null,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label + (isRequired ? ' *' : ''),
          prefixIcon: const Icon(Icons.calendar_today, size: 20),
          suffixIcon: selectedDate != null && enabled
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () => onDateSelected(null),
                )
              : null,
          border: const OutlineInputBorder(),
          enabled: enabled,
        ),
        child: Text(
          selectedDate != null
              ? DateFormat('dd MMM yyyy').format(selectedDate!)
              : 'Select date',
          style: TextStyle(
            fontSize: 14,
            color: selectedDate != null
                ? (enabled ? AppColors.textPrimary : Colors.grey)
                : (enabled ? AppColors.textTertiary : Colors.grey.shade400),
          ),
        ),
      ),
    );
  }
}
