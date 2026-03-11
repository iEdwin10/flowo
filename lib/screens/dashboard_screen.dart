import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/budget_provider.dart';
import '../providers/expense_provider.dart';
import '../providers/goal_provider.dart';
import '../utils/formatters.dart';
import '../utils/categories.dart';
import '../utils/haptics.dart';
import '../widgets/add_expense_sheet.dart';
import '../widgets/goal_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final budget = context.watch<BudgetProvider>().budget!;
    final expenseProvider = context.watch<ExpenseProvider>();
    final goals = context.watch<GoalProvider>().goals;
    final spent = expenseProvider.getTotalSpent(now.year, now.month);
    final remaining = budget.monthlyIncome - spent;
    final categoryTotals = expenseProvider.getCategoryTotals(now.year, now.month);

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: false,
            floating: true,
            expandedHeight: 0,
            flexibleSpace: const FlexibleSpaceBar(),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  FlowoFormatters.month(now),
                  style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500),
                ),
                const Text('Tableau de bord', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 8),
                _BalanceCard(spent: spent, remaining: remaining, income: budget.monthlyIncome),
                const SizedBox(height: 20),
                _DonutChart(categoryTotals: categoryTotals, total: spent),
                const SizedBox(height: 20),
                _CategoryBreakdown(categoryTotals: categoryTotals, limits: budget.categoryLimits),
                if (goals.isNotEmpty) ...
                  [
                    const SizedBox(height: 20),
                    const Text('Objectifs', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    ...goals.take(2).map((g) => GoalCard(goal: g)),
                  ],
                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
      floatingActionButton: _AddButton(),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  final double spent, remaining, income;
  const _BalanceCard({required this.spent, required this.remaining, required this.income});

  @override
  Widget build(BuildContext context) {
    final pct = (spent / income).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF5B8DEF), Color(0xFF7C6EF8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5B8DEF).withOpacity(0.4),
            blurRadius: 24,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Disponible ce mois', style: TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 6),
          Text(
            FlowoFormatters.currency(remaining),
            style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
          ).animate().fadeIn().slideY(begin: 0.3),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 6,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation(Colors.white),
            ),
          ).animate().scaleX(begin: 0, curve: Curves.easeOutCubic, duration: 800.ms),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Dépensé : ${FlowoFormatters.currency(spent)}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
              Text('Budget : ${FlowoFormatters.currency(income)}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1);
  }
}

class _DonutChart extends StatefulWidget {
  final Map<String, double> categoryTotals;
  final double total;
  const _DonutChart({required this.categoryTotals, required this.total});

  @override
  State<_DonutChart> createState() => _DonutChartState();
}

class _DonutChartState extends State<_DonutChart> {
  int _touched = -1;

  @override
  Widget build(BuildContext context) {
    if (widget.categoryTotals.isEmpty) {
      return Container(
        height: 220,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 16)],
        ),
        child: Text('Aucune dépense ce mois', style: TextStyle(color: Colors.grey[400])),
      );
    }

    final sections = widget.categoryTotals.entries.map((entry) {
      final cat = FlowoCategories.findByName(entry.key);
      final idx = widget.categoryTotals.keys.toList().indexOf(entry.key);
      final isTouched = idx == _touched;
      return PieChartSectionData(
        value: entry.value,
        color: cat?.color ?? Colors.grey,
        radius: isTouched ? 56 : 48,
        title: isTouched ? FlowoFormatters.currencyCompact(entry.value) : '',
        titleStyle: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600),
      );
    }).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 16)],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Répartition', style: TextStyle(fontWeight: FontWeight.w600)),
              Text(FlowoFormatters.currency(widget.total), style: TextStyle(color: Colors.grey[500], fontSize: 13)),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: PieChart(
              PieChartData(
                sections: sections,
                centerSpaceRadius: 50,
                pieTouchData: PieTouchData(
                  touchCallback: (event, response) async {
                    if (response?.touchedSection != null) {
                      await FlowoHaptics.selection();
                      setState(() => _touched = response!.touchedSection!.touchedSectionIndex);
                    } else {
                      setState(() => _touched = -1);
                    }
                  },
                ),
                sectionsSpace: 3,
              ),
              swapAnimationDuration: const Duration(milliseconds: 400),
              swapAnimationCurve: Curves.easeOutCubic,
            ).animate().scale(begin: const Offset(0.7, 0.7), curve: Curves.elasticOut, duration: 700.ms),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1);
  }
}

class _CategoryBreakdown extends StatelessWidget {
  final Map<String, double> categoryTotals;
  final Map<String, double> limits;
  const _CategoryBreakdown({required this.categoryTotals, required this.limits});

  @override
  Widget build(BuildContext context) {
    if (categoryTotals.isEmpty) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Par catégorie', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...categoryTotals.entries.mapIndexed((idx, entry) {
          final cat = FlowoCategories.findByName(entry.key);
          final limit = limits[entry.key] ?? double.infinity;
          final pct = (entry.value / limit).clamp(0.0, 1.0);
          final isOver = entry.value > limit;
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12)],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(cat?.emoji ?? '📦', style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 12),
                    Expanded(child: Text(entry.key, style: const TextStyle(fontWeight: FontWeight.w600))),
                    Text(
                      FlowoFormatters.currency(entry.value),
                      style: TextStyle(color: isOver ? Colors.red : Colors.grey[600], fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: pct,
                    minHeight: 5,
                    backgroundColor: Colors.grey[100],
                    valueColor: AlwaysStoppedAnimation(isOver ? Colors.red : cat?.color ?? Colors.blue),
                  ),
                ).animate().scaleX(begin: 0, delay: Duration(milliseconds: 100 * idx), curve: Curves.easeOutCubic),
              ],
            ),
          ).animate().fadeIn(delay: Duration(milliseconds: 80 * idx)).slideX(begin: 0.1);
        }),
      ],
    );
  }
}

extension IndexedIterable<E> on Iterable<E> {
  Iterable<T> mapIndexed<T>(T Function(int index, E element) f) {
    var i = 0;
    return map((e) => f(i++, e));
  }
}

class _AddButton extends StatefulWidget {
  @override
  State<_AddButton> createState() => _AddButtonState();
}

class _AddButtonState extends State<_AddButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 150));
    _scaleAnim = Tween<double>(begin: 1, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTap() async {
    await _controller.forward();
    await _controller.reverse();
    await FlowoHaptics.medium();
    if (mounted) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => const AddExpenseSheet(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: const Color(0xFF5B8DEF),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF5B8DEF).withOpacity(0.45),
                blurRadius: 18,
                offset: const Offset(0, 6),
              )
            ],
          ),
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
        ),
      ),
    ).animate().scale(begin: const Offset(0, 0), delay: 500.ms, curve: Curves.elasticOut);
  }
}
