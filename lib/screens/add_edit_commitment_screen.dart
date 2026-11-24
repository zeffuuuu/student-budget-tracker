import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/app_state.dart';
import '../data/categories.dart';
import '../models/commitment.dart';
import '../theme.dart';
import '../utils/validators.dart';

enum _Unit { months, years, forever }

/// Add or edit a monthly commitment (rent, utilities, bills, PayLater...).
/// The user types how long it lasts, in months or in years (or forever).
class AddEditCommitmentScreen extends StatefulWidget {
  final Commitment? existing;
  const AddEditCommitmentScreen({super.key, this.existing});

  @override
  State<AddEditCommitmentScreen> createState() => _AddEditCommitmentScreenState();
}

class _AddEditCommitmentScreenState extends State<AddEditCommitmentScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _amountCtrl;
  late final TextEditingController _periodCtrl;
  late String _type;
  late _Unit _unit;

  bool get _editing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameCtrl = TextEditingController(text: e?.name ?? '');
    _amountCtrl = TextEditingController(text: e == null ? '' : e.amount.toStringAsFixed(2));
    _type = e?.type ?? commitmentTypes.first.name;

    // Work out how the saved period should be shown (months, years or forever).
    var unit = _Unit.months;
    var count = '1';
    if (e != null) {
      final m = e.months;
      if (m == null) {
        unit = _Unit.forever;
      } else if (m % 12 == 0) {
        unit = _Unit.years;
        count = '${m ~/ 12}';
      } else {
        count = '$m';
      }
    }
    _unit = unit;
    _periodCtrl = TextEditingController(text: count);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _amountCtrl.dispose();
    _periodCtrl.dispose();
    super.dispose();
  }

  String? _validatePeriod(String? v) {
    final n = int.tryParse((v ?? '').trim());
    if (n == null || n < 1) {
      return _unit == _Unit.years ? 'Enter the number of years' : 'Enter the number of months';
    }
    if (_unit == _Unit.years && n > 50) return 'Maximum is 50 years';
    if (_unit == _Unit.months && n > 600) return 'Maximum is 600 months';
    return null;
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final now = DateTime.now();
    int? months;
    if (_unit != _Unit.forever) {
      final n = int.parse(_periodCtrl.text.trim());
      months = _unit == _Unit.years ? n * 12 : n;
    }
    final c = Commitment(
      id: widget.existing?.id ?? AppState.instance.newId(),
      name: _nameCtrl.text.trim(),
      type: _type,
      amount: double.parse(_amountCtrl.text.trim()),
      start: widget.existing?.start ?? DateTime(now.year, now.month),
      months: months,
    );
    if (_editing) {
      AppState.instance.updateCommitment(c);
    } else {
      AppState.instance.addCommitment(c);
    }
    Navigator.pop(context);
  }

  Future<void> _delete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete commitment?'),
        content: const Text('It will no longer be added to your spending.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
        ],
      ),
    );
    if (ok == true && mounted) {
      AppState.instance.deleteCommitment(widget.existing!.id);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_editing ? 'Edit Commitment' : 'Add Commitment'),
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
                Text('Type', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: commitmentTypes
                      .map((c) => ChoiceChip(
                            avatar: Icon(c.icon, size: 18, color: c.color),
                            label: Text(c.name),
                            selected: _type == c.name,
                            selectedColor: AppColors.primarySoft,
                            onSelected: (_) => setState(() => _type = c.name),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _nameCtrl,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                      labelText: 'Name (e.g. Room rent, Shopee PayLater)',
                      prefixIcon: Icon(Icons.edit_outlined)),
                  validator: (v) => Validators.required(v, 'Name'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _amountCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                  ],
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  decoration: const InputDecoration(
                      labelText: 'Amount per month', prefixText: 'RM '),
                  validator: Validators.amount,
                ),
                const SizedBox(height: 20),
                Text('How long?', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                SegmentedButton<_Unit>(
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment<_Unit>(value: _Unit.months, label: Text('Months')),
                    ButtonSegment<_Unit>(value: _Unit.years, label: Text('Years')),
                    ButtonSegment<_Unit>(value: _Unit.forever, label: Text('Forever')),
                  ],
                  selected: {_unit},
                  onSelectionChanged: (sel) => setState(() => _unit = sel.first),
                ),
                if (_unit != _Unit.forever) ...[
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _periodCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      labelText: _unit == _Unit.years ? 'Number of years' : 'Number of months',
                      prefixIcon: const Icon(Icons.timelapse),
                    ),
                    validator: _validatePeriod,
                  ),
                ],
                const SizedBox(height: 12),
                Text(
                  'Added to your spending automatically every month while it is active, '
                  'so there is no need to key it in yourself.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 28),
                ElevatedButton(
                  onPressed: _save,
                  child: Text(_editing ? 'Save Changes' : 'Add Commitment'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
