import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spend_pilot/data/services/hive_service.dart';
import 'package:spend_pilot/shared/models/expense.dart';


final hiveServiceProvider = Provider<HiveService>((ref) {
  return HiveService.instance;
});


final transactionProvider = StateNotifierProvider<TransactionNotifier, List<Expense>>((ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  return TransactionNotifier(hiveService);
});

final allIncomeProvider = Provider<double>((ref) {
  return ref
      .watch(transactionProvider)
      .where((e) => e.isIncome)
      .fold(0.0, (sum, e) => sum + e.amount);
});

final allExpenseProvider = Provider<double>((ref) {
  return ref
      .watch(transactionProvider)
      .where((e) => !e.isIncome)
      .fold(0.0, (sum, e) => sum + e.amount);
});


final allBalanceProvider = Provider<double>((ref) {
  final income = ref.watch(allIncomeProvider);
  final expense = ref.watch(allExpenseProvider);
  return income - expense;
});


final transactionCountProvider = Provider<int>((ref) {
  return ref.watch(transactionProvider).length;
});



class TransactionNotifier extends StateNotifier<List<Expense>> {
  final HiveService _hiveService;

  TransactionNotifier(this._hiveService) : super([]) {
    _loadTransactions();
  }


  Future<void> _loadTransactions() async {
    try {
      final saved = await _hiveService.getAllExpenses();
      if (saved.isEmpty) {

        state = _mockTransactions;
        await _saveAllToHive();
      } else {
        state = saved;
      }
    } catch (e) {

      state = _mockTransactions;
    }
  }


  Future<void> _saveAllToHive() async {
    for (var expense in state) {
      await _hiveService.addExpense(expense);
    }
  }


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

  Future<void> addTransaction(Expense expense) async {
    state = [expense, ...state];
    await _hiveService.addExpense(expense);
  }

  Future<void> deleteTransaction(String id) async {
    state = state.where((e) => e.id != id).toList();
    await _hiveService.deleteExpense(id);
  }
}