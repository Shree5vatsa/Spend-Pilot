import 'package:flutter/material.dart';
import 'package:spend_pilot/core/constants/colors.dart';
import 'package:spend_pilot/core/widgets/filters/filter_chip.dart';

/// Horizontal row of category filter chips preceded by an "All" chip.
///
/// Used by both [DashboardScreen] and [TransactionHistoryScreen].
/// Wrap in [SingleChildScrollView] with horizontal axis at the call site.
///
/// [allChipColor] — colour of the "All" chip when selected (defaults to
/// [AppColors.primary]). Pass the active type colour so the chip matches the
/// current Income/Expense context.
class CategoryFilterRow extends StatelessWidget {
  final List<dynamic> categories;
  final String selectedCategoryId;
  final ValueChanged<String> onCategorySelected;


  final Color? allChipColor;

  const CategoryFilterRow({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategorySelected,
    this.allChipColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        FilterChipWidget(
          label: 'All',
          isSelected: selectedCategoryId == 'all',
          onTap: () => onCategorySelected('all'),
          selectedColor: allChipColor ?? AppColors.primary,
        ),
        const SizedBox(width: 8),
        ...categories.map((category) {
          final isSelected = selectedCategoryId == category.id;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChipWidget(
              label: category.name as String,
              icon: category.icon as String,
              isSelected: isSelected,
              onTap: () {

                onCategorySelected(isSelected ? 'all' : category.id as String);
              },
              selectedColor: category.color as Color,
            ),
          );
        }),
      ],
    );
  }
}