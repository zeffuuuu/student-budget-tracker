class Transaction {
  final String id;
  final String title;
  final String category;
  final double amount;
  final DateTime date;
  final bool isExpense;
  final String note;

  /// Set when this entry was generated automatically from a monthly commitment.
  final String? commitmentId;

  const Transaction({
    required this.id,
    required this.title,
    required this.category,
    required this.amount,
    required this.date,
    required this.isExpense,
    this.note = '',
    this.commitmentId,
  });
}
