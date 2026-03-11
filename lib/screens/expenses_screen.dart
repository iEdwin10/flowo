import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import '../utils/formatters.dart';
import '../utils/categories.dart';
import '../utils/haptics.dart';
import '../models/expense.dart';
import '../widgets/add_expense_sheet.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  DateTime _selectedMonth = DateTime.now();

  void _changeMonth(int delta) async {
    await FlowoHaptics.selection();
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + delta);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();
    final expenses = provider.getByMonth(_selectedMonth.year, _selectedMonth.month)
      ..sort((a, b) => b.date.compareTo(a.date));

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Dépenses', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      _MonthButton(icon: Icons.chevron_left_rounded, onTap: () => _changeMonth(-1)),
                      const SizedBox(width: 8),
                      Text(FlowoFormatters.month(_selectedMonth),
                          style: const TextStyle(fontWeight: FontWeight.w500)),
                      const SizedBox(width: 8),
                      _MonthButton(icon: Icons.chevron_right_rounded, onTap: () => _changeMonth(1)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: expenses.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('🧾', style: TextStyle(fontSize: 48)).animate().scale(
                              begin: const Offset(0.5, 0.5), curve: Curves.elasticOut, duration: 600.ms),
                          const SizedBox(height: 16),
                          Text('Aucune dépense', style: TextStyle(color: Colors.grey[400], fontSize: 16)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: expenses.length,
                      itemBuilder: (ctx, i) => _ExpenseTile(expense: expenses[i])
                          .animate()
                          .fadeIn(delay: Duration(milliseconds: 40 * i))
                          .slideX(begin: 0.05),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await FlowoHaptics.medium();
          if (context.mounted) {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => const AddExpenseSheet(),
            );
          }
        },
        backgroundColor: const Color(0xFF5B8DEF),
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }
}

class _MonthButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _MonthButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: Colors.grey[600]),
      ),
    );
  }
}

class _ExpenseTile extends StatelessWidget {
  final Expense expense;
  const _ExpenseTile({required this.expense});

  @override
  Widget build(BuildContext context) {
    final cat = FlowoCategories.findByName(expense.category);
    return Dismissible(
      key: Key(expense.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.red[50],
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.red),
      ),
      onDismissed: (_) async {
        await FlowoHaptics.medium();
        context.read<ExpenseProvider>().deleteExpense(expense.id);
      },
      confirmDismiss: (_) async {
        await FlowoHaptics.light();
        return true;
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12)],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: (cat?.color ?? Colors.grey).withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(cat?.emoji ?? '📦', style: const TextStyle(fontSize: 20)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(expense.subCategory, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                  Text(FlowoFormatters.shortDate(expense.date),
                      style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                ],
              ),
            ),
            Text(FlowoFormatters.currency(expense.amount),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          ],
        ),
      ),
    );
  }
}
