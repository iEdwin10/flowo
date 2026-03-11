import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/goal_provider.dart';
import '../utils/haptics.dart';

const _emojis = ['🏠', '🏡', '✈️', '🚗', '📱', '💰', '🎓', '💍', '🌴', '🎯'];

class AddGoalSheet extends StatefulWidget {
  const AddGoalSheet({super.key});

  @override
  State<AddGoalSheet> createState() => _AddGoalSheetState();
}

class _AddGoalSheetState extends State<AddGoalSheet> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  String _selectedEmoji = '🎯';

  void _submit() async {
    final name = _nameController.text.trim();
    final amount = double.tryParse(_amountController.text.replaceAll(',', '.'));
    if (name.isEmpty || amount == null || amount <= 0) {
      await FlowoHaptics.error();
      return;
    }
    await FlowoHaptics.success();
    if (mounted) {
      await context.read<GoalProvider>().addGoal(
            name: name,
            emoji: _selectedEmoji,
            targetAmount: amount,
          );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF8F9FB),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(24, 12, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Nouvel objectif', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))
                .animate().fadeIn().slideY(begin: 0.1),
            const SizedBox(height: 20),
            const Text('Emoji', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _emojis.length,
                itemBuilder: (ctx, i) {
                  final selected = _selectedEmoji == _emojis[i];
                  return GestureDetector(
                    onTap: () async {
                      await FlowoHaptics.light();
                      setState(() => _selectedEmoji = _emojis[i]);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: selected ? const Color(0xFF5B8DEF).withOpacity(0.15) : Colors.white,
                        border: Border.all(color: selected ? const Color(0xFF5B8DEF) : Colors.grey[200]!),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(_emojis[i], style: const TextStyle(fontSize: 22)),
                    ),
                  );
                },
              ),
            ).animate().fadeIn(delay: 100.ms),
            const SizedBox(height: 16),
            const Text('Nom', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            _Field(controller: _nameController, hint: 'Ex: 1ère maison, Voyage Japon...'),
            const SizedBox(height: 16),
            const Text('Montant cible', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            _Field(controller: _amountController, hint: '10 000', isNumber: true, suffix: '€'),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: _submit,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF5B8DEF),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [BoxShadow(color: const Color(0xFF5B8DEF).withOpacity(0.4), blurRadius: 16, offset: const Offset(0, 6))],
                ),
                alignment: Alignment.center,
                child: const Text('Créer', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
              ).animate(onPlay: (c) => c.repeat(reverse: true)).shimmer(duration: 2500.ms, color: Colors.white24),
            ),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool isNumber;
  final String? suffix;
  const _Field({required this.controller, required this.hint, this.isNumber = false, this.suffix});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[300]),
          suffixText: suffix,
          suffixStyle: const TextStyle(color: Color(0xFF5B8DEF), fontWeight: FontWeight.w600),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}
