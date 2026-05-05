import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spend_pilot/data/providers/transaction_provider.dart';
import 'package:spend_pilot/shared/models/expense.dart';

final analyticsProvider = Provider((ref) {
  final transactions = ref.watch(transactionProvider);
  return AnalyticsData(transactions);
});

class AnalyticsData {
  final List<Expense> _transactions;

  AnalyticsData(this._transactions);

  // Get spending by category for pie chart
  Map<String, double> getSpendingByCategory(DateTime startDate, DateTime endDate) {
    final filtered = _transactions.where((t) =>
    !t.isIncome &&
        t.date.isAfter(startDate) &&
        t.date.isBefore(endDate.add(const Duration(days: 1)))
    ).toList();

    final Map<String, double> categorySpending = {};
    for (final transaction in filtered) {
      categorySpending[transaction.category] =
          (categorySpending[transaction.category] ?? 0) + transaction.amount;
    }
    return categorySpending;
  }

  // Get monthly income vs expense for bar chart
  List<MonthlyData> getMonthlyData(int months) {
    final now = DateTime.now();
    final List<MonthlyData> result = [];

    for (int i = months - 1; i >= 0; i--) {
      final date = DateTime(now.year, now.month - i, 1);
      final startDate = DateTime(date.year, date.month, 1);
      final endDate = DateTime(date.year, date.month + 1, 0);

      final monthlyTransactions = _transactions.where((t) =>
      t.date.isAfter(startDate) &&
          t.date.isBefore(endDate.add(const Duration(days: 1)))
      ).toList();

      final income = monthlyTransactions
          .where((t) => t.isIncome)
          .fold(0.0, (sum, t) => sum + t.amount);

      final expense = monthlyTransactions
          .where((t) => !t.isIncome)
          .fold(0.0, (sum, t) => sum + t.amount);

      result.add(MonthlyData(
        month: _getMonthName(date.month),
        income: income,
        expense: expense,
        netWorth: income - expense,
      ));
    }
    return result;
  }

  // Get daily/weekly/monthly trend for line chart
  List<TrendData> getTrendData(String period, int range) {
    final now = DateTime.now();
    final List<TrendData> result = [];

    if (period == 'day') {
      for (int i = range - 1; i >= 0; i--) {
        final date = now.subtract(Duration(days: i));
        final dayStart = DateTime(date.year, date.month, date.day);
        final dayEnd = DateTime(date.year, date.month, date.day, 23, 59, 59);

        final dayTransactions = _transactions.where((t) =>
        t.date.isAfter(dayStart) &&
            t.date.isBefore(dayEnd)
        ).toList();

        final expense = dayTransactions
            .where((t) => !t.isIncome)
            .fold(0.0, (sum, t) => sum + t.amount);

        result.add(TrendData(
          label: '${date.day}/${date.month}',
          amount: expense,
        ));
      }
    } else if (period == 'week') {
      for (int i = range - 1; i >= 0; i--) {
        final startDate = now.subtract(Duration(days: i * 7));
        final endDate = startDate.add(const Duration(days: 6));

        final weekTransactions = _transactions.where((t) =>
        t.date.isAfter(startDate) &&
            t.date.isBefore(endDate)
        ).toList();

        final expense = weekTransactions
            .where((t) => !t.isIncome)
            .fold(0.0, (sum, t) => sum + t.amount);

        result.add(TrendData(
          label: 'Week ${range - i}',
          amount: expense,
        ));
      }
    } else {
      // month
      for (int i = range - 1; i >= 0; i--) {
        final date = DateTime(now.year, now.month - i, 1);
        final startDate = DateTime(date.year, date.month, 1);
        final endDate = DateTime(date.year, date.month + 1, 0);

        final monthTransactions = _transactions.where((t) =>
        t.date.isAfter(startDate) &&
            t.date.isBefore(endDate)
        ).toList();

        final expense = monthTransactions
            .where((t) => !t.isIncome)
            .fold(0.0, (sum, t) => sum + t.amount);

        result.add(TrendData(
          label: _getMonthName(date.month),
          amount: expense,
        ));
      }
    }
    return result;
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }
}

class MonthlyData {
  final String month;
  final double income;
  final double expense;
  final double netWorth;

  MonthlyData({
    required this.month,
    required this.income,
    required this.expense,
    required this.netWorth,
  });
}

class TrendData {
  final String label;
  final double amount;

  TrendData({required this.label, required this.amount});
}