
import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int currentPage = 0;

  final List<String> titles = [
    'Welcome to Student Budget Tracker',
    'Track Your Expenses',
    'Manage Your Budget',
  ];

  final List<String> descriptions = [
    'Manage your money easily as a student.',
    'Keep track of your daily income and expenses.',
    'Build better spending habits and save money.',
  ];

  final List<IconData> icons = [
    Icons.account_balance_wallet,
    Icons.receipt_long,
    Icons.savings,
  ];

  void nextPage() {
    if (currentPage < 2) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      openLogin();
    }
  }

  void openLogin() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: openLogin,
                child: const Text('Skip'),
              ),
            ),

            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: 3,
                onPageChanged: (index) {
                  setState(() {
                    currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(30),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          icons[index],
                          size: 110,
                          color: Colors.green,
                        ),
                        const SizedBox(height: 40),
                        Text(
                          titles[index],
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          descriptions[index],
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                return Container(
                  margin: const EdgeInsets.all(5),
                  width: currentPage == index ? 20 : 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: currentPage == index
                        ? Colors.green
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                );
              }),
            ),

            Padding(
              padding: const EdgeInsets.all(25),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    currentPage == 2 ? 'Get Started' : 'Next',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
