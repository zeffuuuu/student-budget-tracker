import 'package:flutter/material.dart';
import '../data/app_state.dart';
import '../theme.dart';
import '../utils/format.dart';
import '../utils/stats.dart';
import '../widgets/bar_chart.dart';
import '../widgets/donut_chart.dart';
import '../widgets/empty_state.dart';
import '../widgets/transaction_tile.dart';
import 'open_transaction.dart';

/// Income / expense statistics for a day, week, month or year.
class StatsTab extends StatefulWidget {
  const StatsTab({super.key});

  @override
  State<StatsTab> createState() => _StatsTabState();
}

class _StatsTabState extends State<StatsTab> {
  StatPeriod _period = StatPeriod.month;
  late DateTime _start = periodStart(_period, DateTime.now());

  void _shift(int dir) =>
      setState(() => _start = shiftPeriod(_period, _start, dir));

  Widget _summary(String label, double value, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 4),
                Text(label,
                    style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
              ],
            ),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(formatMoney(value),
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold, color: color)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _legendDot(Color c, String text) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
          const SizedBox(width: 4),
          Text(text, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
        ],
      );

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppState.instance,
      builder: (context, _) {
        final s = AppState.instance;
        final stats = computeStats(s.transactions, _period, _start);
        final canNext = !shiftPeriod(_period, _start, 1).isAfter(DateTime.now());
        final shown = stats.items.take(15).toList();

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            SegmentedButton<StatPeriod>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment<StatPeriod>(value: StatPeriod.day, label: Text('Day')),
                ButtonSegment<StatPeriod>(value: StatPeriod.week, label: Text('Week')),
                ButtonSegment<StatPeriod>(value: StatPeriod.month, label: Text('Month')),
                ButtonSegment<StatPeriod>(value: StatPeriod.year, label: Text('Year')),
              ],
              selected: {_period},
              onSelectionChanged: (sel) => setState(() {
                _period = sel.first;
                _start = periodStart(_period, DateTime.now());
              }),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  tooltip: 'Previous',
                  onPressed: () => _shift(-1),
                ),
                Expanded(
                  child: Text(stats.label,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  tooltip: 'Next',
                  onPressed: canNext ? () => _shift(1) : null,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _summary('Income', stats.income, AppColors.income, Icons.arrow_downward),
                const SizedBox(width: 8),
                _summary('Expense', stats.expense, AppColors.expense, Icons.arrow_upward),
                const SizedBox(width: 8),
                _summary('Net', stats.net,
                    stats.net >= 0 ? AppColors.primary : AppColors.expense,
                    Icons.account_balance_wallet),
              ],
            ),
            const SizedBox(height: 16),
            if (stats.isEmpty)
              const EmptyState(
                icon: Icons.insights,
                message: 'No income or spending in this period.\nTry another date or add a transaction.',
              )
            else ...[
              if (_period != StatPeriod.day) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text('Income vs expenses',
                                style: Theme.of(context).textTheme.titleMedium),
                          ),
                          _legendDot(AppColors.income, 'Income'),
                          const SizedBox(width: 12),
                          _legendDot(AppColors.expense, 'Expense'),
                        ],
                      ),
                      const SizedBox(height: 12),
                      IncomeExpenseBarChart(
                        key: ValueKey('${_period.name}-${_start.toIso8601String()}'),
                        labels: stats.labels,
                        income: stats.incomeBars,
                        expense: stats.expenseBars,
                        labelEvery: stats.labelEvery,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              CategoryDonutCard(
                data: stats.expenseByCategory,
                title: 'Expenses by category',
                subtitle: stats.label,
              ),
              const SizedBox(height: 20),
              Text('Transactions', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              ...shown.map((t) => TransactionTile(
                    transaction: t,
                    onTap: () => openTransaction(context, t),
                  )),
              if (stats.items.length > shown.length)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'Showing ${shown.length} of ${stats.items.length}. See the Transactions tab for all of them.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
            ],
          ],
        );
      },
    );
  }
}
