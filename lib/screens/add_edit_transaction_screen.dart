import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../theme/app_theme.dart';
import '../widgets/transaction_form.dart';

/// Screen for adding a new transaction or editing an existing one.
///
/// - Edit: pass [transaction].
/// - Add: leave it null. Use [initialType] to open on Income or Expense
///   (for the dashboard's "Add Expense" and "Income" quick actions).
///
/// Returns the saved [Transaction] with Navigator.pop, or null if cancelled.
class AddEditTransactionScreen extends StatelessWidget {
  final Transaction? transaction;
  final TransactionType initialType;

  const AddEditTransactionScreen({
    super.key,
    this.transaction,
    this.initialType = TransactionType.expense,
  });

  bool get isEditing => transaction != null;

  String get title {
    if (isEditing) return 'Edit Transaction';
    return initialType == TransactionType.income ? 'Add Income' : 'Add Expense';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(title),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: TransactionForm(
          initial: transaction,
          initialType: initialType,
          submitLabel: isEditing ? 'Save Changes' : 'Save',
          onSubmit: (saved) => Navigator.pop(context, saved),
        ),
      ),
    );
  }
}
