import 'package:flutter/material.dart';
import 'package:spend_pilot/core/constants/colors.dart';

class FilterChipWidget extends StatelessWidget {
  final String label;
  final String? icon;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? selectedColor;

  const FilterChipWidget({
    super.key,
    required this.label,
    this.icon,
    required this.isSelected,
    required this.onTap,
    this.selectedColor,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = selectedColor ?? AppColors.primary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? chipColor.withValues(alpha: 0.15) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: chipColor.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Text(icon!, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? chipColor : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}