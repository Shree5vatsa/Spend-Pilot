import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spend_pilot/core/constants/colors.dart';
import 'package:spend_pilot/core/widgets/modals/confirmation_dialog.dart';
import 'package:spend_pilot/data/providers/transaction_provider.dart';
import 'package:spend_pilot/modules/tracker/widgets/transaction_card.dart';
import 'package:spend_pilot/shared/models/expense.dart';
import 'add_transaction_screen.dart';
import 'transaction_history_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  String _selectedPeriod = 'Month';

  List<Expense> _getFilteredTransactions(List<Expense> allTransactions) {
    final now = DateTime.now();
    DateTime startDate;

    switch (_selectedPeriod) {
      case 'Week':
        startDate = now.subtract(Duration(days: now.weekday - 1));
        break;
      case 'Month':
        startDate = DateTime(now.year, now.month, 1);
        break;
      case 'Year':
        startDate = DateTime(now.year, 1, 1);
        break;
      default:
        startDate = DateTime(now.year, now.month, 1);
    }

    return allTransactions.where((e) =>
    e.date.isAfter(startDate) &&
        e.date.isBefore(now.add(const Duration(days: 1)))
    ).toList();
  }

  double _getTotalIncome(List<Expense> transactions) {
    return transactions
        .where((e) => e.isIncome)
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  double _getTotalExpense(List<Expense> transactions) {
    return transactions
        .where((e) => !e.isIncome)
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  double _getBalance(List<Expense> transactions) {
    return _getTotalIncome(transactions) - _getTotalExpense(transactions);
  }

  Future<void> _addTransaction(Expense expense) async {
    await ref.read(transactionProvider.notifier).addTransaction(expense);
  }

  Future<void> _deleteTransaction(String id) async {
    await ref.read(transactionProvider.notifier).deleteTransaction(id);
  }

  Future<void> _showDeleteDialog(Expense expense) async {
    final confirmed = await ConfirmationDialog.show(
      context: context,
      title: 'Delete Transaction',
      message: 'Delete "${expense.title}"? This cannot be undone.',
      confirmText: 'Delete',
      confirmColor: AppColors.error,
    );

    if (confirmed == true) {
      await _deleteTransaction(expense.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final allTransactions = ref.watch(transactionProvider);
    final filteredTransactions = _getFilteredTransactions(allTransactions);
    final totalIncome = _getTotalIncome(filteredTransactions);
    final totalExpense = _getTotalExpense(filteredTransactions);
    final balance = _getBalance(filteredTransactions);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Spend Pilot', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(icon: const Icon(Icons.person_outline), onPressed: () {}),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => setState(() {}),
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDateSelector(),
              const SizedBox(height: 16),
              _buildStatsSection(balance, totalIncome, totalExpense),
              const SizedBox(height: 24),
              _buildRecentTransactionsHeader(filteredTransactions.length),
              const SizedBox(height: 8),
              filteredTransactions.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredTransactions.length > 5 ? 5 : filteredTransactions.length,
                itemBuilder: (context, index) {
                  final expense = filteredTransactions[index];
                  return TransactionCard(
                    id: expense.id,
                    title: expense.title,
                    amount: expense.amount,
                    date: expense.date,
                    category: expense.category,
                    note: expense.note,
                    isIncome: expense.isIncome,
                    onTap: () {},
                    onLongPress: () => _showDeleteDialog(expense),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push<Expense>(
            context,
            MaterialPageRoute(builder: (context) => const AddTransactionScreen()),
          );
          if (result != null) {
            await _addTransaction(result);
          }
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildDateSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildPeriodChip('Week'),
            const SizedBox(width: 4),
            _buildPeriodChip('Month'),
            const SizedBox(width: 4),
            _buildPeriodChip('Year'),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodChip(String label) {
    final isSelected = _selectedPeriod == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedPeriod = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildStatsSection(double balance, double totalIncome, double totalExpense) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(child: _buildStatCard('Balance', balance, AppColors.primary, Icons.account_balance_wallet, '\$')),
          const SizedBox(width: 12),
          Expanded(child: _buildStatCard('Income', totalIncome, AppColors.success, Icons.trending_up, '+ \$')),
          const SizedBox(width: 12),
          Expanded(child: _buildStatCard('Expenses', totalExpense, AppColors.error, Icons.trending_down, '- \$')),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, double amount, Color color, IconData icon, String prefix) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Text(title, style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '$prefix${amount.toStringAsFixed(2)}',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactionsHeader(int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TransactionHistoryScreen()),
              );
            },
            child: const Text(
              'Recent Transactions',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text('$count total', style: TextStyle(fontSize: 12, color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle),
              child: Icon(Icons.receipt_long, size: 48, color: AppColors.primary),
            ),
            const SizedBox(height: 16),
            Text('No transactions yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            Text('Tap the + button to add your first transaction', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}