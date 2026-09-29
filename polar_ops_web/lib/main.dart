import 'package:flutter/material.dart';
import 'layout/app_shell.dart';
import 'screens/auth/login_screen.dart';
import 'services/auth/auth_service.dart';
import 'theme/app_theme.dart';
import 'services/sync/sync_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SyncService.initialize();
  await AuthService.loadSavedAuth();
  runApp(const PolarOpsWebApp());
}

class PolarOpsWebApp extends StatelessWidget {
  const PolarOpsWebApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'POLAR-OPS Web Command Center',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: AuthService.currentToken != null ? const AppShell() : const LoginScreen(),
    );
  }
}
