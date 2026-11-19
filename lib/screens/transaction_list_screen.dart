import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../data/sample_transactions.dart';
import '../theme/app_theme.dart';
import '../widgets/transaction_card.dart';
import 'add_edit_transaction_screen.dart';

/// Transaction history (the dashboard's "History" button).
/// Lets the user add, edit and delete transactions.
class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({super.key});

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  // Starts with hard-coded sample data (no database yet).
  final List<Transaction> transactions = sampleTransactions();

  double get totalIncome => transactions
      .where((t) => t.isIncome)
      .fold(0, (sum, t) => sum + t.amount);

  double get totalExpense => transactions
      .where((t) => !t.isIncome)
      .fold(0, (sum, t) => sum + t.amount);

  double get balance => totalIncome - totalExpense;

  /// Newest first.
  void sortByDate() {
    transactions.sort((a, b) => b.date.compareTo(a.date));
  }

  @override
  void initState() {
    super.initState();
    sortByDate();
  }

  Future<void> openAdd() async {
    final result = await Navigator.push<Transaction>(
      context,
      MaterialPageRoute(builder: (_) => const AddEditTransactionScreen()),
    );
    if (result == null || !mounted) return;

    setState(() {
      transactions.add(result);
      sortByDate();
    });
    showMessage('Transaction added');
  }

  Future<void> openEdit(Transaction t) async {
    final result = await Navigator.push<Transaction>(
      context,
      MaterialPageRoute(
        builder: (_) => AddEditTransactionScreen(transaction: t),
      ),
    );
    if (result == null || !mounted) return;

    setState(() {
      final index = transactions.indexWhere((x) => x.id == result.id);
      if (index != -1) transactions[index] = result;
      sortByDate();
    });
    showMessage('Transaction updated');
  }

  void delete(Transaction t) {
    final index = transactions.indexOf(t);
    setState(() => transactions.removeAt(index));

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('"${t.title}" deleted'),
          action: SnackBarAction(
            label: 'UNDO',
            textColor: AppColors.primary,
            onPressed: () => setState(() {
              transactions.insert(index, t);
            }),
          ),
        ),
      );
  }

  void showMessage(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Transaction History'),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.text,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: const TextStyle(
          color: AppColors.text,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: openAdd,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.text,
        elevation: 2,
        icon: const Icon(Icons.add),
        label: const Text(
          'Add',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
        // +1 for the summary header at the top
        itemCount: transactions.isEmpty ? 2 : transactions.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) return _buildSummary();
          if (transactions.isEmpty) return _buildEmptyState();

          final t = transactions[index - 1];
          return TransactionCard(
            transaction: t,
            onTap: () => openEdit(t),
            onDelete: () => delete(t),
          );
        },
      ),
    );
  }

  Widget _buildSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Yellow balance card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Available Balance',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 6),
              Text(
                formatRM(balance),
                style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${transactions.length} transactions · Sample data',
                style: const TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Income / Expenses cards
        Row(
          children: [
            Expanded(
              child: _summaryCard(
                'Income',
                totalIncome,
                Icons.south_west,
                AppColors.income,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _summaryCard(
                'Expenses',
                totalExpense,
                Icons.north_east,
                AppColors.expense,
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),

        const Text(
          'All Transactions',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.text,
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _summaryCard(
    String label,
    double amount,
    IconData icon,
    Color iconColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: iconColor),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(fontSize: 15, color: AppColors.subtext),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            formatRM(amount),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Padding(
      padding: EdgeInsets.only(top: 40),
      child: Column(
        children: [
          Icon(Icons.receipt_long_outlined, size: 70, color: AppColors.subtext),
          SizedBox(height: 12),
          Text(
            'No transactions yet',
            style: TextStyle(fontSize: 18, color: AppColors.subtext),
          ),
          SizedBox(height: 4),
          Text('Tap "Add" to record your first one'),
        ],
      ),
    );
  }
}
