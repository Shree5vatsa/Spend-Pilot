import 'package:flutter/material.dart';
import 'package:spend_pilot/core/constants/colors.dart';
import 'package:spend_pilot/core/constants/categories.dart';
import 'package:spend_pilot/core/utils/date_formatter.dart';

class TransactionCard extends StatelessWidget {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final String category;
  final String? note;
  final bool isIncome;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const TransactionCard({
    super.key,
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    this.note,
    required this.isIncome,
    this.onTap,
    this.onLongPress,
  });

  // Helper to get category data
  String _getCategoryIcon() {
    if (isIncome) {
      final cat = IncomeCategory.fromId(category);
      return cat?.icon ?? '📌';
    } else {
      final cat = ExpenseCategory.fromId(category);
      return cat?.icon ?? '📌';
    }
  }

  String _getCategoryName() {
    if (isIncome) {
      final cat = IncomeCategory.fromId(category);
      return cat?.name ?? 'Other';
    } else {
      final cat = ExpenseCategory.fromId(category);
      return cat?.name ?? 'Other';
    }
  }

  Color _getCategoryColor() {
    if (isIncome) {
      final cat = IncomeCategory.fromId(category);
      return cat?.color ?? AppColors.textSecondary;
    } else {
      final cat = ExpenseCategory.fromId(category);
      return cat?.color ?? AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isNegative = !isIncome;
    final categoryIcon = _getCategoryIcon();
    final categoryName = _getCategoryName();
    final categoryColor = _getCategoryColor();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.border, width: 0.5),
      ),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: categoryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    categoryIcon,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormatter.formatDate(date),
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textTertiary,
                      ),
                    ),
                    if (note != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        note!,
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textTertiary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${isNegative ? '-' : '+'} \$${amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isNegative ? AppColors.error : AppColors.success,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: categoryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      categoryName,
                      style: TextStyle(
                        fontSize: 10,
                        color: categoryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}