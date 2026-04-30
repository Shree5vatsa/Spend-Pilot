import 'package:hive_flutter/hive_flutter.dart';
import 'package:spend_pilot/shared/models/expense.dart';

class HiveService {
  static const String _expensesBoxName = 'expenses_box';
  late Box<Expense> _expensesBox;

  // Initialize Hive
  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(ExpenseAdapter());
    _expensesBox = await Hive.openBox<Expense>(_expensesBoxName);
  }

  // Get all expenses
  List<Expense> getAllExpenses() {
    return _expensesBox.values.toList();
  }

  // Add an expense
  Future<void> addExpense(Expense expense) async {
    await _expensesBox.put(expense.id, expense);
  }

  // Delete an expense
  Future<void> deleteExpense(String id) async {
    await _expensesBox.delete(id);
  }

  // Clear all expenses
  Future<void> clearAllExpenses() async {
    await _expensesBox.clear();
  }
}