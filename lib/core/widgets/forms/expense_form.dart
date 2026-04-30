import 'package:flutter/material.dart';
import 'package:spend_pilot/core/constants/colors.dart';
import 'package:spend_pilot/core/constants/categories.dart';
import 'package:spend_pilot/core/widgets/inputs/custom_text_field.dart';
import 'package:spend_pilot/core/widgets/inputs/category_selector.dart';
import 'package:spend_pilot/core/widgets/inputs/date_picker_field.dart';

class ExpenseForm extends StatefulWidget {
  final TextEditingController titleController;
  final TextEditingController amountController;
  final TextEditingController noteController;
  final String selectedCategoryId;
  final DateTime selectedDate;
  final ValueChanged<String> onCategoryChanged;
  final ValueChanged<DateTime> onDateChanged;

  const ExpenseForm({
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
  State<ExpenseForm> createState() => _ExpenseFormState();
}

class _ExpenseFormState extends State<ExpenseForm> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          controller: widget.titleController,
          label: 'Title',
          hint: 'e.g., Coffee, Grocery, Uber',
          focusColor: AppColors.error,
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
          focusColor: AppColors.error,
          validator: (value) {
            if (value == null || value.isEmpty) return 'Please enter an amount';
            if (double.tryParse(value) == null) return 'Please enter a valid number';
            if (double.parse(value) <= 0) return 'Amount must be greater than 0';
            return null;
          },
        ),
        const SizedBox(height: 16),
        CategorySelector(
          selectedCategoryId: widget.selectedCategoryId,
          onCategorySelected: widget.onCategoryChanged,
          focusColor: AppColors.error,
        ),
        const SizedBox(height: 16),
        DatePickerField(
          selectedDate: widget.selectedDate,
          onDateSelected: widget.onDateChanged,
          focusColor: AppColors.error,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: widget.noteController,
          label: 'Note (Optional)',
          hint: 'Add a note...',
          maxLines: 3,
          focusColor: AppColors.error,
        ),
      ],
    );
  }
}