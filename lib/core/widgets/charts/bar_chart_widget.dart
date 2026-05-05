import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:spend_pilot/core/constants/colors.dart';
import 'package:spend_pilot/data/providers/analytics_provider.dart';

class BarChartWidget extends StatelessWidget {
  final List<MonthlyData> data;

  const BarChartWidget({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(
        child: Text('No data available'),
      );
    }

    return SizedBox(
      height: 250,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: _getMaxY(),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: _getBottomTitles,
                reservedSize: 30,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 50,
                getTitlesWidget: _getLeftTitles,
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: true),
          barGroups: _buildBarGroups(),
        ),
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups() {
    return data.asMap().entries.map((entry) {
      final index = entry.key;
      final monthlyData = entry.value;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: monthlyData.income,
            color: AppColors.success,
            width: 12,
            borderRadius: BorderRadius.circular(4),
          ),
          BarChartRodData(
            toY: monthlyData.expense,
            color: AppColors.error,
            width: 12,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
        barsSpace: 8,
      );
    }).toList();
  }

  double _getMaxY() {
    double maxValue = 0;
    for (final data in data) {
      if (data.income > maxValue) maxValue = data.income;
      if (data.expense > maxValue) maxValue = data.expense;
    }
    return maxValue * 1.1;
  }

  Widget _getBottomTitles(double value, TitleMeta meta) {
    if (value.toInt() >= data.length) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        data[value.toInt()].month,
        style: const TextStyle(fontSize: 11),
      ),
    );
  }

  Widget _getLeftTitles(double value, TitleMeta meta) {
    if (value == 0) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Text(
        '\$${value.toInt()}',
        style: const TextStyle(fontSize: 11),
      ),
    );
  }
}