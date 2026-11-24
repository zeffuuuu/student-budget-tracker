import 'package:flutter/material.dart';
import '../data/app_state.dart';
import '../theme.dart';
import '../utils/format.dart';
import '../widgets/amount_dialog.dart';
import 'commitments_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Widget _title(String text) => Padding(
        padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
        child: Text(text,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: AppColors.textMuted, fontSize: 13)),
      );

  Widget _card(List<Widget> children) => Card(
        color: Colors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(children: children),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListenableBuilder(
        listenable: AppState.instance,
        builder: (context, _) {
          final s = AppState.instance;
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            children: [
              _title('FIXED PAYMENTS'),
              _card([
                ListTile(
                  leading: const Icon(Icons.event_repeat, color: AppColors.primary),
                  title: const Text('Monthly commitments'),
                  subtitle: Text(
                      '${s.activeCommitments.length} active  •  ${formatMoney(s.monthCommitments)} this month\nAdded to your spending automatically'),
                  isThreeLine: true,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const CommitmentsScreen())),
                ),
              ]),
              _title('IMPULSIVE PURCHASE ALERT'),
              _card([
                SwitchListTile(
                  secondary: const Icon(Icons.notifications_active, color: AppColors.primary),
                  title: const Text('Alert me when I overspend'),
                  subtitle: const Text(
                      'Warns you before saving an expense that takes your daily total over the limit'),
                  value: s.alertEnabled,
                  onChanged: s.setAlertEnabled,
                ),
                const Divider(height: 1),
                ListTile(
                  enabled: s.alertEnabled,
                  leading: const Icon(Icons.speed, color: AppColors.primary),
                  title: const Text('Daily spending limit'),
                  trailing: Text(formatMoney(s.dailyLimit),
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  onTap: () async {
                    final v = await showAmountDialog(context,
                        title: 'Daily spending limit', initial: s.dailyLimit);
                    if (v != null) s.setDailyLimit(v);
                  },
                ),
              ]),
            ],
          );
        },
      ),
    );
  }
}
