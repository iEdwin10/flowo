import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/expense_provider.dart';
import '../utils/formatters.dart';
import '../utils/categories.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  bool _showYear = false;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final provider = context.watch<ExpenseProvider>();

    final months = List.generate(12, (i) => DateTime(now.year, i + 1));
    final monthlyTotals = months.map((m) => provider.getTotalSpent(m.year, m.month)).toList();

    final allExpenses = _showYear
        ? provider.getByYear(now.year)
        : provider.getByMonth(now.year, now.month);
    final Map<String, double> catTotals = {};
    for (var e in allExpenses) {
      catTotals[e.category] = (catTotals[e.category] ?? 0) + e.amount;
    }

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            title: const Text('Analyse', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            floating: true,
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Row(
                  children: [
                    _ToggleChip(label: 'Ce mois', selected: !_showYear, onTap: () => setState(() => _showYear = false)),
                    const SizedBox(width: 8),
                    _ToggleChip(label: 'Cette année', selected: _showYear, onTap: () => setState(() => _showYear = true)),
                  ],
                ).animate().fadeIn(),
                const SizedBox(height: 20),
                _YearBarChart(monthlyTotals: monthlyTotals, currentMonth: now.month),
                const SizedBox(height: 24),
                const Text('Par catégorie', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                ...catTotals.entries.map((e) => _CategoryRow(name: e.key, amount: e.value, total: allExpenses.fold(0, (s, ex) => s + ex.amount))),
                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _YearBarChart extends StatelessWidget {
  final List<double> monthlyTotals;
  final int currentMonth;
  const _YearBarChart({required this.monthlyTotals, required this.currentMonth});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 16)],
      ),
      child: BarChart(
        BarChartData(
          barGroups: List.generate(12, (i) => BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: monthlyTotals[i],
                color: i + 1 == currentMonth ? const Color(0xFF5B8DEF) : const Color(0xFFDDE3EE),
                width: 16,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
              ),
            ],
          )),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, _) => Text(
                  ['J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'][v.toInt()],
                  style: TextStyle(fontSize: 10, color: Colors.grey[400]),
                ),
              ),
            ),
          ),
        ),
        swapAnimationDuration: const Duration(milliseconds: 500),
        swapAnimationCurve: Curves.easeOutCubic,
      ).animate().fadeIn(duration: 500.ms),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final String name;
  final double amount;
  final double total;
  const _CategoryRow({required this.name, required this.amount, required this.total});

  @override
  Widget build(BuildContext context) {
    final cat = FlowoCategories.findByName(name);
    final pct = total > 0 ? amount / total : 0.0;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
      ),
      child: Row(
        children: [
          Text(cat?.emoji ?? '📦', style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: pct,
                    minHeight: 4,
                    backgroundColor: Colors.grey[100],
                    valueColor: AlwaysStoppedAnimation(cat?.color ?? Colors.blue),
                  ),
                ).animate().scaleX(begin: 0, curve: Curves.easeOutCubic),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(FlowoFormatters.currency(amount), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              Text(FlowoFormatters.percent(pct), style: TextStyle(color: Colors.grey[400], fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ToggleChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _ToggleChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF5B8DEF) : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.grey[600],
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
