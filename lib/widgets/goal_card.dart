import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../models/goal.dart';
import '../providers/goal_provider.dart';
import '../utils/formatters.dart';
import '../utils/haptics.dart';

class GoalCard extends StatelessWidget {
  final Goal goal;
  const GoalCard({super.key, required this.goal});

  void _addSaving(BuildContext context) async {
    final ctrl = TextEditingController();
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Ajouter à "${goal.name}"'),
        content: TextField(
          controller: ctrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(suffixText: '€', hintText: '50'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5B8DEF), foregroundColor: Colors.white),
            onPressed: () async {
              final amount = double.tryParse(ctrl.text);
              if (amount != null && amount > 0) {
                await FlowoHaptics.success();
                if (ctx.mounted) {
                  context.read<GoalProvider>().addSaving(goal.id, amount);
                  Navigator.pop(ctx);
                }
              }
            },
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pct = goal.progress;
    return GestureDetector(
      onTap: () async {
        await FlowoHaptics.light();
        _addSaving(context);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 14)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(goal.emoji, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(goal.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(
                        '${FlowoFormatters.currency(goal.savedAmount)} / ${FlowoFormatters.currency(goal.targetAmount)}',
                        style: TextStyle(color: Colors.grey[400], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF5B8DEF).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    FlowoFormatters.percent(pct),
                    style: const TextStyle(color: Color(0xFF5B8DEF), fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Stack(
              children: [
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                AnimatedFractionallySizedBox(
                  widthFactor: pct,
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.easeOutCubic,
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF5B8DEF), Color(0xFF7C6EF8)],
                      ),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF5B8DEF).withOpacity(0.4),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (goal.remaining > 0) ...
              [
                const SizedBox(height: 10),
                Text(
                  'Il te reste ${FlowoFormatters.currency(goal.remaining)} à économiser',
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
              ]
            else
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Row(
                  children: const [
                    Icon(Icons.check_circle_rounded, color: Color(0xFF51CF66), size: 16),
                    SizedBox(width: 4),
                    Text('Objectif atteint ! 🎉', style: TextStyle(color: Color(0xFF51CF66), fontWeight: FontWeight.w600, fontSize: 13)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
