import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:spend_pilot/core/constants/colors.dart';
import 'package:spend_pilot/data/providers/analytics_provider.dart';

class LineChartWidget extends StatelessWidget {
  final List<TrendData> data;
  final String title;
  final Color lineColor;

  const LineChartWidget({
    super.key,
    required this.data,
    required this.title,
    required this.lineColor,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(
        child: Text('No data available'),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(show: true),
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
              minY: 0,
              maxY: _getMaxY(),
              lineBarsData: [
                LineChartBarData(
                  spots: _getSpots(),
                  isCurved: true,
                  color: lineColor,
                  barWidth: 3,
                  dotData: const FlDotData(show: true),
                  belowBarData: BarAreaData(
                    show: true,
                    color: lineColor.withValues(alpha: 0.1),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<FlSpot> _getSpots() {
    return data.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.amount);
    }).toList();
  }

  double _getMaxY() {
    double maxValue = 0;
    for (final data in data) {
      if (data.amount > maxValue) maxValue = data.amount;
    }
    return maxValue * 1.1;
  }

  Widget _getBottomTitles(double value, TitleMeta meta) {
    if (value.toInt() >= data.length) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        data[value.toInt()].label,
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