import 'package:flutter/material.dart';
import '../data/app_state.dart';
import '../theme.dart';
import 'login_screen.dart';
import 'settings_screen.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  void _logout(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
    AppState.instance.logout();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppState.instance,
      builder: (context, _) {
        final s = AppState.instance;
        final initial = s.userName.isEmpty ? '?' : s.userName[0].toUpperCase();
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SizedBox(height: 8),
            Center(
              child: CircleAvatar(
                radius: 44,
                backgroundColor: AppColors.primary,
                child: Text(initial,
                    style: const TextStyle(
                        fontSize: 36, color: AppColors.secondary, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 12),
            Text(s.userName,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium),
            if (s.userEmail.isNotEmpty)
              Text(s.userEmail,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 24),
            Card(
              color: Colors.white,
              elevation: 0,
              margin: EdgeInsets.zero,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.settings, color: AppColors.primary),
                    title: const Text('Settings'),
                    subtitle: const Text('Monthly commitments and impulse alert'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const SettingsScreen())),
                  ),
                  const Divider(height: 1),
                  const ListTile(
                    leading: Icon(Icons.payments, color: AppColors.primary),
                    title: Text('Currency'),
                    trailing: Text('Malaysian Ringgit (RM)'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.info_outline, color: AppColors.primary),
                    title: const Text('About'),
                    onTap: () => showAboutDialog(
                      context: context,
                      applicationName: 'Student Budget Tracker',
                      applicationVersion: '1.1.0',
                      children: const [
                        Text('A simple way for students to record income and spending, '
                            'plan monthly commitments and build better money habits.'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () => _logout(context),
              icon: const Icon(Icons.logout),
              label: const Text('Log out'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                foregroundColor: AppColors.expense,
              ),
            ),
          ],
        );
      },
    );
  }
}
