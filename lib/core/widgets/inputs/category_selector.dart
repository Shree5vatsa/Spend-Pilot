import 'package:flutter/material.dart';
import 'package:spend_pilot/core/constants/colors.dart';
import 'package:spend_pilot/core/constants/categories.dart';


class CategorySelector extends StatelessWidget {
  final String selectedCategoryId;
  final ValueChanged<String> onCategorySelected;

  final bool isIncome;

  const CategorySelector({
    super.key,
    required this.selectedCategoryId,
    required this.onCategorySelected,
    this.isIncome = false,
  });

  @override
  Widget build(BuildContext context) {

    final List<dynamic> categories =
        isIncome ? IncomeCategory.all : ExpenseCategory.all;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Category',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1.1,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return _CategoryItem(

              key: ValueKey(category.id),
              icon: category.icon,
              name: category.name,
              color: category.color,
              isSelected: selectedCategoryId == category.id,
              onTap: () => onCategorySelected(category.id),
            );
          },
        ),
      ],
    );
  }
}


class _CategoryItem extends StatelessWidget {
  final String icon;
  final String name;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryItem({
    super.key,
    required this.icon,
    required this.name,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.2) : Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon scales up slightly when selected
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              tween: Tween<double>(begin: 1.0, end: isSelected ? 1.07 : 1.0),
              builder: (context, scale, child) =>
                  Transform.scale(scale: scale, child: child),
              child: Text(icon, style: const TextStyle(fontSize: 28)),
            ),
            const SizedBox(height: 4),
            // Label weight / colour transitions smoothly
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? color : AppColors.textSecondary,
              ),
              child: Text(name),
            ),
          ],
        ),
      ),
    );
  }
}