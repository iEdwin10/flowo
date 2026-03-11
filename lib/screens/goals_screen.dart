import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/goal_provider.dart';
import '../utils/formatters.dart';
import '../utils/haptics.dart';
import '../models/goal.dart';
import '../widgets/goal_card.dart';
import '../widgets/add_goal_sheet.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final goals = context.watch<GoalProvider>().goals;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Objectifs', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  GestureDetector(
                    onTap: () async {
                      await FlowoHaptics.light();
                      if (context.mounted) {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) => const AddGoalSheet(),
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF5B8DEF).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.add_rounded, color: Color(0xFF5B8DEF), size: 20),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: goals.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('🎯', style: TextStyle(fontSize: 56))
                              .animate()
                              .scale(begin: const Offset(0.5, 0.5), curve: Curves.elasticOut, duration: 700.ms),
                          const SizedBox(height: 16),
                          Text(
                            'Crée ton 1er objectif\n(LDDS, voyage, maison...)',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey[400], fontSize: 15, height: 1.5),
                          ).animate().fadeIn(delay: 200.ms),
                        ],
                      ),
                    )
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: goals.length,
                      itemBuilder: (ctx, i) => GoalCard(goal: goals[i])
                          .animate()
                          .fadeIn(delay: Duration(milliseconds: 60 * i))
                          .slideY(begin: 0.1),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
