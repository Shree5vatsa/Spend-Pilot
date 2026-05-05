import 'package:flutter/material.dart';
import 'package:spend_pilot/core/constants/colors.dart';

class SortDropdown extends StatelessWidget {
  final String selectedValue;
  final ValueChanged<String> onChanged;
  final List<String> options;
  final Map<String, String> optionLabels;

  const SortDropdown({
    super.key,
    required this.selectedValue,
    required this.onChanged,
    required this.options,
    required this.optionLabels,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: DropdownButton<String>(
        value: selectedValue,
        underline: const SizedBox(),
        icon: const Icon(
          Icons.swap_vert,
          size: 18,
          color: AppColors.textSecondary,
        ),
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
        items: options.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Row(
              children: [
                Icon(
                  _getIconForSortOption(value),
                  size: 14,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(optionLabels[value] ?? value),
              ],
            ),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            onChanged(value);
          }
        },
        // This makes the dropdown menu have rounded corners
        elevation: 4,
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }

  IconData _getIconForSortOption(String value) {
    switch (value) {
      case 'newest':
        return Icons.access_time;
      case 'oldest':
        return Icons.history;
      case 'amount_high':
        return Icons.trending_down;
      case 'amount_low':
        return Icons.trending_up;
      default:
        return Icons.sort;
    }
  }
}