import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spend_pilot/core/constants/colors.dart';
import 'package:spend_pilot/core/constants/categories.dart';
import 'package:spend_pilot/core/utils/date_formatter.dart';
import 'package:spend_pilot/data/providers/transaction_provider.dart';
import 'package:spend_pilot/modules/tracker/screens/edit_transaction_screen.dart';
import 'package:spend_pilot/shared/models/expense.dart';

class TransactionDetailScreen extends ConsumerStatefulWidget {
  final Expense expense;

  const TransactionDetailScreen({
    super.key,
    required this.expense,
  });

  @override
  ConsumerState<TransactionDetailScreen> createState() => _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends ConsumerState<TransactionDetailScreen> {
  late Expense _expense;

  @override
  void initState() {
    super.initState();
    _expense = widget.expense;
  }

  String _getCategoryName() {
    if (_expense.isIncome) {
      return IncomeCategory.fromId(_expense.category)?.name ?? 'Other';
    } else {
      return ExpenseCategory.fromId(_expense.category)?.name ?? 'Other';
    }
  }

  String _getCategoryIcon() {
    if (_expense.isIncome) {
      return IncomeCategory.fromId(_expense.category)?.icon ?? '📌';
    } else {
      return ExpenseCategory.fromId(_expense.category)?.icon ?? '📌';
    }
  }

  Color _getCategoryColor() {
    if (_expense.isIncome) {
      return IncomeCategory.fromId(_expense.category)?.color ?? AppColors.success;
    } else {
      return ExpenseCategory.fromId(_expense.category)?.color ?? AppColors.error;
    }
  }

  Future<void> _deleteAndPop() async {
    await ref.read(transactionProvider.notifier).deleteTransaction(_expense.id);
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaction deleted')),
      );
    }
  }

  Future<void> _duplicateTransaction() async {
    final newExpense = Expense(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: '${_expense.title} (Copy)',
      amount: _expense.amount,
      date: DateTime.now(),
      category: _expense.category,
      note: _expense.note,
      isIncome: _expense.isIncome,
    );
    await ref.read(transactionProvider.notifier).addTransaction(newExpense);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaction duplicated')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isNegative = !_expense.isIncome;
    final categoryName = _getCategoryName();
    final categoryIcon = _getCategoryIcon();
    final categoryColor = _getCategoryColor();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Transaction Details'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy, color: AppColors.primary),
            onPressed: _duplicateTransaction,
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: AppColors.primary),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditTransactionScreen(expense: _expense),
                ),
              ).then((updated) {
                if (updated != null && mounted) {
                  setState(() {
                    _expense = updated;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Transaction updated')),
                  );
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
            onPressed: () => _showDeleteDialog(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(32),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: categoryColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        categoryIcon,
                        style: const TextStyle(fontSize: 36),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _expense.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: categoryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _expense.isIncome ? Icons.trending_up : Icons.trending_down,
                          size: 14,
                          color: categoryColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _expense.isIncome ? 'Income' : 'Expense',
                          style: TextStyle(
                            fontSize: 12,
                            color: categoryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    '${isNegative ? '-' : '+'} \$${_expense.amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 44,
                      fontWeight: FontWeight.bold,
                      color: isNegative ? AppColors.error : AppColors.success,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Details Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _buildInfoCard(
                    icon: Icons.category,
                    title: 'Category',
                    value: categoryName,
                  ),
                  const SizedBox(height: 12),
                  _buildInfoCard(
                    icon: Icons.calendar_today,
                    title: 'Date',
                    value: DateFormatter.formatDate(_expense.date),
                  ),
                  const SizedBox(height: 12),
                  if (_expense.note != null && _expense.note!.isNotEmpty)
                    _buildInfoCard(
                      icon: Icons.note,
                      title: 'Note',
                      value: _expense.note!,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 22, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Transaction'),
        content: Text('Delete "${_expense.title}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteAndPop();
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}