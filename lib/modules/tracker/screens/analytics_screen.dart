import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spend_pilot/core/constants/colors.dart';
import 'package:spend_pilot/core/widgets/charts/bar_chart_widget.dart';
import 'package:spend_pilot/core/widgets/charts/line_chart_widget.dart';
import 'package:spend_pilot/core/widgets/charts/pie_chart_widget.dart';
import 'package:spend_pilot/data/providers/analytics_provider.dart';
import 'package:spend_pilot/data/providers/transaction_provider.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  String _selectedPeriod = 'Month';
  String _selectedLineChart = 'Expense'; // Expense, Income, Net Worth
  final List<String> _periods = ['Week', 'Month', 'Year', 'All time'];

  DateTime _getStartDate() {
    final now = DateTime.now();
    switch (_selectedPeriod) {
      case 'Week':
        return now.subtract(Duration(days: now.weekday - 1));
      case 'Month':
        return DateTime(now.year, now.month, 1);
      case 'Year':
        return DateTime(now.year, 1, 1);
      case 'All time':
        return DateTime(2000, 1, 1);
      default:
        return DateTime(now.year, now.month, 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final analytics = ref.watch(analyticsProvider);
    final allTransactions = ref.watch(transactionProvider);

    final startDate = _getStartDate();
    final endDate = DateTime.now();

    // Data for Pie Chart (Expenses only)
    final spendingByCategory = analytics.getSpendingByCategory(startDate, endDate);
    final totalSpending = spendingByCategory.values.fold(0.0, (sum, val) => sum + val);

    // Data for Bar Chart (6 months)
    final monthlyData = analytics.getMonthlyData(6);

    // Data for Line Chart (12 months)
    final expenseTrend = analytics.getTrendData('month', 12);
    final incomeTrend = _getIncomeTrend(analytics, 12);
    final netWorthTrend = _getNetWorthTrend(analytics, 12);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Analytics'),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Period Selector
            _buildPeriodSelector(),
            const SizedBox(height: 24),

            // Pie Chart Section
            const Text(
              'Spending by Category',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _selectedPeriod == 'All time' ? 'All time' : 'This $_selectedPeriod',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            PieChartWidget(
              data: spendingByCategory,
              total: totalSpending,
            ),
            const SizedBox(height: 32),

            // Bar Chart Section
            const Text(
              'Monthly Income vs Expense',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            BarChartWidget(data: monthlyData),
            const SizedBox(height: 32),

            // Line Chart Section with Toggle
            const Text(
              'Trend Analysis',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildLineChartToggle(),
            const SizedBox(height: 16),
            LineChartWidget(
              data: _selectedLineChart == 'Expense' ? expenseTrend :
              (_selectedLineChart == 'Income' ? incomeTrend : netWorthTrend),
              title: _selectedLineChart == 'Expense' ? 'Expense Trend' :
              (_selectedLineChart == 'Income' ? 'Income Trend' : 'Net Worth Trend'),
              lineColor: _selectedLineChart == 'Expense' ? AppColors.error :
              (_selectedLineChart == 'Income' ? AppColors.success : AppColors.primary),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Row(
      children: _periods.map((period) {
        final isSelected = _selectedPeriod == period;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () => setState(() => _selectedPeriod = period),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                ),
              ),
              child: Text(
                period,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLineChartToggle() {
    return Row(
      children: [
        _buildToggleChip('Expense', _selectedLineChart == 'Expense', AppColors.error),
        const SizedBox(width: 8),
        _buildToggleChip('Income', _selectedLineChart == 'Income', AppColors.success),
        const SizedBox(width: 8),
        _buildToggleChip('Net Worth', _selectedLineChart == 'Net Worth', AppColors.primary),
      ],
    );
  }

  Widget _buildToggleChip(String label, bool isSelected, Color color) {
    return GestureDetector(
      onTap: () => setState(() => _selectedLineChart = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.15) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isSelected ? color : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  List<TrendData> _getIncomeTrend(AnalyticsData analytics, int months) {
    // Simplified - you may want to add this to your provider
    final allTransactions = ref.read(transactionProvider);
    final now = DateTime.now();
    final result = <TrendData>[];

    for (int i = months - 1; i >= 0; i--) {
      final date = DateTime(now.year, now.month - i, 1);
      final startDate = DateTime(date.year, date.month, 1);
      final endDate = DateTime(date.year, date.month + 1, 0);

      final monthTransactions = allTransactions.where((t) =>
      t.isIncome &&
          t.date.isAfter(startDate) &&
          t.date.isBefore(endDate)
      ).toList();

      final total = monthTransactions.fold(0.0, (sum, t) => sum + t.amount);

      result.add(TrendData(
        label: _getMonthName(date.month),
        amount: total,
      ));
    }
    return result;
  }

  List<TrendData> _getNetWorthTrend(AnalyticsData analytics, int months) {
    final allTransactions = ref.read(transactionProvider);
    final now = DateTime.now();
    final result = <TrendData>[];

    for (int i = months - 1; i >= 0; i--) {
      final date = DateTime(now.year, now.month - i, 1);
      final startDate = DateTime(date.year, date.month, 1);
      final endDate = DateTime(date.year, date.month + 1, 0);

      final monthTransactions = allTransactions.where((t) =>
      t.date.isAfter(startDate) &&
          t.date.isBefore(endDate)
      ).toList();

      final income = monthTransactions.where((t) => t.isIncome).fold(0.0, (sum, t) => sum + t.amount);
      final expense = monthTransactions.where((t) => !t.isIncome).fold(0.0, (sum, t) => sum + t.amount);

      result.add(TrendData(
        label: _getMonthName(date.month),
        amount: income - expense,
      ));
    }
    return result;
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }
}