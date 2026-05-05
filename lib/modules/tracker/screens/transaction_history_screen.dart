import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spend_pilot/core/constants/colors.dart';
import 'package:spend_pilot/core/constants/categories.dart';
import 'package:spend_pilot/core/widgets/filters/category_filter_row.dart';
import 'package:spend_pilot/core/widgets/filters/period_chip.dart';
import 'package:spend_pilot/core/widgets/filters/sort_dropdown.dart';
import 'package:spend_pilot/data/providers/transaction_provider.dart';
import 'package:spend_pilot/modules/tracker/widgets/transaction_card.dart';
import 'package:spend_pilot/shared/models/expense.dart';

class TransactionHistoryScreen extends ConsumerStatefulWidget {
  final String initialCategory;
  final String initialType;
  final String initialSortOrder;
  final String initialPeriod;

  const TransactionHistoryScreen({
    super.key,
    this.initialCategory = 'all',
    this.initialType = 'All Types',
    this.initialSortOrder = 'newest',
    this.initialPeriod = 'Month',
  });

  @override
  ConsumerState<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends ConsumerState<TransactionHistoryScreen> {
  late String _searchQuery;
  late String _selectedCategory;
  late String _selectedType;
  late String _sortOrder;
  late String _selectedPeriod;

  final List<String> _periods = ['Today', 'Week', 'Month', 'Year', 'All time'];
  final List<String> _typeOptions = ['All Types', 'Income', 'Expense'];
  final List<String> _sortOptions = ['newest', 'oldest', 'amount_high', 'amount_low'];
  final Map<String, String> _sortLabels = {
    'newest': 'Newest first',
    'oldest': 'Oldest first',
    'amount_high': 'Amount: High to Low',
    'amount_low': 'Amount: Low to High',
  };

  // Check if any filter is active (for Clear All button)
  bool get _isAnyFilterActive {
    return _searchQuery.isNotEmpty ||
        _selectedCategory != 'all' ||
        _selectedType != 'All Types';
  }

  // Get active filter count
  int get _activeFilterCount {
    int count = 0;
    if (_searchQuery.isNotEmpty) count++;
    if (_selectedCategory != 'all') count++;
    if (_selectedType != 'All Types') count++;
    return count;
  }

  @override
  void initState() {
    super.initState();
    _searchQuery = '';
    _selectedCategory = widget.initialCategory;
    _selectedType = widget.initialType == 'all'
        ? 'All Types'
        : (widget.initialType == 'income' ? 'Income' :
    (widget.initialType == 'expense' ? 'Expense' : widget.initialType));
    _sortOrder = widget.initialSortOrder;
    _selectedPeriod = widget.initialPeriod;
  }

  List<Expense> _getFilteredTransactions(List<Expense> allTransactions) {
    final now = DateTime.now();

    List<Expense> filtered;

    if (_selectedPeriod == 'All time') {
      filtered = List<Expense>.from(allTransactions);
    } else {
      DateTime startDate;
      switch (_selectedPeriod) {
        case 'Today':
          startDate = DateTime(now.year, now.month, now.day);
          break;
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
      filtered = allTransactions.where((e) =>
      e.date.isAfter(startDate) &&
          e.date.isBefore(now.add(const Duration(days: 1)))
      ).toList();
    }


    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((t) =>
      t.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (t.note?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false)
      ).toList();
    }


    if (_selectedCategory != 'all') {
      filtered = filtered.where((t) => t.category == _selectedCategory).toList();
    }


    if (_selectedType == 'Income') {
      filtered = filtered.where((t) => t.isIncome).toList();
    } else if (_selectedType == 'Expense') {
      filtered = filtered.where((t) => !t.isIncome).toList();
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

  void _clearAllFilters() {
    setState(() {
      _searchQuery = '';
      _selectedCategory = 'all';
      _selectedType = 'All Types';

    });
  }

  @override
  Widget build(BuildContext context) {
    final allTransactions = ref.watch(transactionProvider);
    final filteredTransactions = _getFilteredTransactions(allTransactions);


    final showCategoryFilters = _selectedType != 'All Types';
    final categories = _selectedType == 'Income'
        ? IncomeCategory.all
        : (_selectedType == 'Expense' ? ExpenseCategory.all : []);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Transaction History'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_isAnyFilterActive)
            TextButton(
              onPressed: _clearAllFilters,
              child: Text(
                'Clear All (${_activeFilterCount})',
                style: const TextStyle(color: AppColors.error),
              ),
            ),
        ],
      ),
      body: Column(
        children: [

          _buildSearchBar(),

          _buildPeriodSelector(),

          _buildTypeDropdown(),

          // Category Chips (only when Income or Expense selected)
          if (showCategoryFilters && categories.isNotEmpty)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: CategoryFilterRow(
                categories: categories,
                selectedCategoryId: _selectedCategory,
                onCategorySelected: (id) =>
                    setState(() => _selectedCategory = id),
                allChipColor: _selectedType == 'Income'
                    ? AppColors.success
                    : AppColors.error,
              ),
            ),

          // Sort and Count Row
          _buildSortAndCountRow(filteredTransactions.length),

          // Transaction List
          Expanded(
            child: filteredTransactions.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
              padding: const EdgeInsets.only(bottom: 16),
              itemCount: filteredTransactions.length,
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
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: InputDecoration(
          hintText: 'Search by title or note...',
          prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.clear, color: AppColors.textSecondary),
            onPressed: () => setState(() => _searchQuery = ''),
          )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
    );
  }

  Widget _buildTypeDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Text(
            'Type:',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.border),
            ),
            child: DropdownButton<String>(
              value: _selectedType,
              underline: const SizedBox(),
              icon: const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
              items: _typeOptions.map((String type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedType = value!;
                  _selectedCategory = 'all'; // Reset category when type changes
                });
              },
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildSortAndCountRow(int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle),
            child: Icon(Icons.receipt_long, size: 48, color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          Text(
            'No transactions found',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filters',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(Expense expense) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Transaction'),
        content: Text('Delete "${expense.title}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await ref.read(transactionProvider.notifier).deleteTransaction(expense.id);
              if (mounted) Navigator.pop(dialogContext);
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}