import 'dart:convert';

class Budget {
  final double monthlyIncome;
  final Map<String, double> categoryLimits;
  final double monthlySavingsGoal;

  Budget({
    required this.monthlyIncome,
    required this.categoryLimits,
    required this.monthlySavingsGoal,
  });

  Map<String, dynamic> toMap() => {
        'monthlyIncome': monthlyIncome,
        'categoryLimits': categoryLimits,
        'monthlySavingsGoal': monthlySavingsGoal,
      };

  factory Budget.fromMap(Map<String, dynamic> map) => Budget(
        monthlyIncome: map['monthlyIncome'].toDouble(),
        categoryLimits: Map<String, double>.from(
          map['categoryLimits'].map((k, v) => MapEntry(k, v.toDouble())),
        ),
        monthlySavingsGoal: map['monthlySavingsGoal'].toDouble(),
      );

  String toJson() => json.encode(toMap());
  factory Budget.fromJson(String source) => Budget.fromMap(json.decode(source));
}
