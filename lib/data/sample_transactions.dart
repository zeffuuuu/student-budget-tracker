import '../models/transaction.dart';

/// Hard-coded sample data used until the app has real storage.
List<Transaction> sampleTransactions() {
  return [
    Transaction(
      id: '1',
      title: 'Monthly allowance',
      amount: 500.00,
      type: TransactionType.income,
      category: 'Allowance',
      date: DateTime(2026, 11, 1),
      note: 'From parents',
    ),
    Transaction(
      id: '2',
      title: 'Nasi lemak breakfast',
      amount: 6.50,
      type: TransactionType.expense,
      category: 'Food',
      date: DateTime(2026, 11, 3),
    ),
    Transaction(
      id: '3',
      title: 'Grab to campus',
      amount: 12.00,
      type: TransactionType.expense,
      category: 'Transport',
      date: DateTime(2026, 11, 4),
    ),
    Transaction(
      id: '4',
      title: 'Database textbook',
      amount: 85.90,
      type: TransactionType.expense,
      category: 'Books',
      date: DateTime(2026, 11, 6),
      note: 'Used copy from senior',
    ),
    Transaction(
      id: '5',
      title: 'Tutoring part-time',
      amount: 150.00,
      type: TransactionType.income,
      category: 'Part-time Job',
      date: DateTime(2026, 11, 8),
    ),
    Transaction(
      id: '6',
      title: 'Movie with friends',
      amount: 18.00,
      type: TransactionType.expense,
      category: 'Entertainment',
      date: DateTime(2026, 11, 10),
    ),
    Transaction(
      id: '7',
      title: 'Phone bill',
      amount: 35.00,
      type: TransactionType.expense,
      category: 'Bills',
      date: DateTime(2026, 11, 12),
    ),
    Transaction(
      id: '8',
      title: 'Mamak dinner',
      amount: 9.80,
      type: TransactionType.expense,
      category: 'Food',
      date: DateTime(2026, 11, 15),
    ),
  ];
}
