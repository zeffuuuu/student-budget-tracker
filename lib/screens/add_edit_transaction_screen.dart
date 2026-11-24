import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/app_state.dart';
import '../data/categories.dart';
import '../models/transaction.dart';
import '../theme.dart';
import '../utils/format.dart';
import '../utils/validators.dart';

/// Used for both adding (existing == null) and editing a transaction.
class AddEditTransactionScreen extends StatefulWidget {
  final Transaction? existing;
  const AddEditTransactionScreen({super.key, this.existing});

  @override
  State<AddEditTransactionScreen> createState() => _AddEditTransactionScreenState();
}

class _AddEditTransactionScreenState extends State<AddEditTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountCtrl;
  late final TextEditingController _titleCtrl;
  late final TextEditingController _noteCtrl;
  late bool _isExpense;
  late String _category;
  late DateTime _date;

  bool get _editing => widget.existing != null;
  List<CategoryInfo> get _categories =>
      _isExpense ? expenseCategories : incomeCategories;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _isExpense = e?.isExpense ?? true;
    _category = e?.category ?? expenseCategories.first.name;
    _date = e?.date ?? DateTime.now();
    _amountCtrl = TextEditingController(text: e == null ? '' : e.amount.toStringAsFixed(2));
    _titleCtrl = TextEditingController(text: e?.title ?? '');
    _noteCtrl = TextEditingController(text: e?.note ?? '');
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _titleCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && mounted) setState(() => _date = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final state = AppState.instance;
    final amount = double.parse(_amountCtrl.text.trim());

    // Impulsive purchase alert: warn BEFORE saving an expense that pushes
    // the day's total over the user's daily limit.
    if (_isExpense) {
      final warning = state.checkImpulse(
          amount: amount, date: _date, excludeId: widget.existing?.id);
      if (warning != null) {
        final proceed = await _showImpulseDialog(warning);
        if (proceed != true) return;
      }
    }
    if (!mounted) return;

    final tx = Transaction(
      id: widget.existing?.id ?? state.newId(),
      title: _titleCtrl.text.trim(),
      category: _category,
      amount: amount,
      date: _date,
      isExpense: _isExpense,
      note: _noteCtrl.text.trim(),
    );
    if (_editing) {
      state.update(tx);
    } else {
      state.add(tx);
    }
    Navigator.pop(context);
  }

  Future<bool?> _showImpulseDialog(ImpulseWarning w) {
    final message = w.singleOver
        ? 'This ${formatMoney(w.amount)} purchase alone is more than your daily limit of ${formatMoney(w.limit)}.'
        : 'With this purchase you will have spent ${formatMoney(w.dayTotal)} on ${formatDate(_date)}, which is over your daily limit of ${formatMoney(w.limit)}.';
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 44),
        title: const Text('Impulse purchase alert'),
        content: Text('$message\n\nIs this a need or a want? Take a moment before you spend.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Save anyway')),
        ],
      ),
    );
  }

  Future<void> _delete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete transaction?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
        ],
      ),
    );
    if (ok == true && mounted) {
      AppState.instance.delete(widget.existing!.id);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_editing ? 'Edit Transaction' : 'Add Transaction'),
        actions: [
          if (_editing)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Delete',
              onPressed: _delete,
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment<bool>(value: true, label: Text('Expense'), icon: Icon(Icons.arrow_upward)),
                    ButtonSegment<bool>(value: false, label: Text('Income'), icon: Icon(Icons.arrow_downward)),
                  ],
                  selected: {_isExpense},
                  onSelectionChanged: (sel) => setState(() {
                    _isExpense = sel.first;
                    _category = _categories.first.name;
                  }),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _amountCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                  ],
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  decoration: const InputDecoration(labelText: 'Amount', prefixText: 'RM '),
                  validator: Validators.amount,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _titleCtrl,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                      labelText: 'Title', prefixIcon: Icon(Icons.edit_outlined)),
                  validator: (v) => Validators.required(v, 'Title'),
                ),
                const SizedBox(height: 20),
                Text('Category', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _categories
                      .map((c) => ChoiceChip(
                            avatar: Icon(c.icon, size: 18, color: c.color),
                            label: Text(c.name),
                            selected: _category == c.name,
                            selectedColor: AppColors.primary.withAlpha(50),
                            onSelected: (_) => setState(() => _category = c.name),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 20),
                InkWell(
                  onTap: _pickDate,
                  borderRadius: BorderRadius.circular(12),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                        labelText: 'Date', prefixIcon: Icon(Icons.calendar_today)),
                    child: Text(formatDate(_date)),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _noteCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(
                      labelText: 'Note (optional)', prefixIcon: Icon(Icons.notes)),
                ),
                const SizedBox(height: 28),
                ElevatedButton(
                  onPressed: _save,
                  child: Text(_editing ? 'Save Changes' : 'Add Transaction'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
