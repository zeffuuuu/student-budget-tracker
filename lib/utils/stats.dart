import '../models/transaction.dart';
import 'format.dart';

enum StatPeriod { day, week, month, year }

/// First moment of the period that contains [a]. Weeks start on Monday.
DateTime periodStart(StatPeriod p, DateTime a) => switch (p) {
      StatPeriod.day => DateTime(a.year, a.month, a.day),
      StatPeriod.week => DateTime(a.year, a.month, a.day - (a.weekday - 1)),
      StatPeriod.month => DateTime(a.year, a.month, 1),
      StatPeriod.year => DateTime(a.year, 1, 1),
    };

/// Start of the next period (exclusive end of this one).
DateTime periodEnd(StatPeriod p, DateTime start) => shiftPeriod(p, start, 1);

DateTime shiftPeriod(StatPeriod p, DateTime start, int dir) => switch (p) {
      StatPeriod.day => DateTime(start.year, start.month, start.day + dir),
      StatPeriod.week => DateTime(start.year, start.month, start.day + 7 * dir),
      StatPeriod.month => DateTime(start.year, start.month + dir, 1),
      StatPeriod.year => DateTime(start.year + dir, 1, 1),
    };

String rangeLabel(StatPeriod p, DateTime start) {
  final now = DateTime.now();
  switch (p) {
    case StatPeriod.day:
      final isToday = start.year == now.year &&
          start.month == now.month &&
          start.day == now.day;
      return isToday ? 'Today, ${formatDate(start)}' : formatDate(start);
    case StatPeriod.week:
      final last = DateTime(start.year, start.month, start.day + 6);
      return '${formatDate(start)} - ${formatDate(last)}';
    case StatPeriod.month:
      return formatMonthLong(start);
    case StatPeriod.year:
      return '${start.year}';
  }
}

const List<String> _weekLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const List<String> _monthLabels = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

/// Everything the Statistics screen needs for one period.
class PeriodStats {
  final String label;
  final double income;
  final double expense;
  final List<String> labels; // bar labels (empty for a single day)
  final List<double> incomeBars;
  final List<double> expenseBars;
  final int labelEvery;
  final Map<String, double> expenseByCategory;
  final List<Transaction> items;

  const PeriodStats({
    required this.label,
    required this.income,
    required this.expense,
    required this.labels,
    required this.incomeBars,
    required this.expenseBars,
    required this.labelEvery,
    required this.expenseByCategory,
    required this.items,
  });

  double get net => income - expense;
  bool get isEmpty => items.isEmpty;
}

PeriodStats computeStats(List<Transaction> all, StatPeriod p, DateTime start) {
  final end = periodEnd(p, start);
  final items = all
      .where((t) => !t.date.isBefore(start) && t.date.isBefore(end))
      .toList()
    ..sort((a, b) => b.date.compareTo(a.date));

  var labelEvery = 1;
  late List<String> labels;
  switch (p) {
    case StatPeriod.day:
      labels = <String>[];
    case StatPeriod.week:
      labels = _weekLabels;
    case StatPeriod.month:
      final days = DateTime(start.year, start.month + 1, 0).day;
      labels = List.generate(days, (i) => '${i + 1}');
      labelEvery = 5;
    case StatPeriod.year:
      labels = _monthLabels;
  }

  final incomeBars = List<double>.filled(labels.length, 0.0);
  final expenseBars = List<double>.filled(labels.length, 0.0);
  final byCategory = <String, double>{};
  var income = 0.0;
  var expense = 0.0;

  for (final t in items) {
    final idx = switch (p) {
      StatPeriod.day => -1,
      StatPeriod.week => t.date.weekday - 1,
      StatPeriod.month => t.date.day - 1,
      StatPeriod.year => t.date.month - 1,
    };
    if (t.isExpense) {
      expense += t.amount;
      byCategory[t.category] = (byCategory[t.category] ?? 0) + t.amount;
      if (idx >= 0 && idx < labels.length) expenseBars[idx] += t.amount;
    } else {
      income += t.amount;
      if (idx >= 0 && idx < labels.length) incomeBars[idx] += t.amount;
    }
  }

  return PeriodStats(
    label: rangeLabel(p, start),
    income: income,
    expense: expense,
    labels: labels,
    incomeBars: incomeBars,
    expenseBars: expenseBars,
    labelEvery: labelEvery,
    expenseByCategory: byCategory,
    items: items,
  );
}
