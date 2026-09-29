import 'package:flutter/material.dart';
import '../../services/auth/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../layout/app_shell.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final result = await AuthService.login(
      _emailController.text,
      _passwordController.text,
    );

    setState(() {
      _isLoading = false;
    });

    if (result.success && result.token != null) {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const AppShell()),
        );
      }
    } else {
      setState(() {
        _errorMessage = result.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryNavy,
      body: Center(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(AppTheme.spacingXl),
          decoration: BoxDecoration(
            color: AppTheme.secondaryNavy,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.accentCyan.withValues(alpha: 0.3)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.ac_unit, size: 48, color: AppTheme.accentCyan),
              const SizedBox(height: AppTheme.spacingMd),
              const Text('POLAR-OPS',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
              const Text('Mission Command Authentication',
                  style: TextStyle(color: AppTheme.textMuted)),
              const SizedBox(height: AppTheme.spacingXl),

              TextField(
                controller: _emailController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Email / Operative ID',
                  labelStyle: const TextStyle(color: AppTheme.textMuted),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppTheme.textMuted.withValues(alpha: 0.3))),
                  focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: AppTheme.accentCyan)),
                ),
              ),
              const SizedBox(height: AppTheme.spacingMd),
              TextField(
                controller: _passwordController,
                style: const TextStyle(color: Colors.white),
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Passcode',
                  labelStyle: const TextStyle(color: AppTheme.textMuted),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppTheme.textMuted.withValues(alpha: 0.3))),
                  focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: AppTheme.accentCyan)),
                ),
              ),
              const SizedBox(height: AppTheme.spacingLg),

              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppTheme.spacingMd),
                  child: Text(_errorMessage,
                      style: const TextStyle(color: AppTheme.statusCritical)),
                ),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentCyan,
                    foregroundColor: AppTheme.primaryNavy,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: AppTheme.primaryNavy)
                      : const Text('AUTHORIZE ACCESS', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: AppTheme.spacingLg),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const RegisterScreen()),
                  );
                },
                child: const Text(
                  'Register new personnel account',
                  style: TextStyle(color: AppTheme.accentCyan, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
