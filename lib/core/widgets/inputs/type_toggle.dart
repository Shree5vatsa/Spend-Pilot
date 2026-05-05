import 'package:flutter/material.dart';
import 'package:spend_pilot/core/constants/colors.dart';


class TypeToggle extends StatelessWidget {
  final bool isExpense;
  final ValueChanged<bool> onChanged;

  const TypeToggle({
    super.key,
    required this.isExpense,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          _TypeTab(
            label: 'EXPENSE',
            icon: Icons.trending_down,
            isActive: isExpense,
            activeColor: AppColors.error,
            onTap: () => onChanged(true),
          ),
          _TypeTab(
            label: 'INCOME',
            icon: Icons.trending_up,
            isActive: !isExpense,
            activeColor: AppColors.success,
            onTap: () => onChanged(false),
          ),
        ],
      ),
    );
  }
}

class _TypeTab extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final Color activeColor;
  final VoidCallback onTap;

  const _TypeTab({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? activeColor : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedScale(
                scale: isActive ? 1.1 : 1.0,
                duration: const Duration(milliseconds: 150),
                curve: Curves.easeOutCubic,
                child: Icon(
                  icon,
                  size: 18,
                  color: isActive ? Colors.white : activeColor,
                ),
              ),
              const SizedBox(width: 8),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 150),
                curve: Curves.easeOutCubic,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: isActive ? Colors.white : activeColor,
                ),
                child: Text(label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
