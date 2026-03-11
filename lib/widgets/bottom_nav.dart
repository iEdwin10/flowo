import 'package:flutter/material.dart';
import '../utils/haptics.dart';

class FlowoBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const FlowoBottomNav({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.home_rounded, 'Accueil'),
      (Icons.receipt_long_rounded, 'Dépenses'),
      (Icons.flag_rounded, 'Objectifs'),
      (Icons.bar_chart_rounded, 'Analyse'),
    ];

    return Container(
      padding: const EdgeInsets.only(top: 12, bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 20, offset: const Offset(0, -4))
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: items.asMap().entries.map((entry) {
          final i = entry.key;
          final item = entry.value;
          final selected = i == currentIndex;
          return GestureDetector(
            onTap: () async {
              await FlowoHaptics.selection();
              onTap(i);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: selected ? const Color(0xFF5B8DEF).withOpacity(0.12) : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedScale(
                    scale: selected ? 1.15 : 1.0,
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    child: Icon(
                      item.$1,
                      color: selected ? const Color(0xFF5B8DEF) : Colors.grey[400],
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 3),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                      color: selected ? const Color(0xFF5B8DEF) : Colors.grey[400],
                    ),
                    child: Text(item.$2),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
