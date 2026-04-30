import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spend_pilot/core/constants/colors.dart';
import 'package:spend_pilot/core/constants/categories.dart';
import 'package:spend_pilot/data/providers/transaction_provider.dart';
import 'package:spend_pilot/modules/tracker/widgets/transaction_card.dart';
import 'package:spend_pilot/shared/models/expense.dart';

class TransactionHistoryScreen extends ConsumerStatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  ConsumerState<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends ConsumerState<TransactionHistoryScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'all';
  String _selectedType = 'all'; // all, income, expense
  String _sortOrder = 'newest'; // newest, oldest

  DateTimeRange? _selectedDateRange;

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }

  void _clearFilters() {
    setState(() {
      _searchQuery = '';
      _selectedCategory = 'all';
      _selectedType = 'all';
      _selectedDateRange = null;
      _sortOrder = 'newest';
    });
  }

  List<Expense> _filterTransactions(List<Expense> transactions) {
    List<Expense> filtered = List.from(transactions);

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((t) =>
      t.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (t.note?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false)
      ).toList();
    }

    // Filter by category
    if (_selectedCategory != 'all') {
      filtered = filtered.where((t) => t.category == _selectedCategory).toList();
    }

    // Filter by type
    if (_selectedType == 'income') {
      filtered = filtered.where((t) => t.isIncome).toList();
    } else if (_selectedType == 'expense') {
      filtered = filtered.where((t) => !t.isIncome).toList();
    }

    // Filter by date range
    if (_selectedDateRange != null) {
      filtered = filtered.where((t) =>
      t.date.isAfter(_selectedDateRange!.start) &&
          t.date.isBefore(_selectedDateRange!.end.add(const Duration(days: 1)))
      ).toList();
    }

    // Sort
    if (_sortOrder == 'newest') {
      filtered.sort((a, b) => b.date.compareTo(a.date));
    } else {
      filtered.sort((a, b) => a.date.compareTo(b.date));
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final allTransactions = ref.watch(transactionProvider);
    final filteredTransactions = _filterTransactions(allTransactions);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Transaction History'),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_searchQuery.isNotEmpty ||
              _selectedCategory != 'all' ||
              _selectedType != 'all' ||
              _selectedDateRange != null)
            IconButton(
              icon: const Icon(Icons.clear_all),
              onPressed: _clearFilters,
              tooltip: 'Clear filters',
            ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          _buildSearchBar(),

          // Filter chips
          _buildFilterChips(),

          // Results count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${filteredTransactions.length} transactions',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                _buildSortButton(),
              ],
            ),
          ),

          // Transaction list
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
                  onTap: () {
                    // TODO: Navigate to detail screen
                  },
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

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Category filter
          FilterChip(
            label: const Text('All'),
            selected: _selectedCategory == 'all',
            onSelected: (_) => setState(() => _selectedCategory = 'all'),
            backgroundColor: Colors.white,
            selectedColor: AppColors.primaryLight,
            checkmarkColor: AppColors.primary,
          ),
          const SizedBox(width: 8),
          ...ExpenseCategory.all.map((category) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(category.name),
                selected: _selectedCategory == category.id,
                onSelected: (_) => setState(() => _selectedCategory = category.id),
                backgroundColor: Colors.white,
                selectedColor: category.color.withValues(alpha: 0.2),
                checkmarkColor: category.color,
                avatar: Text(category.icon),
              ),
            );
          }),

          const SizedBox(width: 16),

          // Type filter
          FilterChip(
            label: const Text('All Types'),
            selected: _selectedType == 'all',
            onSelected: (_) => setState(() => _selectedType = 'all'),
            backgroundColor: Colors.white,
            selectedColor: AppColors.primaryLight,
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('Income'),
            selected: _selectedType == 'income',
            onSelected: (_) => setState(() => _selectedType = 'income'),
            backgroundColor: Colors.white,
            selectedColor: AppColors.success.withValues(alpha: 0.2),
            checkmarkColor: AppColors.success,
            avatar: const Icon(Icons.trending_up, size: 18),
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('Expense'),
            selected: _selectedType == 'expense',
            onSelected: (_) => setState(() => _selectedType = 'expense'),
            backgroundColor: Colors.white,
            selectedColor: AppColors.error.withValues(alpha: 0.2),
            checkmarkColor: AppColors.error,
            avatar: const Icon(Icons.trending_down, size: 18),
          ),

          const SizedBox(width: 16),

          // Date range filter
          FilterChip(
            label: Text(_selectedDateRange == null ? 'Date Range' : '${_selectedDateRange!.start.day}/${_selectedDateRange!.start.month} - ${_selectedDateRange!.end.day}/${_selectedDateRange!.end.month}'),
            selected: _selectedDateRange != null,
            onSelected: (_) => _pickDateRange(),
            backgroundColor: Colors.white,
            selectedColor: AppColors.primaryLight,
            avatar: const Icon(Icons.calendar_today, size: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildSortButton() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _sortOrder = _sortOrder == 'newest' ? 'oldest' : 'newest';
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _sortOrder == 'newest' ? Icons.arrow_downward : Icons.arrow_upward,
              size: 16,
              color: AppColors.primary,
            ),
            const SizedBox(width: 4),
            Text(
              _sortOrder == 'newest' ? 'Newest first' : 'Oldest first',
              style: TextStyle(fontSize: 12, color: AppColors.primary),
            ),
          ],
        ),
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
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
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