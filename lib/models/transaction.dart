import 'package:flutter/material.dart';

/// Whether money is coming in or going out.
enum TransactionType { income, expense }

/// A single income or expense record.
class Transaction {
  final String id;
  final String title;
  final double amount; // always positive; [type] decides + or -
  final TransactionType type;
  final String category;
  final DateTime date;
  final String note;

  const Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    this.note = '',
  });

  bool get isIncome => type == TransactionType.income;

  /// Positive for income, negative for expense.
  double get signedAmount => isIncome ? amount : -amount;

  Transaction copyWith({
    String? title,
    double? amount,
    TransactionType? type,
    String? category,
    DateTime? date,
    String? note,
  }) {
    return Transaction(
      id: id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      category: category ?? this.category,
      date: date ?? this.date,
      note: note ?? this.note,
    );
  }

  /// Simple unique id based on the current time.
  static String newId() => DateTime.now().microsecondsSinceEpoch.toString();
}

/// Categories offered in the form, per transaction type.
const List<String> expenseCategories = [
  'Food',
  'Transport',
  'Books',
  'Rent',
  'Entertainment',
  'Shopping',
  'Bills',
  'Other',
];

const List<String> incomeCategories = [
  'Allowance',
  'PTPTN',
  'Scholarship',
  'Part-time Job',
  'Other',
];

/// Icon shown for each category in the list.
IconData categoryIcon(String category) {
  switch (category) {
    case 'Food':
      return Icons.restaurant;
    case 'Transport':
      return Icons.directions_car_outlined;
    case 'Books':
      return Icons.menu_book_outlined;
    case 'Rent':
      return Icons.home_outlined;
    case 'Entertainment':
      return Icons.movie_outlined;
    case 'Shopping':
      return Icons.shopping_bag_outlined;
    case 'Bills':
      return Icons.receipt_outlined;
    case 'Allowance':
      return Icons.account_balance_wallet_outlined;
    case 'PTPTN':
      return Icons.account_balance_outlined;
    case 'Scholarship':
      return Icons.school_outlined;
    case 'Part-time Job':
      return Icons.work_outline;
    default:
      return Icons.payments_outlined;
  }
}

/// Formats an amount as Malaysian Ringgit, e.g. "RM 12.50".
String formatRM(double amount) => 'RM ${amount.toStringAsFixed(2)}';

/// Signed amount like the dashboard: "+RM 800.00" or "−RM 12.00".
String formatSignedRM(Transaction t) =>
    '${t.isIncome ? '+' : '\u2212'}${formatRM(t.amount)}';

/// Formats a date as "18 Nov 2026" without needing the intl package.
String formatDate(DateTime date) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}
