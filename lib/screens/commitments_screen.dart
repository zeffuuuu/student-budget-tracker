import 'package:flutter/material.dart';
import '../data/app_state.dart';
import '../data/categories.dart';
import '../models/commitment.dart';
import '../theme.dart';
import '../utils/format.dart';
import '../widgets/empty_state.dart';
import 'add_edit_commitment_screen.dart';

class CommitmentsScreen extends StatelessWidget {
  const CommitmentsScreen({super.key});

  void _open(BuildContext context, [Commitment? c]) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddEditCommitmentScreen(existing: c)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Monthly Commitments')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _open(context),
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
      body: ListenableBuilder(
        listenable: AppState.instance,
        builder: (context, _) {
          final s = AppState.instance;
          final all = s.commitments;
          final now = DateTime.now();
          if (all.isEmpty) {
            return const Center(
              child: EmptyState(
                icon: Icons.event_repeat,
                message: 'No commitments yet.\nAdd fixed monthly payments like rent, utilities, bills or PayLater. '
                    'They are added to your spending automatically every month.',
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [AppColors.primaryDark, AppColors.primary]),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Added to spending this month',
                              style: TextStyle(color: Colors.white70)),
                          const SizedBox(height: 4),
                          Text(formatMoney(s.monthCommitments),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    Text('${s.activeCommitments.length} active',
                        style: const TextStyle(
                            color: AppColors.secondary, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ...all.map((c) {
                final info = commitmentTypeByName(c.type);
                final active = c.isActiveIn(now.year, now.month);
                return Card(
                  color: Colors.white,
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 8),
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  child: ListTile(
                    leading: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: info.color.withAlpha(active ? 40 : 20),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(info.icon, color: active ? info.color : Colors.grey),
                    ),
                    title: Text(c.name,
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: active ? AppColors.textDark : AppColors.textMuted)),
                    subtitle: Text(
                        '${c.type}  •  ${c.durationLabel}\n${c.statusLabel(now.year, now.month)}'),
                    trailing: Text('${formatMoney(c.amount)}/mo',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: active ? AppColors.textDark : AppColors.textMuted)),
                    onTap: () => _open(context, c),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}
