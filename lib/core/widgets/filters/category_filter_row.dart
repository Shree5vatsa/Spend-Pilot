import 'package:flutter/material.dart';
import 'package:spend_pilot/core/widgets/filters/filter_chip.dart';

class CategoryFilterRow extends StatelessWidget {
  final List<dynamic> categories;
  final String selectedCategoryId;
  final ValueChanged<String> onCategorySelected;

  const CategoryFilterRow({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        FilterChipWidget(
          label: 'All',
          isSelected: selectedCategoryId == 'all',
          onTap: () => onCategorySelected('all'),
        ),
        const SizedBox(width: 8),
        ...categories.map((category) {
          final isSelected = selectedCategoryId == category.id;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChipWidget(
              label: category.name,
              icon: category.icon,
              isSelected: isSelected,
              onTap: () {
                // Toggle: if already selected, unselect to 'all'
                if (isSelected) {
                  onCategorySelected('all');
                } else {
                  onCategorySelected(category.id);
                }
              },
              selectedColor: category.color,
            ),
          );
        }),
      ],
    );
  }
}