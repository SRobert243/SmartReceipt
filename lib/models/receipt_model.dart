class Receipt {
  final int? id;
  final String storeName;
  final double amount;
  final String date;
  final String category;
  final String? imagePath;
  final String currency;

  Receipt({
    this.id,
    required this.storeName,
    required this.amount,
    required this.date,
    required this.category,
    this.imagePath,
    this.currency = 'RON',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'storeName': storeName,
      'amount': amount,
      'date': date,
      'category': category,
      'imagePath': imagePath,
      'currency': currency,
    };
  }

  factory Receipt.fromMap(Map<String, dynamic> map) {
    return Receipt(
      id: map['id'],
      storeName: map['storeName'],
      amount: map['amount'],
      date: map['date'],
      category: map['category'],
      imagePath: map['imagePath'],
      currency: map['currency'] ?? 'RON',
    );
  }
}