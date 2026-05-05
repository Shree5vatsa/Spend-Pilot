import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:spend_pilot/core/constants/colors.dart';
import 'package:spend_pilot/core/constants/categories.dart';

class PieChartWidget extends StatelessWidget {
  final Map<String, double> data;
  final double total;

  const PieChartWidget({
    super.key,
    required this.data,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(
        child: Text('No expense data for this period'),
      );
    }

    final List<MapEntry<String, double>> entries = data.entries.toList();
    entries.sort((a, b) => b.value.compareTo(a.value));

    return Column(
      children: [
        SizedBox(
          height: 250,
          child: PieChart(
            PieChartData(
              sections: _buildSections(entries),
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              startDegreeOffset: -90,
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildLegend(entries),
      ],
    );
  }

  List<PieChartSectionData> _buildSections(List<MapEntry<String, double>> entries) {
    return entries.map((entry) {
      final categoryColor = _getCategoryColor(entry.key);
      final percentage = (entry.value / total) * 100;

      return PieChartSectionData(
        value: entry.value,
        title: '${percentage.toStringAsFixed(0)}%',
        radius: 100,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        color: categoryColor,
      );
    }).toList();
  }

  Widget _buildLegend(List<MapEntry<String, double>> entries) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: entries.map((entry) {
        final categoryColor = _getCategoryColor(entry.key);
        final categoryName = _getCategoryName(entry.key);

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: categoryColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '$categoryName: \$${entry.value.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        );
      }).toList(),
    );
  }

  Color _getCategoryColor(String categoryId) {
    final category = ExpenseCategory.fromId(categoryId);
    return category?.color ?? AppColors.textSecondary;
  }

  String _getCategoryName(String categoryId) {
    final category = ExpenseCategory.fromId(categoryId);
    return category?.name ?? 'Other';
  }
}