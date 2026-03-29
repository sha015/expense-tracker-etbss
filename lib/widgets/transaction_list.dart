import 'package:flutter/material.dart';
import '../widgets/transaction_items.dart';
import '../models/transaction.dart';

class TransactionList extends StatelessWidget {
  const TransactionList(this.trans, this.deleteTransaction, {Key? key}) : super(key: key);

  final List<Transaction> trans;
  final void Function(String) deleteTransaction;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        return SizedBox(
          height: constraints.maxHeight * 0.9,
          child: trans.isEmpty
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'No items added!',
                      style: Theme.of(context).textTheme.titleLarge ??
                          const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: constraints.maxHeight * 0.5,
                      child: Image.asset(
                        'assets/images/waiting.png',
                        fit: BoxFit.cover, // Better scaling
                      ),
                    ),
                  ],
                )
              : ListView.builder(
                  itemCount: trans.length,
                  itemBuilder: (context, index) {
                    return TransactionItems(
                      trans: trans[index],
                      deleteTransaction: deleteTransaction,
                    );
                  },
                ),
        );
      },
    );
  }
}
