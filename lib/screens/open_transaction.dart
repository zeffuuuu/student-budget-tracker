import 'package:flutter/material.dart';
import '../data/app_state.dart';
import '../models/transaction.dart';
import 'add_edit_commitment_screen.dart';
import 'add_edit_transaction_screen.dart';

/// Tapping a transaction opens its edit screen. Entries that were generated
/// from a monthly commitment open the commitment instead.
void openTransaction(BuildContext context, Transaction t) {
  final cid = t.commitmentId;
  if (cid != null) {
    for (final c in AppState.instance.commitments) {
      if (c.id == cid) {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => AddEditCommitmentScreen(existing: c)));
        return;
      }
    }
    return;
  }
  Navigator.push(context,
      MaterialPageRoute(builder: (_) => AddEditTransactionScreen(existing: t)));
}
