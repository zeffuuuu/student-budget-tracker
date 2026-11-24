import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Small dialog asking for an amount in RM. Returns null if cancelled.
Future<double?> showAmountDialog(
  BuildContext context, {
  required String title,
  required double initial,
  String? helper,
}) {
  return showDialog<double>(
    context: context,
    builder: (_) => _AmountDialog(title: title, initial: initial, helper: helper),
  );
}

class _AmountDialog extends StatefulWidget {
  final String title;
  final double initial;
  final String? helper;
  const _AmountDialog({required this.title, required this.initial, this.helper});

  @override
  State<_AmountDialog> createState() => _AmountDialogState();
}

class _AmountDialogState extends State<_AmountDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    final v = widget.initial;
    _ctrl = TextEditingController(
        text: v <= 0 ? '' : v.toStringAsFixed(v % 1 == 0 ? 0 : 2));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _ctrl,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
          ],
          decoration: InputDecoration(prefixText: 'RM ', helperText: widget.helper),
          validator: (v) {
            final n = double.tryParse((v ?? '').trim());
            if (n == null || n <= 0) return 'Enter an amount above 0';
            return null;
          },
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context, double.parse(_ctrl.text.trim()));
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
