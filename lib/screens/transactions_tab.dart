import 'package:flutter/material.dart';
import '../data/app_state.dart';
import '../theme.dart';
import '../widgets/empty_state.dart';
import '../widgets/transaction_tile.dart';
import 'open_transaction.dart';

class TransactionsTab extends StatefulWidget {
  const TransactionsTab({super.key});

  @override
  State<TransactionsTab> createState() => _TransactionsTabState();
}

class _TransactionsTabState extends State<TransactionsTab> {
  int _filter = 0; // 0 = all, 1 = income, 2 = expense
  static const _labels = ['All', 'Income', 'Expense'];

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppState.instance,
      builder: (context, _) {
        final state = AppState.instance;
        final items = state.transactions
            .where((t) =>
                _filter == 0 ||
                (_filter == 1 && !t.isExpense) ||
                (_filter == 2 && t.isExpense))
            .toList();
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                children: List.generate(
                  _labels.length,
                  (i) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(_labels[i]),
                      selected: _filter == i,
                      selectedColor: AppColors.primarySoft,
                      onSelected: (_) => setState(() => _filter = i),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: items.isEmpty
                  ? const Center(
                      child: EmptyState(
                          icon: Icons.inbox,
                          message: 'Nothing here yet.\nTap Add to record a transaction.'))
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                      itemCount: items.length,
                      itemBuilder: (context, i) {
                        final t = items[i];
                        // Automatic commitment entries cannot be swiped away;
                        // they are changed from the commitment itself.
                        return Dismissible(
                          key: ValueKey(t.id),
                          direction: t.commitmentId == null
                              ? DismissDirection.endToStart
                              : DismissDirection.none,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: AppColors.expense,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          onDismissed: (_) {
                            state.delete(t.id);
                            ScaffoldMessenger.of(context)
                              ..hideCurrentSnackBar()
                              ..showSnackBar(
                                SnackBar(
                                  content: Text('Deleted "${t.title}"'),
                                  action: SnackBarAction(
                                    label: 'Undo',
                                    onPressed: () => state.add(t),
                                  ),
                                ),
                              );
                          },
                          child: TransactionTile(
                            transaction: t,
                            onTap: () => openTransaction(context, t),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}
