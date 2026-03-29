import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../widgets/expense_chart.dart'; // Import the chart widget

class DashboardScreen extends StatelessWidget {
  final List<Transaction> transactions;
  final double dailyLimit;

  const DashboardScreen(this.transactions, this.dailyLimit, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Map<DateTime, double> dailyExpenses = {};

    for (var tx in transactions) {
      final date = DateTime(tx.date.year, tx.date.month, tx.date.day);
      dailyExpenses.update(date, (value) => value + tx.amount, ifAbsent: () => tx.amount);
    }

    final entries = dailyExpenses.entries.toList()..sort((a, b) => b.key.compareTo(a.key)); // Sorted by latest date

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: SafeArea(
        child: transactions.isEmpty
            ? const Center(child: Text('No transactions yet!'))
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: ExpenseChart(transactions: transactions.map((tx) {
                      return {"date": tx.date, "amount": tx.amount};
                    }).toList()), // Pass transactions to ExpenseChart
                  ),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.all(10),
                      itemCount: entries.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (context, index) {
                        final entry = entries[index];
                        final isOverLimit = entry.value > dailyLimit;

                        return ListTile(
                          title: Text('${entry.key.day}/${entry.key.month}/${entry.key.year}'),
                          subtitle: Text('₹${entry.value.toStringAsFixed(2)}'),
                          trailing: Icon(
                            isOverLimit ? Icons.warning_amber_rounded : Icons.check_circle,
                            color: isOverLimit ? Colors.red : Colors.green,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
