import 'package:flutter/material.dart';
import './widgets/transaction_list.dart';
import './models/transaction.dart';
import './widgets/new_transaction.dart';
import './widgets/chart.dart';
import './widgets/dashboard.dart';
import './widgets/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  bool isDarkMode = false; // Set light theme as default

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker',
      debugShowCheckedModeBanner: false,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light, // Switch the logic
      theme: ThemeData.light().copyWith(
        colorScheme: const ColorScheme.light(primary: Colors.green, secondary: Colors.amber),
        scaffoldBackgroundColor: Colors.white,
      ),
      darkTheme: ThemeData.dark().copyWith(
        colorScheme: const ColorScheme.dark(primary: Colors.green, secondary: Colors.amber),
        scaffoldBackgroundColor: Colors.black,
      ),
      home: MyHomePage(toggleTheme: () => setState(() => isDarkMode = !isDarkMode)),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final VoidCallback toggleTheme;
  const MyHomePage({required this.toggleTheme, Key? key}) : super(key: key);

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  final List<Transaction> _transactions = [];
  double _dailyExpenseLimit = 0;
  double _monthlyExpenseLimit = 0;

  @override
  void initState() {
    super.initState();
    _loadLimits();
    _loadTransactions();
  }

  // Load the daily and monthly limits from SharedPreferences
  void _loadLimits() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _dailyExpenseLimit = prefs.getDouble('dailyExpenseLimit') ?? 0.0;
      _monthlyExpenseLimit = prefs.getDouble('monthlyExpenseLimit') ?? 0.0;
    });
  }

  // Save the daily and monthly limits to SharedPreferences
  void _saveLimits() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('dailyExpenseLimit', _dailyExpenseLimit);
    await prefs.setDouble('monthlyExpenseLimit', _monthlyExpenseLimit);
  }

  // Load the saved transactions from SharedPreferences
  void _loadTransactions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> savedTransactions = prefs.getStringList('transactions') ?? [];
    setState(() {
      _transactions.clear();
      for (var tx in savedTransactions) {
        Map<String, dynamic> transactionMap = jsonDecode(tx);
        _transactions.add(Transaction(
          title: transactionMap['title'],
          amount: transactionMap['amount'],
          id: transactionMap['id'],
          date: DateTime.parse(transactionMap['date']),
          category: transactionMap['category'],
        ));
      }
    });
  }

  // Save transactions to SharedPreferences
  void _saveTransactions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> savedTransactions = _transactions.map((tx) {
      return jsonEncode({
        'title': tx.title,
        'amount': tx.amount,
        'id': tx.id,
        'date': tx.date.toIso8601String(),
        'category': tx.category,
      });
    }).toList();
    await prefs.setStringList('transactions', savedTransactions);
  }

  List<Transaction> get _monthlyTransactions {
    final now = DateTime.now();
    return _transactions.where((tx) => tx.date.month == now.month && tx.date.year == now.year).toList();
  }

  double get _totalMonthlyExpenses => _monthlyTransactions.fold(0.0, (sum, tx) => sum + tx.amount);

  void _addTransaction(String title, double amount, DateTime selectedDate, String category) {
    if (_getTotalDailyExpense(selectedDate) + amount > _dailyExpenseLimit) {
      _showLimitAlert();
      return;
    }
    setState(() {
      _transactions.add(Transaction(
        title: title,
        amount: amount,
        id: DateTime.now().toString(),
        date: selectedDate,
        category: category, // ✅ Now uses the passed category
      ));
    });
    _saveTransactions(); // Save transactions after adding a new one
  }

  double _getTotalDailyExpense(DateTime date) {
    return _transactions
        .where((tx) => tx.date.year == date.year && tx.date.month == date.month && tx.date.day == date.day)
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  void _showLimitAlert() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Daily Limit Exceeded!'),
        content: const Text('You have exceeded your daily expense limit.'),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK'))],
      ),
    );
  }

  void _deleteTransaction(String id) {
    setState(() {
      _transactions.removeWhere((tx) => tx.id == id);
    });
    _saveTransactions(); // Save transactions after deleting one
  }

  void _startAddNewTransaction(BuildContext ctx) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: ctx,
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: NewTransaction(_addTransaction, _dailyExpenseLimit),
      ),
    );
  }

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SettingsScreen(
          initialDailyLimit: _dailyExpenseLimit,
          initialMonthlyLimit: _monthlyExpenseLimit,
          onLimitChanged: (dailyLimit, monthlyLimit) {
            setState(() {
              _dailyExpenseLimit = dailyLimit;
              _monthlyExpenseLimit = monthlyLimit;
            });
            _saveLimits(); // Save the updated limits
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final appBar = AppBar(
      title: const Text('Expense Tracker'),
      actions: [
        IconButton(icon: const Icon(Icons.settings), onPressed: _openSettings),
        IconButton(
          icon: const Icon(Icons.dashboard),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DashboardScreen(_transactions, _dailyExpenseLimit)),
          ),
        ),
        IconButton(icon: const Icon(Icons.color_lens), onPressed: widget.toggleTheme),
      ],
    );

    return Scaffold(
      appBar: appBar,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: (mediaQuery.size.height - appBar.preferredSize.height - mediaQuery.padding.top) * 0.3,
              child: Chart(_monthlyTransactions, _dailyExpenseLimit),
            ),
            if (_dailyExpenseLimit > 0 || _monthlyExpenseLimit > 0)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    if (_dailyExpenseLimit > 0)
                      Text(
                        'Daily Limit: ₹${_dailyExpenseLimit.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    if (_monthlyExpenseLimit > 0)
                      Text(
                        'Monthly Limit: ₹${_monthlyExpenseLimit.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Monthly Expenses: ₹${_totalMonthlyExpenses.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(child: TransactionList(_transactions, _deleteTransaction)),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
        onPressed: () => _startAddNewTransaction(context),
      ),
    );
  }
}
