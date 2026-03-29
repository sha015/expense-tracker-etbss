import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';

class TransactionItems extends StatelessWidget {
  const TransactionItems({
    Key? key,
    required this.trans,
    required this.deleteTransaction,
  }) : super(key: key);

  final Transaction trans;
  final void Function(String) deleteTransaction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 6,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
      child: ListTile(
        leading: CircleAvatar(
          radius: 35,
          backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: FittedBox(
              child: Text(
                '₹${trans.amount.toStringAsFixed(2)}',
                style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ) ??
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
        title: Text(
          trans.title,
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold) ??
              const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          DateFormat.yMMMd().format(trans.date),
          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, size: 28), // Bigger delete button
          onPressed: () => deleteTransaction(trans.id),
          color: theme.colorScheme.error,
        ),
      ),
    );
  }
}
