import 'package:flutter/material.dart';
import 'package:spend_pilot/core/constants/colors.dart';
import 'package:spend_pilot/core/widgets/buttons/primary_button.dart';
import 'package:spend_pilot/core/widgets/forms/expense_form.dart';
import 'package:spend_pilot/core/widgets/forms/income_form.dart';
import 'package:spend_pilot/shared/models/expense.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  bool _isExpense = true;

  String _selectedExpenseCategoryId = 'food';
  String _selectedIncomeCategoryId = 'salary';
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _saveTransaction() {
    if (_formKey.currentState!.validate()) {
      final newExpense = Expense(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        amount: double.parse(_amountController.text),
        date: _selectedDate,
        category: _isExpense ? _selectedExpenseCategoryId : _selectedIncomeCategoryId,
        note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
        isIncome: !_isExpense,
      );

      Navigator.pop(context, newExpense);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Add Transaction'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Cancel',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
        actions: [
          TextButton(
            onPressed: _saveTransaction,
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
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTypeToggle(),
              const SizedBox(height: 24),
              _isExpense
                  ? ExpenseForm(
                titleController: _titleController,
                amountController: _amountController,
                noteController: _noteController,
                selectedCategoryId: _selectedExpenseCategoryId,
                selectedDate: _selectedDate,
                onCategoryChanged: (id) => setState(() => _selectedExpenseCategoryId = id),
                onDateChanged: (date) => setState(() => _selectedDate = date),
              )
                  : IncomeForm(
                titleController: _titleController,
                amountController: _amountController,
                noteController: _noteController,
                selectedCategoryId: _selectedIncomeCategoryId,
                selectedDate: _selectedDate,
                onCategoryChanged: (id) => setState(() => _selectedIncomeCategoryId = id),
                onDateChanged: (date) => setState(() => _selectedDate = date),
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                onPressed: _saveTransaction,
                label: _isExpense ? 'SAVE EXPENSE' : 'SAVE INCOME',
                backgroundColor: _isExpense ? AppColors.error : AppColors.success,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeToggle() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isExpense = true),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _isExpense ? AppColors.error : Colors.transparent,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.trending_down, size: 20, color: _isExpense ? Colors.white : AppColors.error),
                    const SizedBox(width: 8),
                    Text(
                      'EXPENSE',
                      style: TextStyle(
                        color: _isExpense ? Colors.white : AppColors.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isExpense = false),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !_isExpense ? AppColors.success : Colors.transparent,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.trending_up, size: 20, color: !_isExpense ? Colors.white : AppColors.success),
                    const SizedBox(width: 8),
                    Text(
                      'INCOME',
                      style: TextStyle(
                        color: !_isExpense ? Colors.white : AppColors.success,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}