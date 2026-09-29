import os

base_dir = "polar_ops_app/lib"
dirs = ["screens/cargo", "screens/inventory", "screens/personnel", "screens/emergency", "screens/reports"]

for d in dirs:
    os.makedirs(os.path.join(base_dir, d), exist_ok=True)

def write_file(path, content):
    with open(os.path.join(base_dir, path), "w", encoding="utf-8") as f:
        f.write(content)

# Auth Screen
write_file("screens/login_screen.dart", """import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  
  void _login() async {
    // Mock login logic
    if (_email.text.isNotEmpty && _password.text == 'admin123') {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', 'mock_jwt_token_admin');
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DashboardScreen()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid credentials')));
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
                onPressed: _login,
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                child: const Text('Login'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
""")

# Cargo List
write_file("screens/cargo/cargo_list_screen.dart", """import 'package:flutter/material.dart';

class CargoListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cargo Management')),
      body: ListView.builder(
        itemCount: 50,
        itemBuilder: (context, index) {
          int risk = (30 + (index % 50));
          bool isHighRisk = risk >= 75;
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: Icon(Icons.inventory, color: isHighRisk ? Colors.red : Colors.green),
              title: Text('CARGO-${1000 + index}'),
              subtitle: Text('Destination: ${index % 2 == 0 ? 'Maitri' : 'Bharati'}\\nStatus: IN_TRANSIT'),
              trailing: CircularProgressIndicator(
                value: risk / 100, 
                color: isHighRisk ? Colors.red : (risk > 50 ? Colors.orange : Colors.green),
                backgroundColor: Colors.grey[800],
              ),
              onTap: () {
                // Navigate to detail
              },
            ),
          );
        },
      ),
    );
  }
}
""")

# Inventory List
write_file("screens/inventory/inventory_list_screen.dart", """import 'package:flutter/material.dart';

class InventoryListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inventory Status')),
      body: ListView.builder(
        itemCount: 100,
        itemBuilder: (context, index) {
          int qty = (50 + (index % 50));
          bool lowStock = qty < 60;
          return Card(
            color: lowStock ? Colors.red.withOpacity(0.1) : null,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text('Item $index'),
              subtitle: Text('Category: ${index % 3 == 0 ? "Food" : "Medical"} | Station: Maitri'),
              trailing: Chip(
                label: Text('$qty kg'),
                backgroundColor: lowStock ? Colors.red : Colors.green,
              ),
            ),
          );
        },
      ),
    );
  }
}
""")

# SOS Emergency Screen
write_file("screens/emergency/sos_screen.dart", """import 'package:flutter/material.dart';

class SosScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Emergency Response'), backgroundColor: Colors.red),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                _showConfirmDialog(context);
              },
              child: Container(
                width: 200, height: 200,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.redAccent, blurRadius: 30, spreadRadius: 10)]
                ),
                child: const Center(
                  child: Text('SOS', style: TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
            const SizedBox(height: 48),
            ElevatedButton.icon(
              icon: const Icon(Icons.mic),
              label: const Text('Voice SOS'),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Listening... Say "Fire in Lab 2"')));
              },
            )
          ],
        ),
      ),
    );
  }
  
  void _showConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Emergency'),
        content: const Text('Are you sure you want to trigger a station-wide SOS?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Emergency incident created. Response team dispatched.')));
            },
            child: const Text('CONFIRM SOS'),
          )
        ],
      )
    );
  }
}
""")

# Update main.dart to start at LoginScreen
write_file("main.dart", """import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'providers/app_state.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
      ],
      child: const PolarOpsApp(),
    ),
  );
}

class PolarOpsApp extends StatelessWidget {
  const PolarOpsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'POLAR-OPS',
      theme: ThemeData.dark().copyWith(
        primaryColor: const Color(0xFF0D47A1),
        scaffoldBackgroundColor: const Color(0xFF121212),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF1976D2),
          secondary: Color(0xFF00BFA5),
          error: Colors.red,
        ),
      ),
      home: LoginScreen(),
    );
  }
}
""")

# Update dashboard to link to the new screens
write_file("screens/dashboard_screen.dart", """import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import 'cargo_scanner_screen.dart';
import 'cargo/cargo_list_screen.dart';
import 'inventory/inventory_list_screen.dart';
import 'emergency/sos_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('POLAR-OPS Dashboard'),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: appState.isOffline ? Colors.orange.withOpacity(0.2) : Colors.green.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: appState.isOffline ? Colors.orange : Colors.green)
            ),
            child: Row(
              children: [
                Icon(appState.isOffline ? Icons.cloud_off : Icons.cloud_done, size: 16, color: appState.isOffline ? Colors.orange : Colors.green),
                const SizedBox(width: 4),
                Text(appState.isOffline ? 'Offline' : 'Online', style: TextStyle(color: appState.isOffline ? Colors.orange : Colors.green, fontSize: 12))
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () => context.read<AppState>().toggleOfflineMode(),
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async { await Future.delayed(const Duration(seconds: 1)); },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSummaryCards(context),
            const SizedBox(height: 24),
            const Text('Quick Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                _buildMenuCard(context, 'Cargo List', Icons.list_alt, CargoListScreen()),
                _buildMenuCard(context, 'Smart Scanner', Icons.qr_code_scanner, const CargoScannerScreen()),
                _buildMenuCard(context, 'Inventory', Icons.inventory, InventoryListScreen()),
                _buildMenuCard(context, 'Emergency SOS', Icons.warning, SosScreen(), color: Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _statCard('In Transit', '15', Colors.blue)),
        const SizedBox(width: 8),
        Expanded(child: _statCard('Low Stock', '12', Colors.orange)),
        const SizedBox(width: 8),
        Expanded(child: _statCard('Emergencies', '1', Colors.red)),
      ],
    );
  }

  Widget _statCard(String title, String count, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5))
      ),
      child: Column(
        children: [
          Text(count, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          Text(title, style: const TextStyle(fontSize: 12), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, String title, IconData icon, Widget? targetScreen, {Color? color}) {
    color ??= Theme.of(context).colorScheme.primary;
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: targetScreen != null 
            ? () => Navigator.push(context, MaterialPageRoute(builder: (_) => targetScreen))
            : null,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
""")

print("Successfully generated Flutter screens.")
