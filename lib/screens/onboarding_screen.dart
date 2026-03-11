import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/budget_provider.dart';
import '../utils/haptics.dart';
import '../utils/categories.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _page = 0;
  final _incomeController = TextEditingController();
  final _savingsController = TextEditingController();

  void _next() async {
    await FlowoHaptics.light();
    if (_page < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
      setState(() => _page++);
    } else {
      _finish();
    }
  }

  void _finish() async {
    final income = double.tryParse(_incomeController.text) ?? 1000;
    final savings = double.tryParse(_savingsController.text) ?? 100;
    await FlowoHaptics.success();
    if (mounted) {
      await context.read<BudgetProvider>().setupBudget(
            monthlyIncome: income,
            monthlySavingsGoal: savings,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _WelcomePage(),
                  _IncomePage(controller: _incomeController),
                  _SavingsPage(controller: _savingsController),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: List.generate(3, (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                      margin: const EdgeInsets.only(right: 6),
                      width: _page == i ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _page == i
                            ? const Color(0xFF5B8DEF)
                            : const Color(0xFFDDE3EE),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    )),
                  ),
                  GestureDetector(
                    onTap: _next,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF5B8DEF),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF5B8DEF).withOpacity(0.35),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          )
                        ],
                      ),
                      child: Text(
                        _page < 2 ? 'Suivant →' : 'Commencer',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ).animate(onPlay: (c) => c.repeat(reverse: true))
                        .shimmer(duration: 2000.ms, color: Colors.white24),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WelcomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('💸', style: TextStyle(fontSize: 72))
              .animate()
              .scale(begin: const Offset(0.5, 0.5), curve: Curves.elasticOut, duration: 800.ms),
          const SizedBox(height: 32),
          const Text(
            'Bienvenue sur Flowo',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
          const SizedBox(height: 16),
          Text(
            'Ton budget, tes objectifs,\nton avenir. En un seul endroit.',
            style: TextStyle(fontSize: 16, color: Colors.grey[600], height: 1.5),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
        ],
      ),
    );
  }
}

class _IncomePage extends StatelessWidget {
  final TextEditingController controller;
  const _IncomePage({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('💶', style: TextStyle(fontSize: 56))
              .animate().scale(begin: const Offset(0.5, 0.5), curve: Curves.elasticOut, duration: 600.ms),
          const SizedBox(height: 24),
          const Text(
            'Quel est ton salaire net ?',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.1),
          const SizedBox(height: 8),
          Text(
            'En euros, par mois.',
            style: TextStyle(color: Colors.grey[500], fontSize: 14),
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 32),
          _FlowoTextField(controller: controller, hint: '1 000', suffix: '€'),
        ],
      ),
    );
  }
}

class _SavingsPage extends StatelessWidget {
  final TextEditingController controller;
  const _SavingsPage({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🎯', style: TextStyle(fontSize: 56))
              .animate().scale(begin: const Offset(0.5, 0.5), curve: Curves.elasticOut, duration: 600.ms),
          const SizedBox(height: 24),
          const Text(
            'Combien veux-tu\nmettre de côté chaque mois ?',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.1),
          const SizedBox(height: 8),
          Text(
            'Nous t\'aiderons à atteindre cet objectif.',
            style: TextStyle(color: Colors.grey[500], fontSize: 14),
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 32),
          _FlowoTextField(controller: controller, hint: '200', suffix: '€'),
        ],
      ),
    );
  }
}

class _FlowoTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final String suffix;

  const _FlowoTextField({required this.controller, required this.hint, required this.suffix});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[300], fontWeight: FontWeight.w600),
          suffixText: suffix,
          suffixStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Color(0xFF5B8DEF)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
      ),
    );
  }
}
