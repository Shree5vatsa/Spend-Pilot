import 'package:flutter/material.dart';
import 'package:spend_pilot/core/constants/colors.dart';

class ExpenseCategory {
  final String id;
  final String name;
  final String icon;
  final Color color;

  const ExpenseCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });

  static const List<ExpenseCategory> all = [
    ExpenseCategory(
      id: 'food',
      name: 'Food',
      icon: '🍔',
      color: Color(0xFF8B2C2C), // Deep red
    ),
    ExpenseCategory(
      id: 'transport',
      name: 'Transport',
      icon: '🚗',
      color: Color(0xFFB33A3A), // Medium red
    ),
    ExpenseCategory(
      id: 'shopping',
      name: 'Shopping',
      icon: '🛍️',
      color: Color(0xFFCD5C5C), // Light red
    ),
    ExpenseCategory(
      id: 'bills',
      name: 'Bills',
      icon: '📄',
      color: Color(0xFFA0522D), // Brown-red
    ),
    ExpenseCategory(
      id: 'entertainment',
      name: 'Entertainment',
      icon: '🎬',
      color: Color(0xFFD2691E), // Orange-red
    ),
    ExpenseCategory(
      id: 'healthcare',
      name: 'Healthcare',
      icon: '🏥',
      color: Color(0xFFE57373), // Soft red
    ),
    ExpenseCategory(
      id: 'education',
      name: 'Education',
      icon: '📚',
      color: Color(0xFFC0392B), // Rich red
    ),
    ExpenseCategory(
      id: 'other',
      name: 'Other',
      icon: '📌',
      color: Color(0xFFA08080), // Muted red
    ),
  ];

  static ExpenseCategory? fromId(String id) {
    try {
      return all.firstWhere((cat) => cat.id == id);
    } catch (e) {
      return null;
    }
  }
}

class IncomeCategory {
  final String id;
  final String name;
  final String icon;
  final Color color;

  const IncomeCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });

  static const List<IncomeCategory> all = [
    IncomeCategory(
      id: 'salary',
      name: 'Salary',
      icon: '💼',
      color: Color(0xFF1B5E20), // Dark green (highest importance)
    ),
    IncomeCategory(
      id: 'bonus',
      name: 'Bonus',
      icon: '🏆',
      color: Color(0xFF2E7D32), // Rich green
    ),
    IncomeCategory(
      id: 'freelance',
      name: 'Freelance',
      icon: '💻',
      color: Color(0xFF388E3C), // Medium green
    ),
    IncomeCategory(
      id: 'rental',
      name: 'Rental',
      icon: '🏠',
      color: Color(0xFF4CAF50), // Soft green
    ),
    IncomeCategory(
      id: 'investment',
      name: 'Investment',
      icon: '📈',
      color: Color(0xFF66BB6A), // Light green
    ),
    IncomeCategory(
      id: 'gift',
      name: 'Gift',
      icon: '🎁',
      color: Color(0xFF81C784), // Pale green
    ),
    IncomeCategory(
      id: 'refund',
      name: 'Refund',
      icon: '💰',
      color: Color(0xFFA5D6A7), // Mint green
    ),
    IncomeCategory(
      id: 'other_income',
      name: 'Other',
      icon: '📌',
      color: Color(0xFF9E9E9E), // Gray-green
    ),
  ];

  static IncomeCategory? fromId(String id) {
    try {
      return all.firstWhere((cat) => cat.id == id);
    } catch (e) {
      return null;
    }
  }
}