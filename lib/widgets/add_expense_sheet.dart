import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import '../utils/categories.dart';
import '../utils/haptics.dart';

class AddExpenseSheet extends StatefulWidget {
  const AddExpenseSheet({super.key});

  @override
  State<AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends State<AddExpenseSheet> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  FlowoCategory? _selectedCategory;
  String? _selectedSub;
  DateTime _date = DateTime.now();

  void _submit() async {
    final amount = double.tryParse(_amountController.text.replaceAll(',', '.'));
    if (amount == null || amount <= 0 || _selectedCategory == null || _selectedSub == null) {
      await FlowoHaptics.error();
      return;
    }
    await FlowoHaptics.success();
    if (mounted) {
      await context.read<ExpenseProvider>().addExpense(
            category: _selectedCategory!.name,
            subCategory: _selectedSub!,
            amount: amount,
            date: _date,
            note: _noteController.text.isEmpty ? null : _noteController.text,
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
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Nouvelle dépense', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))
                .animate().fadeIn().slideY(begin: 0.1),
            const SizedBox(height: 20),
            // Montant
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12)],
              ),
              child: TextField(
                controller: _amountController,
                autofocus: true,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  hintText: '0',
                  hintStyle: TextStyle(color: Colors.grey[200], fontWeight: FontWeight.bold, fontSize: 28),
                  suffixText: '€',
                  suffixStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500, color: Color(0xFF5B8DEF)),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
              ),
            ).animate().fadeIn(delay: 100.ms),
            const SizedBox(height: 20),
            // Categories
            const Text('Catégorie', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: FlowoCategories.all.length,
                itemBuilder: (ctx, i) {
                  final cat = FlowoCategories.all[i];
                  final selected = _selectedCategory?.name == cat.name;
                  return GestureDetector(
                    onTap: () async {
                      await FlowoHaptics.light();
                      setState(() {
                        _selectedCategory = cat;
                        _selectedSub = null;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOutCubic,
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: selected ? cat.color : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: selected
                            ? [BoxShadow(color: cat.color.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4))]
                            : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(cat.emoji, style: const TextStyle(fontSize: 22)),
                          const SizedBox(height: 4),
                          Text(
                            cat.name,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: selected ? Colors.white : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ).animate().fadeIn(delay: 150.ms),
            if (_selectedCategory != null) ...
              [
                const SizedBox(height: 16),
                const Text('Sous-catégorie', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _selectedCategory!.subCategories.map((sub) {
                    final selected = _selectedSub == sub;
                    return GestureDetector(
                      onTap: () async {
                        await FlowoHaptics.light();
                        setState(() => _selectedSub = sub);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: selected ? _selectedCategory!.color.withOpacity(0.15) : Colors.white,
                          border: Border.all(
                            color: selected ? _selectedCategory!.color : Colors.grey[200]!,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          sub,
                          style: TextStyle(
                            fontSize: 13,
                            color: selected ? _selectedCategory!.color : Colors.grey[600],
                            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ).animate().fadeIn(),
              ],
            const SizedBox(height: 24),
            GestureDetector(
              onTap: _submit,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF5B8DEF),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF5B8DEF).withOpacity(0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    )
                  ],
                ),
                alignment: Alignment.center,
                child: const Text('Ajouter', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
              ).animate(onPlay: (c) => c.repeat(reverse: true)).shimmer(duration: 2500.ms, color: Colors.white24),
            ),
          ],
        ),
      ),
    );
  }
}
