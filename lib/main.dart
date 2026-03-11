import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/budget_provider.dart';
import 'providers/expense_provider.dart';
import 'providers/goal_provider.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const FlowoApp());
}

class FlowoApp extends StatelessWidget {
  const FlowoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BudgetProvider()..init()),
        ChangeNotifierProvider(create: (_) => ExpenseProvider()..init()),
        ChangeNotifierProvider(create: (_) => GoalProvider()..init()),
      ],
      child: MaterialApp(
        title: 'Flowo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF5B8DEF),
            brightness: Brightness.light,
          ),
          textTheme: GoogleFonts.interTextTheme(),
          scaffoldBackgroundColor: const Color(0xFFF8F9FB),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFFF8F9FB),
            elevation: 0,
            scrolledUnderElevation: 0,
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
