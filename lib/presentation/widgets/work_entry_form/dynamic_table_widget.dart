import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

/// Dynamic table widget with add/remove row functionality
/// Used in BOQ, NIT, and other sections
class DynamicTableWidget extends StatefulWidget {
  final List<String> columnHeaders;
  final List<Map<String, String>> rows;
  final Function(List<Map<String, String>>) onRowsChanged;
  final String addButtonLabel;

  const DynamicTableWidget({
    super.key,
    required this.columnHeaders,
    required this.rows,
    required this.onRowsChanged,
    this.addButtonLabel = 'Add Row',
  });

  @override
  State<DynamicTableWidget> createState() => _DynamicTableWidgetState();
}

class _DynamicTableWidgetState extends State<DynamicTableWidget> {
  void _addRow() {
    final newRow = <String, String>{};
    for (final header in widget.columnHeaders) {
      newRow[header] = '';
    }
    setState(() {
      widget.rows.add(newRow);
      widget.onRowsChanged(widget.rows);
    });
  }

  void _removeRow(int index) {
    setState(() {
      widget.rows.removeAt(index);
      widget.onRowsChanged(widget.rows);
    });
  }

  void _updateCell(int rowIndex, String column, String value) {
    setState(() {
      widget.rows[rowIndex][column] = value;
      widget.onRowsChanged(widget.rows);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Table
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              // Header Row
              Container(
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
                child: Row(
                  children: [
                    // Action column header
                    Container(
                      width: 60,
                      padding: const EdgeInsets.all(12),
                      child: const Text(
                        'Action',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    // Data column headers
                    ...widget.columnHeaders.map((header) => Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: const BoxDecoration(
                              border: Border(
                                left: BorderSide(color: AppColors.border),
                              ),
                            ),
                            child: Text(
                              header,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        )),
                  ],
                ),
              ),

              // Data Rows
              ...widget.rows.asMap().entries.map((entry) {
                final index = entry.key;
                final row = entry.value;
                return Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: AppColors.border),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Delete button
                      SizedBox(
                        width: 60,
                        child: IconButton(
                          icon: const Icon(Icons.delete_outline, size: 18),
                          color: AppColors.error,
                          onPressed: () => _removeRow(index),
                          tooltip: 'Remove row',
                        ),
                      ),
                      // Data columns
                      ...widget.columnHeaders.map((header) => Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: const BoxDecoration(
                                border: Border(
                                  left: BorderSide(color: AppColors.border),
                                ),
                              ),
                              child: TextFormField(
                                initialValue: row[header] ?? '',
                                onChanged: (value) =>
                                    _updateCell(index, header, value),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 12,
                                  ),
                                  isDense: true,
                                ),
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                          )),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Add Row Button
        OutlinedButton.icon(
          onPressed: _addRow,
          icon: const Icon(Icons.add, size: 18),
          label: Text(widget.addButtonLabel),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.border),
          ),
        ),
      ],
    );
  }
}
