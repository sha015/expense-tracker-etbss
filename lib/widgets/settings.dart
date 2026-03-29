import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  final double initialDailyLimit;
  final double initialMonthlyLimit;
  final Function(double, double) onLimitChanged;

  const SettingsScreen({
    required this.onLimitChanged,
    required this.initialDailyLimit,
    required this.initialMonthlyLimit,
    Key? key,
  }) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _dailyLimitController;
  late TextEditingController _monthlyLimitController;

  @override
  void initState() {
    super.initState();
    _dailyLimitController = TextEditingController(text: widget.initialDailyLimit.toString());
    _monthlyLimitController = TextEditingController(text: widget.initialMonthlyLimit.toString());
  }

  @override
  void dispose() {
    _dailyLimitController.dispose();
    _monthlyLimitController.dispose();
    super.dispose();
  }

  void _saveLimits() {
    double dailyLimit = double.tryParse(_dailyLimitController.text) ?? widget.initialDailyLimit;
    double monthlyLimit = double.tryParse(_monthlyLimitController.text) ?? widget.initialMonthlyLimit;

    if (dailyLimit > 0 && monthlyLimit > 0) {
      widget.onLimitChanged(dailyLimit, monthlyLimit);
      Navigator.pop(context);
    } else {
      _showError();
    }
  }

  void _showError() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Invalid Input'),
        content: const Text('Limits must be positive numbers.'),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK'))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Bug Report'),
            const Text('If you found any bug or glitch, send a screenshot to:'),
            const SelectableText('📧 etbss200@gmail.com', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
            const Divider(height: 30),

            _buildSectionTitle('Set Expense Limits'),
            _buildInputField(_dailyLimitController, 'Daily Limit'),
            _buildInputField(_monthlyLimitController, 'Monthly Limit'),
            const SizedBox(height: 16),

            Center(
              child: ElevatedButton.icon(
                onPressed: _saveLimits,
                icon: const Icon(Icons.save),
                label: const Text('Save Limits'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
  );

  Widget _buildInputField(TextEditingController controller, String label) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(labelText: label, border: OutlineInputBorder()),
    ),
  );
}
