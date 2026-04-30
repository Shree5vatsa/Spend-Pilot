import 'package:hive_flutter/hive_flutter.dart';
import 'package:spend_pilot/shared/models/expense.dart';

class HiveService {
  static final HiveService _instance = HiveService._internal();
  static HiveService get instance => _instance;

  HiveService._internal();

  late Box<Expense> _expensesBox;
  bool _isInitialized = false;

  static const String _expensesBoxName = 'expenses_box';

  Future<void> init() async {
    if (_isInitialized) return;

    await Hive.initFlutter();
    Hive.registerAdapter(ExpenseAdapter());
    _expensesBox = await Hive.openBox<Expense>(_expensesBoxName);
    _isInitialized = true;
  }

  List<Expense> getAllExpenses() {
    if (!_isInitialized) {
      throw Exception('HiveService not initialized. Call init() first.');
    }
    return _expensesBox.values.toList();
  }

  Future<void> addExpense(Expense expense) async {
    if (!_isInitialized) {
      throw Exception('HiveService not initialized. Call init() first.');
    }
    await _expensesBox.put(expense.id, expense);
  }

  Future<void> deleteExpense(String id) async {
    if (!_isInitialized) {
      throw Exception('HiveService not initialized. Call init() first.');
    }
    await _expensesBox.delete(id);
  }

  Future<void> clearAllExpenses() async {
    if (!_isInitialized) {
      throw Exception('HiveService not initialized. Call init() first.');
    }
    await _expensesBox.clear();
  }
}