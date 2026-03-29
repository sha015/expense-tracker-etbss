class Transaction {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final String category; // ✅ Added category field

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category, // ✅ Add this in the constructor
  });

  // Convert Transaction to JSON (for saving)
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'amount': amount,
        'date': date.toIso8601String(),
        'category': category, // ✅ Added category in JSON
      };

  // Convert JSON to Transaction (for loading)
  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] ?? '',
      title: json['title'] ?? 'Untitled',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      category: json['category'] ?? 'Uncategorized', // ✅ Default category
    );
  }
}
