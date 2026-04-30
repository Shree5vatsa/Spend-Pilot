import 'package:flutter/material.dart';

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
      color: Color(0xFFFF6B6B),
    ),
    ExpenseCategory(
      id: 'transport',
      name: 'Transport',
      icon: '🚗',
      color: Color(0xFF4ECDC4),
    ),
    ExpenseCategory(
      id: 'shopping',
      name: 'Shopping',
      icon: '🛍️',
      color: Color(0xFF45B7D1),
    ),
    ExpenseCategory(
      id: 'bills',
      name: 'Bills',
      icon: '📄',
      color: Color(0xFF96CEB4),
    ),
    ExpenseCategory(
      id: 'entertainment',
      name: 'Entertainment',
      icon: '🎬',
      color: Color(0xFFFFEAA7),
    ),
    ExpenseCategory(
      id: 'healthcare',
      name: 'Healthcare',
      icon: '🏥',
      color: Color(0xFFDDA0DD),
    ),
    ExpenseCategory(
      id: 'education',
      name: 'Education',
      icon: '📚',
      color: Color(0xFF98D8C8),
    ),
    ExpenseCategory(
      id: 'other',
      name: 'Other',
      icon: '📌',
      color: Color(0xFFB0B0B0),
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
      color: Color(0xFF10B981),
    ),
    IncomeCategory(
      id: 'freelance',
      name: 'Freelance',
      icon: '💻',
      color: Color(0xFF3B82F6),
    ),
    IncomeCategory(
      id: 'gift',
      name: 'Gift',
      icon: '🎁',
      color: Color(0xFFF59E0B),
    ),
    IncomeCategory(
      id: 'investment',
      name: 'Investment',
      icon: '📈',
      color: Color(0xFF8B5CF6),
    ),
    IncomeCategory(
      id: 'refund',
      name: 'Refund',
      icon: '💰',
      color: Color(0xFFEC4899),
    ),
    IncomeCategory(
      id: 'bonus',
      name: 'Bonus',
      icon: '🏆',
      color: Color(0xFF14B8A6),
    ),
    IncomeCategory(
      id: 'rental',
      name: 'Rental',
      icon: '🏠',
      color: Color(0xFFF97316),
    ),
    IncomeCategory(
      id: 'other_income',
      name: 'Other',
      icon: '📌',
      color: Color(0xFF6B7280),
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