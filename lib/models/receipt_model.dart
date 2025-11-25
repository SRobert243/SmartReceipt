class Receipt {
  final int? id;
  final String storeName;
  final double amount;
  final String date;
  final String category;
  final String? imagePath;

  Receipt({
    this.id,
    required this.storeName,
    required this.amount,
    required this.date,
    required this.category,
    this.imagePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'storeName': storeName,
      'amount': amount,
      'date': date,
      'category': category,
      'imagePath': imagePath,
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
    );
  }
}