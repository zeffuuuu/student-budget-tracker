import 'package:flutter/material.dart';
import '../data/app_state.dart';
import '../theme.dart';
import '../utils/format.dart';
import '../widgets/amount_dialog.dart';
import '../widgets/donut_chart.dart';
import '../widgets/empty_state.dart';
import '../widgets/transaction_tile.dart';
import 'add_edit_transaction_screen.dart';
import 'commitments_screen.dart';
import 'open_transaction.dart';

class DashboardTab extends StatelessWidget {
  final VoidCallback onSeeAll;
  const DashboardTab({super.key, required this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppState.instance,
      builder: (context, _) {
        final s = AppState.instance;
        final all = s.transactions;
        final recent = all.take(5).toList();
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
          children: [
            Text('Hi, ${s.userName}', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 4),
            Text("Here's your money at a glance",
                style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 16),
            _BalanceCard(balance: s.balance, income: s.totalIncome, spent: s.totalExpense),
            if (s.overDailyLimitToday) ...[
              const SizedBox(height: 12),
              _LimitBanner(today: s.todayExpense, limit: s.dailyLimit),
            ],
            const SizedBox(height: 16),
            if (all.isEmpty) ...[
              const _GetStartedCard(),
              const SizedBox(height: 16),
            ],
            Card(
              color: Colors.white,
              elevation: 0,
              margin: EdgeInsets.zero,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppColors.primarySoft,
                  child: Icon(Icons.event_repeat, color: AppColors.primary),
                ),
                title: const Text('Monthly commitments'),
                subtitle: Text('${s.activeCommitments.length} active  •  added to spending automatically'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(formatMoney(s.monthCommitments),
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    const Icon(Icons.chevron_right),
                  ],
                ),
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const CommitmentsScreen())),
              ),
            ),
            const SizedBox(height: 16),
            CategoryDonutCard(
              data: s.monthExpenseByCategory,
              subtitle: 'This month',
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Text('Recent transactions',
                      style: Theme.of(context).textTheme.titleMedium),
                ),
                TextButton(onPressed: onSeeAll, child: const Text('See all')),
              ],
            ),
            const SizedBox(height: 4),
            if (recent.isEmpty)
              const EmptyState(
                  icon: Icons.receipt_long,
                  message: 'No transactions yet.\nTap Add to record your first one.')
            else
              ...recent.map(
                (t) => TransactionTile(
                  transaction: t,
                  onTap: () => openTransaction(context, t),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _BalanceCard extends StatelessWidget {
  final double balance;
  final double income;
  final double spent;
  const _BalanceCard({required this.balance, required this.income, required this.spent});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryDark, AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.account_balance_wallet, color: AppColors.secondary, size: 18),
              SizedBox(width: 8),
              Text('Current balance', style: TextStyle(color: Colors.white70)),
            ],
          ),
          const SizedBox(height: 6),
          Text(formatMoney(balance),
              style: const TextStyle(
                  color: Colors.white, fontSize: 34, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _stat('Income', income, Icons.arrow_downward)),
              Expanded(child: _stat('Spent', spent, Icons.arrow_upward)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, double value, IconData icon) => Row(
        children: [
          Icon(icon, color: AppColors.secondary, size: 18),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
              Text(formatMoney(value),
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      );
}

/// Shown when today's spending is already over the daily limit.
class _LimitBanner extends StatelessWidget {
  final double today;
  final double limit;
  const _LimitBanner({required this.today, required this.limit});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4D6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.secondary),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: AppColors.warning),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Impulse alert: you have spent ${formatMoney(today)} today, '
              'over your daily limit of ${formatMoney(limit)}.',
              style: const TextStyle(color: AppColors.textDark),
            ),
          ),
        ],
      ),
    );
  }
}

/// Checklist for a brand-new account (nothing recorded yet).
class _GetStartedCard extends StatelessWidget {
  const _GetStartedCard();

  @override
  Widget build(BuildContext context) {
    final s = AppState.instance;
    return Card(
      color: Colors.white,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Text('Get started', style: Theme.of(context).textTheme.titleMedium),
            ),
            ListTile(
              leading: const Icon(Icons.event_repeat, color: AppColors.primary),
              title: const Text('Add monthly commitments'),
              subtitle: const Text('Rent, utilities, bills, PayLater...'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const CommitmentsScreen())),
            ),
            ListTile(
              leading: const Icon(Icons.add_circle, color: AppColors.primary),
              title: const Text('Record your first transaction'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const AddEditTransactionScreen())),
            ),
            ListTile(
              leading: const Icon(Icons.speed, color: AppColors.primary),
              title: const Text('Set your daily spending limit'),
              subtitle: const Text('Get an alert before an impulse purchase'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                final v = await showAmountDialog(context,
                    title: 'Daily spending limit', initial: s.dailyLimit);
                if (v != null) s.setDailyLimit(v);
              },
            ),
          ],
        ),
      ),
    );
  }
}
