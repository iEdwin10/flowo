import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/expense.dart';

class ExpenseProvider extends ChangeNotifier {
  List<Expense> _expenses = [];
  static const _key = 'flowo_expenses';
  final _uuid = const Uuid();

  List<Expense> get expenses => List.unmodifiable(_expenses);

  List<Expense> getByMonth(int year, int month) => _expenses
      .where((e) => e.date.year == year && e.date.month == month)
      .toList();

  List<Expense> getByYear(int year) =>
      _expenses.where((e) => e.date.year == year).toList();

  Map<String, double> getCategoryTotals(int year, int month) {
    final monthly = getByMonth(year, month);
    final Map<String, double> totals = {};
    for (var e in monthly) {
      totals[e.category] = (totals[e.category] ?? 0) + e.amount;
    }
    return totals;
  }

  double getTotalSpent(int year, int month) {
    return getByMonth(year, month).fold(0, (sum, e) => sum + e.amount);
  }

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_key) ?? [];
    _expenses = data.map((e) => Expense.fromJson(e)).toList();
    notifyListeners();
  }

  Future<void> addExpense({
    required String category,
    required String subCategory,
    required double amount,
    required DateTime date,
    String? note,
  }) async {
    final expense = Expense(
      id: _uuid.v4(),
      category: category,
      subCategory: subCategory,
      amount: amount,
      date: date,
      note: note,
    );
    _expenses.add(expense);
    await _save();
    notifyListeners();
  }

  Future<void> updateExpense(Expense updated) async {
    final idx = _expenses.indexWhere((e) => e.id == updated.id);
    if (idx != -1) {
      _expenses[idx] = updated;
      await _save();
      notifyListeners();
    }
  }

  Future<void> deleteExpense(String id) async {
    _expenses.removeWhere((e) => e.id == id);
    await _save();
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, _expenses.map((e) => e.toJson()).toList());
  }
}
