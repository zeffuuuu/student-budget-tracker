import 'package:flutter/material.dart';
import 'add_edit_transaction_screen.dart';
import 'dashboard_tab.dart';
import 'profile_tab.dart';
import 'settings_screen.dart';
import 'stats_tab.dart';
import 'transactions_tab.dart';

/// Holds the AppBar, bottom navigation and the four tabs.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _tab = 0;
  static const _titles = ['Dashboard', 'Transactions', 'Statistics', 'Profile'];

  void _openAdd() {
    Navigator.push(context,
        MaterialPageRoute(builder: (_) => const AddEditTransactionScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      DashboardTab(onSeeAll: () => setState(() => _tab = 1)),
      const TransactionsTab(),
      const StatsTab(),
      const ProfileTab(),
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_tab]),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
        ],
      ),
      body: IndexedStack(index: _tab, children: pages),
      floatingActionButton: _tab <= 1
          ? FloatingActionButton.extended(
              onPressed: _openAdd,
              icon: const Icon(Icons.add),
              label: const Text('Add'),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long), label: 'Transactions'),
          NavigationDestination(icon: Icon(Icons.bar_chart_outlined), selectedIcon: Icon(Icons.bar_chart), label: 'Statistics'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
