import 'package:flutter/material.dart';

class ChartBar extends StatelessWidget {
  final String label;
  final double spendAmount;
  final double percentage;
  final double dailyLimit;

  const ChartBar({
    required this.label,
    required this.spendAmount,
    required this.percentage,
    required this.dailyLimit,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isOverLimit = spendAmount > dailyLimit; // Check if over limit

    return Column(
      children: [
        SizedBox(
          height: 20,
          child: FittedBox(
            child: Text('₹${spendAmount.toStringAsFixed(2)}'), // Fixed currency symbol
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          height: 60,
          width: 10,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Container(
                height: 60,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              FractionallySizedBox(
                heightFactor: percentage.clamp(0.0, 1.0), // Ensure percentage is between 0-1
                child: Container(
                  decoration: BoxDecoration(
                    color: isOverLimit ? Colors.red : Colors.green,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(label),
      ],
    );
  }
}
