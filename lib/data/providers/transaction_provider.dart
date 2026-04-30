import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spend_pilot/data/services/hive_service.dart';
import 'package:spend_pilot/shared/models/expense.dart';

// Provider for Hive service - use the same instance
final hiveServiceProvider = Provider<HiveService>((ref) {
  return HiveService.instance;
});

// Provider for transactions
final transactionProvider = StateNotifierProvider<TransactionNotifier, List<Expense>>((ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  return TransactionNotifier(hiveService);
});

class TransactionNotifier extends StateNotifier<List<Expense>> {
  final HiveService _hiveService;

  TransactionNotifier(this._hiveService) : super([]) {
    _loadTransactions();
  }

  // Load from Hive
  Future<void> _loadTransactions() async {
    try {
      final saved = await _hiveService.getAllExpenses();
      if (saved.isEmpty) {
        // First launch - load mock data
        state = _mockTransactions;
        await _saveAllToHive();
      } else {
        state = saved;
      }
    } catch (e) {
      // If error, load mock data
      state = _mockTransactions;
    }
  }

  // Save all to Hive
  Future<void> _saveAllToHive() async {
    for (var expense in state) {
      await _hiveService.addExpense(expense);
    }
  }

  // Mock data for first-time users
  static final List<Expense> _mockTransactions = [
    Expense(
      id: '1',
      title: 'Grocery Shopping',
      amount: 85.50,
      date: DateTime.now().subtract(const Duration(days: 1)),
      category: 'food',
      note: 'Weekly groceries',
      isIncome: false,
    ),
    Expense(
      id: '2',
      title: 'Salary',
      amount: 3000.00,
      date: DateTime.now().subtract(const Duration(days: 3)),
      category: 'other',
      note: 'Monthly salary',
      isIncome: true,
    ),
    Expense(
      id: '3',
      title: 'Uber Ride',
      amount: 15.75,
      date: DateTime.now().subtract(const Duration(days: 4)),
      category: 'transport',
      note: null,
      isIncome: false,
    ),
    Expense(
      id: '4',
      title: 'Movie Tickets',
      amount: 24.00,
      date: DateTime.now().subtract(const Duration(days: 5)),
      category: 'entertainment',
      note: 'Weekend movie',
      isIncome: false,
    ),
    Expense(
      id: '5',
      title: 'Freelance Work',
      amount: 500.00,
      date: DateTime.now().subtract(const Duration(days: 6)),
      category: 'other',
      note: 'Website project',
      isIncome: true,
    ),
  ];

  // Add transaction
  Future<void> addTransaction(Expense expense) async {
    state = [expense, ...state];
    await _hiveService.addExpense(expense);
  }

  // Delete transaction
  Future<void> deleteTransaction(String id) async {
    state = state.where((e) => e.id != id).toList();
    await _hiveService.deleteExpense(id);
  }
}