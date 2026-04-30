import 'package:flutter/material.dart';
import 'package:spend_pilot/core/constants/colors.dart';
import 'package:spend_pilot/core/constants/categories.dart';
import 'package:spend_pilot/core/widgets/inputs/custom_text_field.dart';
import 'package:spend_pilot/core/widgets/inputs/date_picker_field.dart';

class IncomeForm extends StatefulWidget {
  final TextEditingController titleController;
  final TextEditingController amountController;
  final TextEditingController noteController;
  final String selectedCategoryId;
  final DateTime selectedDate;
  final ValueChanged<String> onCategoryChanged;
  final ValueChanged<DateTime> onDateChanged;

  const IncomeForm({
    super.key,
    required this.titleController,
    required this.amountController,
    required this.noteController,
    required this.selectedCategoryId,
    required this.selectedDate,
    required this.onCategoryChanged,
    required this.onDateChanged,
  });

  @override
  State<IncomeForm> createState() => _IncomeFormState();
}

class _IncomeFormState extends State<IncomeForm> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          controller: widget.titleController,
          label: 'Title',
          hint: 'e.g., Salary, Freelance, Gift',
          focusColor: AppColors.success,
          validator: (value) =>
          (value == null || value.trim().isEmpty)
              ? 'Please enter a title'
              : null,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: widget.amountController,
          label: 'Amount',
          hint: '0.00',
          prefixText: '\$ ',
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          focusColor: AppColors.success,
          validator: (value) {
            if (value == null || value.isEmpty) return 'Please enter an amount';
            if (double.tryParse(value) == null) return 'Please enter a valid number';
            if (double.parse(value) <= 0) return 'Amount must be greater than 0';
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildIncomeCategorySelector(),
        const SizedBox(height: 16),
        DatePickerField(
          selectedDate: widget.selectedDate,
          onDateSelected: widget.onDateChanged,
          focusColor: AppColors.success,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: widget.noteController,
          label: 'Note (Optional)',
          hint: 'Add a note...',
          maxLines: 3,
          focusColor: AppColors.success,
        ),
      ],
    );
  }

  Widget _buildIncomeCategorySelector() {
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
          itemCount: IncomeCategory.all.length,
          itemBuilder: (context, index) {
            final category = IncomeCategory.all[index];
            final isSelected = widget.selectedCategoryId == category.id;
            return GestureDetector(
              onTap: () => widget.onCategoryChanged(category.id),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? category.color.withValues(alpha: 0.2) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? category.color : AppColors.border,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(category.icon, style: const TextStyle(fontSize: 28)),
                    const SizedBox(height: 4),
                    Text(
                      category.name,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? category.color : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}