import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/goal.dart';

class GoalProvider extends ChangeNotifier {
  List<Goal> _goals = [];
  static const _key = 'flowo_goals';
  final _uuid = const Uuid();

  List<Goal> get goals => List.unmodifiable(_goals);

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_key) ?? [];
    _goals = data.map((g) => Goal.fromJson(g)).toList();
    notifyListeners();
  }

  Future<void> addGoal({
    required String name,
    required String emoji,
    required double targetAmount,
    DateTime? targetDate,
  }) async {
    _goals.add(Goal(
      id: _uuid.v4(),
      name: name,
      emoji: emoji,
      targetAmount: targetAmount,
      createdAt: DateTime.now(),
      targetDate: targetDate,
    ));
    await _save();
    notifyListeners();
  }

  Future<void> addSaving(String id, double amount) async {
    final idx = _goals.indexWhere((g) => g.id == id);
    if (idx != -1) {
      _goals[idx].savedAmount += amount;
      await _save();
      notifyListeners();
    }
  }

  Future<void> deleteGoal(String id) async {
    _goals.removeWhere((g) => g.id == id);
    await _save();
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, _goals.map((g) => g.toJson()).toList());
  }
}
