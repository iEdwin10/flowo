import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/budget.dart';
import '../utils/categories.dart';

class BudgetProvider extends ChangeNotifier {
  Budget? _budget;
  static const _key = 'flowo_budget';

  Budget? get budget => _budget;
  bool get isSetup => _budget != null;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_key);
    if (data != null) {
      _budget = Budget.fromJson(data);
    }
    notifyListeners();
  }

  Future<void> setupBudget({
    required double monthlyIncome,
    required double monthlySavingsGoal,
    Map<String, double>? categoryLimits,
  }) async {
    final limits = categoryLimits ??
        {for (var c in FlowoCategories.all) c.name: monthlyIncome / FlowoCategories.all.length};
    _budget = Budget(
      monthlyIncome: monthlyIncome,
      categoryLimits: limits,
      monthlySavingsGoal: monthlySavingsGoal,
    );
    await _save();
    notifyListeners();
  }

  Future<void> updateLimit(String category, double limit) async {
    if (_budget == null) return;
    final newLimits = Map<String, double>.from(_budget!.categoryLimits);
    newLimits[category] = limit;
    _budget = Budget(
      monthlyIncome: _budget!.monthlyIncome,
      categoryLimits: newLimits,
      monthlySavingsGoal: _budget!.monthlySavingsGoal,
    );
    await _save();
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, _budget!.toJson());
  }
}
