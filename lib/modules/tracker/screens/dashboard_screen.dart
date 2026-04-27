import 'package:flutter/material.dart';
import 'package:spend_pilot/core/constants/colors.dart';
import 'package:spend_pilot/core/constants/categories.dart';
import 'package:spend_pilot/shared/models/expense.dart';
import 'package:spend_pilot/modules/tracker/widgets/transaction_card.dart';
import 'package:spend_pilot/core/utils/date_formatter.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Mock data - will be replaced with real data source later
  List<Expense> _expenses = [];
  double _totalIncome = 0;
  double _totalExpense = 0;
  double _balance = 0;

  @override
  void initState() {
    super.initState();
    _loadMockData();
  }

  void _loadMockData() {
    final now = DateTime.now();
    _expenses = [
      Expense(
        id: '1',
        title: 'Salary',
        amount: 3000.00,
        date: DateTime(now.year, now.month, 25),
        category: 'other',
        isIncome: true,
      ),
      Expense(
        id: '2',
        title: 'Coffee',
        amount: 4.50,
        date: DateTime(now.year, now.month, now.day),
        category: 'food',
      ),
      Expense(
        id: '3',
        title: 'Uber Ride',
        amount: 12.00,
        date: DateTime(now.year, now.month, now.day - 1),
        category: 'transport',
      ),
      Expense(
        id: '4',
        title: 'Grocery Shopping',
        amount: 85.50,
        date: DateTime(now.year, now.month, now.day - 2),
        category: 'shopping',
      ),
      Expense(
        id: '5',
        title: 'Netflix',
        amount: 15.99,
        date: DateTime(now.year, now.month, now.day - 5),
        category: 'entertainment',
      ),
      Expense(
        id: '6',
        title: 'Gym Membership',
        amount: 50.00,
        date: DateTime(now.year, now.month, now.day - 8),
        category: 'healthcare',
      ),
      Expense(
        id: '7',
        title: 'Electricity Bill',
        amount: 75.00,
        date: DateTime(now.year, now.month, now.day - 12),
        category: 'bills',
      ),
    ];
    _calculateStats();
  }

  void _calculateStats() {
    _totalIncome = _expenses
        .where((e) => e.isIncome)
        .fold(0, (sum, e) => sum + e.amount);
    _totalExpense = _expenses
        .where((e) => !e.isIncome)
        .fold(0, (sum, e) => sum + e.amount);
    _balance = _totalIncome - _totalExpense;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Spend Pilot'),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Search functionality
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              // TODO: Profile screen
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadMockData();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date Selector
              _buildDateSelector(),
              const SizedBox(height: 16),

              // Stats Cards
              _buildStatsSection(),
              const SizedBox(height: 24),

              // Recent Transactions Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Recent Transactions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // TODO: Navigate to full transaction history
                      },
                      child: const Text('See All'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Transaction List
              _expenses.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _expenses.length > 5 ? 5 : _expenses.length,
                itemBuilder: (context, index) {
                  return TransactionCard(
                    expense: _expenses[index],
                    onTap: () {
                      // TODO: View expense detail
                    },
                    onLongPress: () {
                      // TODO: Delete/edit options
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Add expense screen
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
    );
  }




  Widget _buildDateSelector() {
    final now = DateTime.now();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Text(
                  '${DateFormatter.getMonth(now.month)} ${now.day}, ${now.year}',
                  style: const TextStyle(fontSize: 14),
                ),
                const Icon(Icons.arrow_drop_down, size: 20),
              ],
            ),
          ),
          const Spacer(),
          _buildFilterChip('Week'),
          const SizedBox(width: 8),
          _buildFilterChip('Month'),
          const SizedBox(width: 8),
          _buildFilterChip('Year'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    return FilterChip(
      label: Text(label),
      selected: label == 'Month', // Default selected
      onSelected: (selected) {
        // TODO: Filter expenses by period
      },
      backgroundColor: Colors.white,
      selectedColor: AppColors.primaryLight,
      checkmarkColor: AppColors.primary,
      side: BorderSide(color: AppColors.border),
    );
  }

  Widget _buildStatsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              title: 'Balance',
              amount: _balance,
              color: AppColors.primary,
              icon: Icons.account_balance_wallet,
              prefix: '\$',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              title: 'Income',
              amount: _totalIncome,
              color: AppColors.success,
              icon: Icons.trending_up,
              prefix: '+ \$',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              title: 'Expenses',
              amount: _totalExpense,
              color: AppColors.error,
              icon: Icons.trending_down,
              prefix: '- \$',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required double amount,
    required Color color,
    required IconData icon,
    required String prefix,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '$prefix${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
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
            Icon(Icons.receipt_long, size: 64, color: AppColors.textTertiary),
            const SizedBox(height: 16),
            Text(
              'No transactions yet',
              style: TextStyle(color: AppColors.textTertiary),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                // TODO: Add expense
              },
              child: const Text('Add Your First Expense'),
            ),
          ],
        ),
      ),
    );
  }
}