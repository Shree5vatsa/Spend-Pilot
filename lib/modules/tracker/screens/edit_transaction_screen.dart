import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spend_pilot/core/constants/colors.dart';
import 'package:spend_pilot/core/widgets/buttons/primary_button.dart';
import 'package:spend_pilot/core/widgets/forms/transaction_form.dart';
import 'package:spend_pilot/core/widgets/inputs/type_toggle.dart';
import 'package:spend_pilot/data/providers/transaction_provider.dart';
import 'package:spend_pilot/shared/models/expense.dart';

class EditTransactionScreen extends ConsumerStatefulWidget {
  final Expense expense;

  const EditTransactionScreen({
    super.key,
    required this.expense,
  });

  @override
  ConsumerState<EditTransactionScreen> createState() =>
      _EditTransactionScreenState();
}

class _EditTransactionScreenState
    extends ConsumerState<EditTransactionScreen> {
  late TextEditingController _titleController;
  late TextEditingController _amountController;
  late TextEditingController _noteController;
  late String _selectedCategoryId;
  late DateTime _selectedDate;


  late bool _isExpense;

  @override
  void initState() {
    super.initState();
    final e = widget.expense;
    _titleController = TextEditingController(text: e.title);
    _amountController = TextEditingController(text: e.amount.toString());
    _noteController = TextEditingController(text: e.note ?? '');
    _selectedCategoryId = e.category;
    _selectedDate = e.date;
    _isExpense = !e.isIncome;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  /// Switching type resets category so income/expense IDs don't bleed across.
  void _onTypeChanged(bool isExpense) {
    setState(() {
      _isExpense = isExpense;
      _selectedCategoryId = '';
    });
  }

  Future<void> _saveChanges() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title cannot be empty')),
      );
      return;
    }

    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    final categoryId = _selectedCategoryId.isEmpty
        ? (_isExpense ? 'other' : 'other_income')
        : _selectedCategoryId;

    final updated = Expense(
      id: widget.expense.id,
      title: _titleController.text.trim(),
      amount: amount,
      date: _selectedDate,
      category: categoryId,
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
      isIncome: !_isExpense,
    );

    // Delete old then re-add (preserves sort order)
    await ref
        .read(transactionProvider.notifier)
        .deleteTransaction(widget.expense.id);
    await ref.read(transactionProvider.notifier).addTransaction(updated);

    if (mounted) Navigator.pop(context, updated);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Edit Transaction'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textSecondary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _saveChanges,
            child: const Text(
              'Save',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //  Shared animated type toggle
            TypeToggle(
              isExpense: _isExpense,
              onChanged: _onTypeChanged,
            ),
            const SizedBox(height: 24),

            //  Unified form (adapts to expense / income)
            TransactionForm(
              isExpense: _isExpense,
              titleController: _titleController,
              amountController: _amountController,
              noteController: _noteController,
              selectedCategoryId: _selectedCategoryId,
              selectedDate: _selectedDate,
              onCategoryChanged: (id) =>
                  setState(() => _selectedCategoryId = id),
              onDateChanged: (date) =>
                  setState(() => _selectedDate = date),
            ),
            const SizedBox(height: 24),

            // Save button
            PrimaryButton(
              onPressed: _saveChanges,
              label: _isExpense ? 'UPDATE EXPENSE' : 'UPDATE INCOME',
              backgroundColor:
                  _isExpense ? AppColors.error : AppColors.success,
            ),
          ],
        ),
      ),
    );
  }
}