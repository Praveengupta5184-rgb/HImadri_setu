import os

base_dir = "polar_ops_app"
dirs = [
    "lib",
    "lib/models",
    "lib/providers",
    "lib/screens",
    "lib/services",
    "lib/utils",
    "lib/widgets",
]

for d in dirs:
    os.makedirs(os.path.join(base_dir, d), exist_ok=True)

def write_file(path, content):
    with open(os.path.join(base_dir, path), "w", encoding="utf-8") as f:
        f.write(content)

# 1. pubspec.yaml
write_file("pubspec.yaml", """name: polar_ops_app
description: POLAR-OPS Mobile App
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.1
  dio: ^5.4.0
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  mobile_scanner: ^3.5.2
  google_mlkit_text_recognition: ^0.11.0
  flutter_map: ^6.0.1
  geolocator: ^10.1.0
  speech_to_text: ^6.5.1
  firebase_messaging: ^14.7.10
  firebase_core: ^2.24.2
  path_provider: ^2.1.2
  permission_handler: ^11.2.0
  shared_preferences: ^2.2.2
  pdf: ^3.10.7
  excel: ^3.0.1
  printing: ^5.11.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.4.7
  hive_generator: ^2.0.1

flutter:
  uses-material-design: true
""")

# 2. lib/main.dart
write_file("lib/main.dart", """import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'providers/app_state.dart';
import 'screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  // await Firebase.initializeApp(); // Uncomment when google-services.json is added
  
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
        ),
      ),
      home: const DashboardScreen(),
    );
  }
}
""")

# 3. lib/providers/app_state.dart
write_file("lib/providers/app_state.dart", """import 'package:flutter/material.dart';

class AppState extends ChangeNotifier {
  bool isOffline = true;
  String currentStation = "Maitri";

  void toggleOfflineMode() {
    isOffline = !isOffline;
    notifyListeners();
  }
}
""")

# 4. lib/screens/dashboard_screen.dart
write_file("lib/screens/dashboard_screen.dart", """import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import 'cargo_scanner_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('POLAR-OPS Dashboard'),
        actions: [
          IconButton(
            icon: Icon(appState.isOffline ? Icons.cloud_off : Icons.cloud_done),
            color: appState.isOffline ? Colors.orange : Colors.green,
            onPressed: () => context.read<AppState>().toggleOfflineMode(),
          )
        ],
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: [
          _buildMenuCard(context, 'Smart Scanner', Icons.qr_code_scanner, const CargoScannerScreen()),
          _buildMenuCard(context, 'Inventory', Icons.inventory, null),
          _buildMenuCard(context, 'Voice SOS', Icons.mic, null),
          _buildMenuCard(context, 'Station Map', Icons.map, null),
        ],
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, String title, IconData icon, Widget? targetScreen) {
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
            Icon(icon, size: 48, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
""")

# 5. lib/screens/cargo_scanner_screen.dart
write_file("lib/screens/cargo_scanner_screen.dart", """import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class CargoScannerScreen extends StatefulWidget {
  const CargoScannerScreen({super.key});

  @override
  State<CargoScannerScreen> createState() => _CargoScannerScreenState();
}

class _CargoScannerScreenState extends State<CargoScannerScreen> {
  String? scanResult;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cargo Scanner')),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: MobileScanner(
              onDetect: (capture) {
                final List<Barcode> barcodes = capture.barcodes;
                for (final barcode in barcodes) {
                  if (barcode.rawValue != null && scanResult != barcode.rawValue) {
                    setState(() {
                      scanResult = barcode.rawValue;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Scanned: ${barcode.rawValue}')),
                    );
                  }
                }
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(24),
              width: double.infinity,
              color: Colors.black87,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Scan Cargo Label (QR/Barcode)'),
                  const SizedBox(height: 16),
                  Text(
                    scanResult ?? 'Waiting for scan...',
                    style: TextStyle(
                      fontSize: 18, 
                      color: scanResult != null ? Colors.green : Colors.grey,
                      fontWeight: FontWeight.bold
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
""")

# 6. lib/services/api_service.dart
write_file("lib/services/api_service.dart", """import 'package:dio/dio.dart';

class ApiService {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://localhost:8080/api/v1'));

  Future<dynamic> getCargoDetails(String id) async {
    try {
      final response = await _dio.get('/cargo/$id');
      return response.data;
    } catch (e) {
      print('API Error: $e');
      return null;
    }
  }
}
""")

print("Successfully generated Flutter project.")
