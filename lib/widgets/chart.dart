import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'chart_bar.dart';
import '../models/transaction.dart';

class Chart extends StatelessWidget {
  final List<Transaction> weeklyTransaction;
  final double dailyLimit;

  const Chart(this.weeklyTransaction, this.dailyLimit, {Key? key}) : super(key: key);

  List<Map<String, Object>> get groupedTransactionValues {
    DateTime now = DateTime.now();
    DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1)); // ✅ Fixed: Ensures Monday as start

    return List.generate(7, (index) {
      final currentDay = startOfWeek.add(Duration(days: index));
      double totalSum = 0.0;

      for (var tx in weeklyTransaction) {
        if (tx.date.year == currentDay.year &&
            tx.date.month == currentDay.month &&
            tx.date.day == currentDay.day) {
          totalSum += tx.amount;
        }
      }

      return {
        'day': DateFormat.E().format(currentDay).substring(0, 2),
        'amount': totalSum,
      };
    });
  }

  double get totalSpendings {
    return groupedTransactionValues.fold(0.0, (sum, item) => sum + (item['amount'] as double));
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      margin: const EdgeInsets.all(20),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: groupedTransactionValues.map((data) {
            double spendingAmount = data['amount'] as double;
            double spendingPct = dailyLimit > 0.0 ? (spendingAmount / dailyLimit).clamp(0.0, 1.0) : 0.0; // ✅ Improved readability

            return Flexible(
              fit: FlexFit.tight,
              child: ChartBar(
                label: data['day'] as String,
                spendAmount: spendingAmount,
                percentage: spendingPct,
                dailyLimit: dailyLimit,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
