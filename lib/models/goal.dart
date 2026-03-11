import 'dart:convert';

class Goal {
  final String id;
  final String name;
  final String emoji;
  final double targetAmount;
  double savedAmount;
  final DateTime createdAt;
  final DateTime? targetDate;

  Goal({
    required this.id,
    required this.name,
    required this.emoji,
    required this.targetAmount,
    this.savedAmount = 0,
    required this.createdAt,
    this.targetDate,
  });

  double get progress => (savedAmount / targetAmount).clamp(0.0, 1.0);
  double get remaining => (targetAmount - savedAmount).clamp(0, double.infinity);

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'emoji': emoji,
        'targetAmount': targetAmount,
        'savedAmount': savedAmount,
        'createdAt': createdAt.toIso8601String(),
        'targetDate': targetDate?.toIso8601String(),
      };

  factory Goal.fromMap(Map<String, dynamic> map) => Goal(
        id: map['id'],
        name: map['name'],
        emoji: map['emoji'],
        targetAmount: map['targetAmount'].toDouble(),
        savedAmount: map['savedAmount'].toDouble(),
        createdAt: DateTime.parse(map['createdAt']),
        targetDate: map['targetDate'] != null ? DateTime.parse(map['targetDate']) : null,
      );

  String toJson() => json.encode(toMap());
  factory Goal.fromJson(String source) => Goal.fromMap(json.decode(source));
}
