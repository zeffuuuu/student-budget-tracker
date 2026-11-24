import 'package:flutter/material.dart';
import '../data/app_state.dart';
import '../theme.dart';
import '../utils/validators.dart';
import 'main_shell.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  String? _error;

  void _register() {
    setState(() => _error = null);
    if (!_formKey.currentState!.validate()) return;
    final s = AppState.instance;
    final name = _nameCtrl.text.trim();
    final err = s.register(
        name: name, email: _emailCtrl.text, password: _passCtrl.text);
    if (err != null) {
      setState(() => _error = err);
      return;
    }
    s.login(_emailCtrl.text, _passCtrl.text);
    final messenger = ScaffoldMessenger.of(context);
    // Go straight into the app. The new account has no data yet.
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const MainShell()),
      (route) => false,
    );
    messenger.showSnackBar(
      SnackBar(content: Text('Welcome, $name! Your account is ready.')),
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Full name', prefixIcon: Icon(Icons.person_outline)),
                  validator: (v) => Validators.required(v, 'Name'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                      labelText: 'Email', prefixIcon: Icon(Icons.email_outlined)),
                  validator: Validators.email,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(
                      labelText: 'Password', prefixIcon: Icon(Icons.lock_outline)),
                  validator: Validators.password,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(
                      labelText: 'Confirm password', prefixIcon: Icon(Icons.lock_outline)),
                  validator: (v) => v != _passCtrl.text ? 'Passwords do not match' : null,
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.expense)),
                ],
                const SizedBox(height: 24),
                ElevatedButton(onPressed: _register, child: const Text('Register')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
