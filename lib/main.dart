import 'package:flutter/material.dart';
import 'theme.dart';
import 'screens/onboarding_screen.dart';

void main() => runApp(const BudgetTrackerApp());

class BudgetTrackerApp extends StatelessWidget {
  const BudgetTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Budget Tracker',
      debugShowCheckedModeBanner: false,
      theme: appTheme, // theme defined once, used everywhere
      home: const OnboardingScreen(),
    );
  }
}
