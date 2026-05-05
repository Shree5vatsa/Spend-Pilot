import 'package:flutter/material.dart';
import 'package:spend_pilot/core/constants/colors.dart';
import 'package:spend_pilot/core/widgets/buttons/primary_button.dart';
import 'package:spend_pilot/core/widgets/forms/transaction_form.dart';
import 'package:spend_pilot/core/widgets/inputs/type_toggle.dart';
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
  String _selectedCategoryId = '';
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  // Switching type resets category so income/expense IDs don't bleed across.
  void _onTypeChanged(bool isExpense) {
    setState(() {
      _isExpense = isExpense;
      _selectedCategoryId = '';
    });
  }

  void _saveTransaction() {
    if (_formKey.currentState!.validate()) {
      final categoryId = _selectedCategoryId.isEmpty
          ? (_isExpense ? 'other' : 'other_income')
          : _selectedCategoryId;

      final newExpense = Expense(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        amount: double.parse(_amountController.text),
        date: _selectedDate,
        category: categoryId,
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
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
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
          color: AppColors.textSecondary,
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

              TypeToggle(
                isExpense: _isExpense,
                onChanged: _onTypeChanged,
              ),
              const SizedBox(height: 24),

              // ── Unified form (adapts to expense / income)
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

              PrimaryButton(
                onPressed: _saveTransaction,
                label: _isExpense ? 'SAVE EXPENSE' : 'SAVE INCOME',
                backgroundColor:
                    _isExpense ? AppColors.error : AppColors.success,
              ),
            ],
          ),
        ),
      ),
    );
  }
}