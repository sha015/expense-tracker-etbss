import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ExpenseChart extends StatelessWidget {
  final List<Map<String, dynamic>> transactions;

  const ExpenseChart({required this.transactions, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<FlSpot> dataPoints = transactions
        .asMap()
        .entries
        .map((entry) => FlSpot(entry.key.toDouble(), (entry.value['amount'] as num).toDouble()))
        .toList();

    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          titlesData: const FlTitlesData(show: false), 
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: dataPoints,
              isCurved: true,
              barWidth: 3,
              gradient: const LinearGradient(
                colors: [Colors.blue, Colors.green],
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: const LinearGradient(
                  colors: [Color(0x4D2196F3), Color(0x1A4CAF50)], // Using hex values instead of withOpacity()
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
