import 'package:flutter/material.dart';
import '../../services/auth/auth_service.dart';
import '../../theme/app_theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';
  String _successMessage = '';

  Future<void> _register() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _successMessage = '';
    });

    final result = await AuthService.register(
      _emailController.text,
      _passwordController.text,
      _nameController.text,
    );

    setState(() {
      _isLoading = false;
    });

    if (result.success) {
      if (result.registrationPending) {
        setState(() {
          _successMessage = result.message;
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message,
                  style: const TextStyle(color: Colors.white)),
              backgroundColor: AppTheme.statusHealthy,
            ),
          );
        }
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
              const Icon(Icons.person_add, size: 48, color: AppTheme.accentCyan),
              const SizedBox(height: AppTheme.spacingMd),
              const Text('POLAR-OPS Registration',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
              const Text('New Personnel Registration',
                  style: TextStyle(color: AppTheme.textMuted)),
              const SizedBox(height: AppTheme.spacingXl),

              TextField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  labelStyle: const TextStyle(color: AppTheme.textMuted),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppTheme.textMuted.withValues(alpha: 0.3))),
                  focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: AppTheme.accentCyan)),
                ),
              ),
              const SizedBox(height: AppTheme.spacingMd),
              TextField(
                controller: _emailController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Email',
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
                  labelText: 'Password (min 6 characters)',
                  labelStyle: const TextStyle(color: AppTheme.textMuted),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppTheme.textMuted.withValues(alpha: 0.3))),
                  focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: AppTheme.accentCyan)),
                ),
              ),
              const SizedBox(height: AppTheme.spacingLg),

              if (_successMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppTheme.spacingMd),
                  child: Text(_successMessage,
                      style: TextStyle(color: AppTheme.statusHealthy, fontSize: 13),
                      textAlign: TextAlign.center),
                ),
              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppTheme.spacingMd),
                  child: Text(_errorMessage,
                      style: TextStyle(color: AppTheme.statusCritical, fontSize: 13),
                      textAlign: TextAlign.center),
                ),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentCyan,
                    foregroundColor: AppTheme.primaryNavy,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: AppTheme.primaryNavy)
                      : const Text('REGISTER', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: AppTheme.spacingLg),
              Text(
                'Registration creates a PERSONNEL account with PENDING status. '
                'An administrator must approve your account before access is granted.',
                style: TextStyle(color: AppTheme.textMuted, fontSize: 11),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
