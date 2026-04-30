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
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedValue,
          icon: Icon(Icons.arrow_drop_down, color: AppColors.primary),
          style: TextStyle(fontSize: 14, color: AppColors.primary),
          items: options.map((value) {
            return DropdownMenuItem(
              value: value,
              child: Text(optionLabels[value] ?? value),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) onChanged(value);
          },
        ),
      ),
    );
  }
}