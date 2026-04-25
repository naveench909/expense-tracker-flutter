class ExpenseTransaction {
  final int? id;
  final double amount;
  final String merchant;
  final DateTime date;
  final String categoryId;
  final String paymentMethod;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  ExpenseTransaction({
    this.id,
    required this.amount,
    required this.merchant,
    required this.date,
    required this.categoryId,
    required this.paymentMethod,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'merchant': merchant,
      'date': date.toIso8601String(),
      'category_id': categoryId,
      'payment_method': paymentMethod,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory ExpenseTransaction.fromMap(Map<String, dynamic> map) {
    return ExpenseTransaction(
      id: map['id'] as int?,
      amount: (map['amount'] as num).toDouble(),
      merchant: map['merchant'] as String,
      date: DateTime.parse(map['date'] as String),
      categoryId: map['category_id'] as String,
      paymentMethod: map['payment_method'] as String,
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  ExpenseTransaction copyWith({
    int? id,
    double? amount,
    String? merchant,
    DateTime? date,
    String? categoryId,
    String? paymentMethod,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ExpenseTransaction(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      merchant: merchant ?? this.merchant,
      date: date ?? this.date,
      categoryId: categoryId ?? this.categoryId,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
