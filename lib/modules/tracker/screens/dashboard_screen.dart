import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spend_pilot/core/constants/colors.dart';
import 'package:spend_pilot/core/constants/categories.dart';
import 'package:spend_pilot/core/widgets/cards/stat_card.dart';
import 'package:spend_pilot/core/widgets/filters/period_chip.dart';
import 'package:spend_pilot/core/widgets/filters/filter_chip.dart';
import 'package:spend_pilot/core/widgets/filters/sort_dropdown.dart';
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
  String _selectedStat = 'Balance';
  String _selectedPeriod = 'Month';
  String _selectedCategory = 'all';
  String _sortOrder = 'newest';
  bool _showLifetimeAmounts = true;

  final List<String> _periods = ['Today', 'Week', 'Month', 'Year'];
  final List<String> _sortOptions = ['newest', 'oldest', 'amount_high', 'amount_low'];
  final Map<String, String> _sortLabels = {
    'newest': 'Newest first',
    'oldest': 'Oldest first',
    'amount_high': 'Amount: High to Low',
    'amount_low': 'Amount: Low to High',
  };

  bool get _isFilterActive {
    return _selectedCategory != 'all';
  }

  // Get start date based on selected period
  DateTime _getStartDate() {
    final now = DateTime.now();
    switch (_selectedPeriod) {
      case 'Today':
        return DateTime(now.year, now.month, now.day);
      case 'Week':
        return now.subtract(Duration(days: now.weekday - 1));
      case 'Month':
        return DateTime(now.year, now.month, 1);
      case 'Year':
        return DateTime(now.year, 1, 1);
      default:
        return DateTime(now.year, now.month, 1);
    }
  }

  // Filter by period only (no type filter) - used for Balance card
  List<Expense> _getPeriodFilteredTransactions(List<Expense> allTransactions) {
    final now = DateTime.now();
    final startDate = _getStartDate();

    return allTransactions.where((e) =>
    e.date.isAfter(startDate) &&
        e.date.isBefore(now.add(const Duration(days: 1)))
    ).toList();
  }

  // Filter by period + type - used for Income/Expense cards and transaction list
  List<Expense> _getPeriodAndTypeFilteredTransactions(List<Expense> allTransactions, String type) {
    final now = DateTime.now();
    final startDate = _getStartDate();

    var filtered = allTransactions.where((e) =>
    e.date.isAfter(startDate) &&
        e.date.isBefore(now.add(const Duration(days: 1)))
    ).toList();

    if (type == 'Income') {
      filtered = filtered.where((e) => e.isIncome).toList();
    } else if (type == 'Expense') {
      filtered = filtered.where((e) => !e.isIncome).toList();
    }

    return filtered;
  }

  // Main filtered transactions for the list (respects selected stat and category)
  List<Expense> _getFilteredTransactions(List<Expense> allTransactions) {
    final now = DateTime.now();
    final startDate = _getStartDate();

    var filtered = allTransactions.where((e) =>
    e.date.isAfter(startDate) &&
        e.date.isBefore(now.add(const Duration(days: 1)))
    ).toList();

    if (_selectedStat == 'Income') {
      filtered = filtered.where((e) => e.isIncome).toList();
    } else if (_selectedStat == 'Expense') {
      filtered = filtered.where((e) => !e.isIncome).toList();
    }

    if ((_selectedStat == 'Income' || _selectedStat == 'Expense') && _selectedCategory != 'all') {
      filtered = filtered.where((e) => e.category == _selectedCategory).toList();
    }

    switch (_sortOrder) {
      case 'newest':
        filtered.sort((a, b) => b.date.compareTo(a.date));
        break;
      case 'oldest':
        filtered.sort((a, b) => a.date.compareTo(b.date));
        break;
      case 'amount_high':
        filtered.sort((a, b) => b.amount.compareTo(a.amount));
        break;
      case 'amount_low':
        filtered.sort((a, b) => a.amount.compareTo(b.amount));
        break;
    }

    return filtered;
  }

  double _getTotalIncome(List<Expense> transactions) {
    return transactions.where((e) => e.isIncome).fold(0.0, (sum, e) => sum + e.amount);
  }

  double _getTotalExpense(List<Expense> transactions) {
    return transactions.where((e) => !e.isIncome).fold(0.0, (sum, e) => sum + e.amount);
  }

  double _getBalance(List<Expense> transactions) {
    return _getTotalIncome(transactions) - _getTotalExpense(transactions);
  }

  void _resetFilters() {
    setState(() {
      _selectedCategory = 'all';
    });
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

    // BALANCE CARD: uses period-filtered transactions (both income and expense)
    final periodAllTransactions = _getPeriodFilteredTransactions(allTransactions);
    final periodBalance = _getBalance(periodAllTransactions);

    // INCOME CARD: uses period + income type filtered transactions
    final periodIncomeTransactions = _getPeriodAndTypeFilteredTransactions(allTransactions, 'Income');
    final periodIncome = _getTotalIncome(periodIncomeTransactions);

    // EXPENSE CARD: uses period + expense type filtered transactions
    final periodExpenseTransactions = _getPeriodAndTypeFilteredTransactions(allTransactions, 'Expense');
    final periodExpense = _getTotalExpense(periodExpenseTransactions);

    // Lifetime totals (all-time, no filters)
    final lifetimeIncome = _getTotalIncome(allTransactions);
    final lifetimeExpense = _getTotalExpense(allTransactions);
    final lifetimeBalance = _getBalance(allTransactions);

    // Transaction list (respects selected stat and category)
    final filteredTransactions = _getFilteredTransactions(allTransactions);

    final showSubFilters = _selectedStat == 'Income' || _selectedStat == 'Expense';
    final subFilterCategories = _selectedStat == 'Income'
        ? IncomeCategory.all
        : (_selectedStat == 'Expense' ? ExpenseCategory.all : []);

    String periodText = '';
    switch (_selectedPeriod) {
      case 'Today': periodText = 'Today'; break;
      case 'Week': periodText = 'This Week'; break;
      case 'Month': periodText = 'This Month'; break;
      case 'Year': periodText = 'This Year'; break;
    }

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
              const SizedBox(height: 8),
              _buildLifetimeTotalsRow(lifetimeBalance, lifetimeIncome, lifetimeExpense),
              const SizedBox(height: 16),
              _buildStatsSection(periodBalance, periodIncome, periodExpense, periodText),
              const SizedBox(height: 16),
              _buildPeriodSelector(),
              const SizedBox(height: 12),
              if (showSubFilters) _buildSubFilterRow(subFilterCategories),
              if (showSubFilters && subFilterCategories.isNotEmpty) const SizedBox(height: 12),
              _buildSortAndCountRow(filteredTransactions.length),
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
              const SizedBox(height: 16),
              _buildSeeAllButton(filteredTransactions.length),
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

  Widget _buildLifetimeTotalsRow(double balance, double income, double expense) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Scrollable stats
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Text(
                    'Lifetime ',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    'Balance: ',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  Text(
                    _showLifetimeAmounts ? '\$${balance.toStringAsFixed(2)}' : '•••••',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Income: ',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  Text(
                    _showLifetimeAmounts ? '\$${income.toStringAsFixed(2)}' : '•••••',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Expense: ',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  Text(
                    _showLifetimeAmounts ? '\$${expense.toStringAsFixed(2)}' : '•••••',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Eye icon
          GestureDetector(
            onTap: () {
              setState(() {
                _showLifetimeAmounts = !_showLifetimeAmounts;
              });
            },
            child: Icon(
              _showLifetimeAmounts ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              size: 18,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(double balance, double income, double expense, String periodText) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: StatCard(
              title: 'Balance',
              amount: balance,
              color: AppColors.primary,
              icon: Icons.account_balance_wallet,
              prefix: '\$',
              isSelected: _selectedStat == 'Balance',
              onTap: () => setState(() {
                _selectedStat = 'Balance';
                _selectedCategory = 'all';
              }),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: StatCard(
              title: 'Income',
              amount: income,
              color: AppColors.success,
              icon: Icons.trending_up,
              prefix: '+ \$',
              isSelected: _selectedStat == 'Income',
              onTap: () => setState(() {
                _selectedStat = 'Income';
                _selectedCategory = 'all';
              }),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: StatCard(
              title: 'Expense',
              amount: expense,
              color: AppColors.error,
              icon: Icons.trending_down,
              prefix: '- \$',
              isSelected: _selectedStat == 'Expense',
              onTap: () => setState(() {
                _selectedStat = 'Expense';
                _selectedCategory = 'all';
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _periods.map((period) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: PeriodChip(
                      label: period,
                      isSelected: _selectedPeriod == period,
                      onTap: () => setState(() => _selectedPeriod = period),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          if (_isFilterActive)
            GestureDetector(
              onTap: _resetFilters,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.clear, size: 14, color: AppColors.error),
                    const SizedBox(width: 4),
                    Text(
                      'Reset',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.error,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSubFilterRow(List<dynamic> categories) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          FilterChipWidget(
            label: 'All',
            isSelected: _selectedCategory == 'all',
            onTap: () => setState(() => _selectedCategory = 'all'),
            selectedColor: _selectedStat == 'Income' ? AppColors.success : AppColors.error,
          ),
          const SizedBox(width: 8),
          ...categories.map((category) {
            final isSelected = _selectedCategory == category.id;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChipWidget(
                label: category.name,
                icon: category.icon,
                isSelected: isSelected,
                onTap: () => setState(() {
                  if (isSelected) {
                    _selectedCategory = 'all';
                  } else {
                    _selectedCategory = category.id;
                  }
                }),
                selectedColor: category.color,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSortAndCountRow(int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$count transactions',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          SortDropdown(
            selectedValue: _sortOrder,
            onChanged: (value) => setState(() => _sortOrder = value),
            options: _sortOptions,
            optionLabels: _sortLabels,
          ),
        ],
      ),
    );
  }

  Widget _buildSeeAllButton(int count) {
    if (count == 0) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Center(
        child: TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TransactionHistoryScreen(
                  initialCategory: _selectedCategory,
                  initialType: _selectedStat == 'Income' ? 'income' : (_selectedStat == 'Expense' ? 'expense' : 'all'),
                  initialSortOrder: _sortOrder,
                  initialPeriod: _selectedPeriod,
                ),
              ),
            );
          },
          child: const Text(
            'See All Transactions →',
            style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w500),
          ),
        ),
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
            Text('No transactions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            Text('Tap + to add your first transaction', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}