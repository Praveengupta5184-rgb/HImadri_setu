import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dashboard_screen.dart';
import '../services/api_service.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  void _login() async {
    if (_email.text.isEmpty || _password.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter credentials')));
      return;
    }
    setState(() => _isLoading = true);
    try {
      final response = await _apiService.login(_email.text, _password.text);
      final token = response['token']; // assuming backend returns { "token": "..." }
      if (token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        _apiService.setToken(token);
        if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DashboardScreen()));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Login failed: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.ac_unit, size: 80, color: Colors.blue),
              const SizedBox(height: 16),
              const Text('POLAR-OPS', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 32),
              TextField(controller: _email, decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder())),
              const SizedBox(height: 16),
              TextField(controller: _password, obscureText: true, decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder())),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _login,
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                child: _isLoading ? const CircularProgressIndicator() : const Text('Login'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
