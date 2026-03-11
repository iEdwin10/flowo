import 'dart:convert';

class Expense {
  final String id;
  final String category;
  final String subCategory;
  final double amount;
  final DateTime date;
  final String? note;

  Expense({
    required this.id,
    required this.category,
    required this.subCategory,
    required this.amount,
    required this.date,
    this.note,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'category': category,
        'subCategory': subCategory,
        'amount': amount,
        'date': date.toIso8601String(),
        'note': note,
      };

  factory Expense.fromMap(Map<String, dynamic> map) => Expense(
        id: map['id'],
        category: map['category'],
        subCategory: map['subCategory'],
        amount: map['amount'].toDouble(),
        date: DateTime.parse(map['date']),
        note: map['note'],
      );

  String toJson() => json.encode(toMap());
  factory Expense.fromJson(String source) => Expense.fromMap(json.decode(source));

  Expense copyWith({
    String? id,
    String? category,
    String? subCategory,
    double? amount,
    DateTime? date,
    String? note,
  }) =>
      Expense(
        id: id ?? this.id,
        category: category ?? this.category,
        subCategory: subCategory ?? this.subCategory,
        amount: amount ?? this.amount,
        date: date ?? this.date,
        note: note ?? this.note,
      );
}
