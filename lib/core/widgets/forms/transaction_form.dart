import 'package:flutter/material.dart';
import 'package:spend_pilot/core/constants/colors.dart';
import 'package:spend_pilot/core/widgets/inputs/custom_text_field.dart';
import 'package:spend_pilot/core/widgets/inputs/category_selector.dart';
import 'package:spend_pilot/core/widgets/inputs/date_picker_field.dart';

class TransactionForm extends StatelessWidget {
  final bool isExpense;
  final TextEditingController titleController;
  final TextEditingController amountController;
  final TextEditingController noteController;
  final String selectedCategoryId;
  final DateTime selectedDate;
  final ValueChanged<String> onCategoryChanged;
  final ValueChanged<DateTime> onDateChanged;

  const TransactionForm({
    super.key,
    required this.isExpense,
    required this.titleController,
    required this.amountController,
    required this.noteController,
    required this.selectedCategoryId,
    required this.selectedDate,
    required this.onCategoryChanged,
    required this.onDateChanged,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = isExpense ? AppColors.error : AppColors.success;
    final titleHint = isExpense
        ? 'e.g., Coffee, Grocery, Uber'
        : 'e.g., Salary, Freelance, Gift';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Title ────────────────────────────────────────────────
        CustomTextField(
          controller: titleController,
          label: 'Title',
          hint: titleHint,
          focusColor: accentColor,
          validator: (value) =>
              (value == null || value.trim().isEmpty)
                  ? 'Please enter a title'
                  : null,
        ),
        const SizedBox(height: 16),

        // ── Amount ───────────────────────────────────────────────
        CustomTextField(
          controller: amountController,
          label: 'Amount',
          hint: '0.00',
          prefixText: '\$ ',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          focusColor: accentColor,
          validator: (value) {
            if (value == null || value.isEmpty) return 'Please enter an amount';
            if (double.tryParse(value) == null) return 'Please enter a valid number';
            if (double.parse(value) <= 0) return 'Amount must be greater than 0';
            return null;
          },
        ),
        const SizedBox(height: 16),

        // ── Category grid (shared, animated) ─────────────────────
        CategorySelector(
          selectedCategoryId: selectedCategoryId,
          onCategorySelected: onCategoryChanged,
          isIncome: !isExpense,
        ),
        const SizedBox(height: 16),

        // ── Date picker ──────────────────────────────────────────
        DatePickerField(
          selectedDate: selectedDate,
          onDateSelected: onDateChanged,
          focusColor: accentColor,
        ),
        const SizedBox(height: 16),

        // ── Note (optional) ──────────────────────────────────────
        CustomTextField(
          controller: noteController,
          label: 'Note (Optional)',
          hint: 'Add a note...',
          maxLines: 3,
          focusColor: accentColor,
        ),
      ],
    );
  }
}
