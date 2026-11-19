import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../theme/app_theme.dart';

/// The add/edit form fields and validation.
///
/// Pass [initial] to pre-fill the form for editing.
/// [onSubmit] is called with the finished [Transaction] when it is valid.
class TransactionForm extends StatefulWidget {
  final Transaction? initial;

  /// Type to start with when adding (e.g. from the "Income" quick action).
  final TransactionType initialType;
  final String submitLabel;
  final ValueChanged<Transaction> onSubmit;

  const TransactionForm({
    super.key,
    this.initial,
    this.initialType = TransactionType.expense,
    required this.submitLabel,
    required this.onSubmit,
  });

  @override
  State<TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  final _formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final amountController = TextEditingController();
  final noteController = TextEditingController();

  TransactionType type = TransactionType.expense;
  String category = expenseCategories.first;
  DateTime date = DateTime.now();

  List<String> get categories =>
      type == TransactionType.income ? incomeCategories : expenseCategories;

  @override
  void initState() {
    super.initState();
    type = widget.initialType;
    category = categories.first;
    final t = widget.initial;
    if (t != null) {
      titleController.text = t.title;
      amountController.text = t.amount.toStringAsFixed(2);
      noteController.text = t.note;
      type = t.type;
      category = t.category;
      date = t.date;
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    amountController.dispose();
    noteController.dispose();
    super.dispose();
  }

  void changeType(TransactionType newType) {
    setState(() {
      type = newType;
      // Reset category if it doesn't belong to the new type.
      if (!categories.contains(category)) {
        category = categories.first;
      }
    });
  }

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => date = picked);
    }
  }

  void submit() {
    if (!_formKey.currentState!.validate()) return;

    final title = titleController.text.trim();
    final amount = double.parse(amountController.text.trim());
    final note = noteController.text.trim();
    final old = widget.initial;

    final result = old != null
        ? old.copyWith(
            title: title,
            amount: amount,
            type: type,
            category: category,
            date: date,
            note: note,
          )
        : Transaction(
            id: Transaction.newId(),
            title: title,
            amount: amount,
            type: type,
            category: category,
            date: date,
            note: note,
          );

    widget.onSubmit(result);
  }

  InputDecoration field(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: AppColors.card,
      alignLabelWithHint: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Income / Expense toggle
          SegmentedButton<TransactionType>(
            segments: const [
              ButtonSegment(
                value: TransactionType.expense,
                label: Text('Expense'),
                icon: Icon(Icons.north_east, color: AppColors.expense),
              ),
              ButtonSegment(
                value: TransactionType.income,
                label: Text('Income'),
                icon: Icon(Icons.south_west, color: AppColors.income),
              ),
            ],
            selected: {type},
            showSelectedIcon: false,
            style: SegmentedButton.styleFrom(
              backgroundColor: AppColors.card,
              selectedBackgroundColor: AppColors.primary,
              selectedForegroundColor: AppColors.text,
              side: BorderSide.none,
            ),
            onSelectionChanged: (selection) => changeType(selection.first),
          ),
          const SizedBox(height: 20),

          TextFormField(
            controller: titleController,
            decoration: field('Title', Icons.edit_outlined),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a title';
              }
              return null;
            },
          ),
          const SizedBox(height: 15),

          TextFormField(
            controller: amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: field('Amount (RM)', Icons.payments_outlined),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter an amount';
              }
              final amount = double.tryParse(value.trim());
              if (amount == null) {
                return 'Enter a valid number';
              }
              if (amount <= 0) {
                return 'Amount must be more than 0';
              }
              return null;
            },
          ),
          const SizedBox(height: 15),

          DropdownButtonFormField<String>(
            // Key forces a rebuild when the category list changes.
            key: ValueKey(type),
            initialValue: category,
            decoration: field('Category', Icons.category_outlined),
            items: categories
                .map((c) => DropdownMenuItem(
                      value: c,
                      child: Row(
                        children: [
                          Icon(categoryIcon(c), size: 20),
                          const SizedBox(width: 10),
                          Text(c),
                        ],
                      ),
                    ))
                .toList(),
            onChanged: (value) {
              if (value != null) setState(() => category = value);
            },
          ),
          const SizedBox(height: 15),

          // Date picker field
          InkWell(
            onTap: pickDate,
            child: InputDecorator(
              decoration: field('Date', Icons.calendar_today_outlined),
              child: Text(formatDate(date)),
            ),
          ),
          const SizedBox(height: 15),

          TextFormField(
            controller: noteController,
            maxLines: 3,
            decoration: field('Note (optional)', Icons.notes),
          ),
          const SizedBox(height: 25),

          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.text,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(widget.submitLabel),
            ),
          ),
        ],
      ),
    );
  }
}
