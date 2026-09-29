import os

base_dir = "polar_ops_web"
dirs = [
    "lib",
    "lib/screens",
    "lib/screens/dashboard",
    "lib/screens/twin",
    "lib/screens/analytics",
    "lib/screens/reports",
    "lib/screens/chatbot",
    "lib/widgets",
]

for d in dirs:
    os.makedirs(os.path.join(base_dir, d), exist_ok=True)

def write_file(path, content):
    with open(os.path.join(base_dir, path), "w", encoding="utf-8") as f:
        f.write(content)

# 1. pubspec.yaml
write_file("pubspec.yaml", """name: polar_ops_web
description: POLAR-OPS Web Dashboard
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.1
  fl_chart: ^0.65.0
  syncfusion_flutter_charts: ^23.1.40
  pdf: ^3.10.7
  excel: ^3.0.1
  printing: ^5.11.1
  data_table_2: ^2.3.12
  flutter_svg: ^2.0.9
  universal_html: ^2.2.4
  web_socket_channel: ^2.4.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.4.7

flutter:
  uses-material-design: true
""")

# 2. main.dart
write_file("lib/main.dart", """import 'package:flutter/material.dart';
import 'screens/dashboard/web_dashboard_screen.dart';

void main() {
  runApp(const PolarOpsWebApp());
}

class PolarOpsWebApp extends StatelessWidget {
  const PolarOpsWebApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'POLAR-OPS Web Command Center',
      theme: ThemeData.dark().copyWith(
        primaryColor: const Color(0xFF0D47A1),
        scaffoldBackgroundColor: const Color(0xFF121212),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF1976D2),
          secondary: Color(0xFF00BFA5),
        ),
      ),
      home: const WebDashboardScreen(),
    );
  }
}
""")

# 3. Web Dashboard Screen
write_file("lib/screens/dashboard/web_dashboard_screen.dart", """import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../twin/digital_twin_screen.dart';
import '../analytics/analytics_screen.dart';
import '../reports/reports_screen.dart';
import '../chatbot/chatbot_widget.dart';

class WebDashboardScreen extends StatefulWidget {
  const WebDashboardScreen({super.key});

  @override
  State<WebDashboardScreen> createState() => _WebDashboardScreenState();
}

class _WebDashboardScreenState extends State<WebDashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() { _selectedIndex = index; });
            },
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(icon: Icon(Icons.dashboard), label: Text('Dashboard')),
              NavigationRailDestination(icon: Icon(Icons.view_in_ar), label: Text('3D Twin')),
              NavigationRailDestination(icon: Icon(Icons.analytics), label: Text('Analytics')),
              NavigationRailDestination(icon: Icon(Icons.picture_as_pdf), label: Text('Reports')),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          // Main Content
          Expanded(
            child: Stack(
              children: [
                _buildBody(),
                // Chatbot FAB Overlay
                Positioned(
                  bottom: 24,
                  right: 24,
                  child: FloatingActionButton(
                    onPressed: () {
                      showDialog(context: context, builder: (_) => const ChatbotWidget());
                    },
                    child: const Icon(Icons.chat),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0: return _buildDashboardContent();
      case 1: return const DigitalTwinScreen();
      case 2: return const AnalyticsScreen();
      case 3: return const ReportsScreen();
      default: return _buildDashboardContent();
    }
  }

  Widget _buildDashboardContent() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Command Center Overview', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _buildKpiCard('Active Expeditions', '1', Colors.blue)),
              Expanded(child: _buildKpiCard('Total Personnel', '25', Colors.green)),
              Expanded(child: _buildKpiCard('Cargo In-Transit', '15', Colors.orange)),
              Expanded(child: _buildKpiCard('Emergencies', '0', Colors.red)),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Text('Cargo Status Distribution'),
                          Expanded(
                            child: PieChart(
                              PieChartData(sections: [
                                PieChartSectionData(value: 40, title: 'Received', color: Colors.blue),
                                PieChartSectionData(value: 30, title: 'In-Transit', color: Colors.orange),
                                PieChartSectionData(value: 30, title: 'Delivered', color: Colors.green),
                              ]),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Text('Inventory Consumption (30 Days)'),
                          Expanded(
                            child: LineChart(
                              LineChartData(
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: const [FlSpot(0, 100), FlSpot(1, 80), FlSpot(2, 60), FlSpot(3, 40)],
                                    isCurved: true,
                                    color: Colors.redAccent,
                                  )
                                ]
                              )
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildKpiCard(String title, String val, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text(val, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: color)),
            Text(title, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
""")

# 4. Digital Twin Screen
write_file("lib/screens/twin/digital_twin_screen.dart", """import 'package:flutter/material.dart';

class DigitalTwinScreen extends StatefulWidget {
  const DigitalTwinScreen({super.key});

  @override
  State<DigitalTwinScreen> createState() => _DigitalTwinScreenState();
}

class _DigitalTwinScreenState extends State<DigitalTwinScreen> {
  String? selectedRoom;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('3D Digital Twin - Maitri Station', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
                    child: Stack(
                      children: [
                        Center(child: Text('Interactive 3D Canvas rendering...\\n(Requires WebGL)', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600]))),
                        // Mock 2D representation of the 3D map for demo
                        Positioned(top: 50, left: 50, child: _buildRoomNode('Lab 1', Colors.green)),
                        Positioned(top: 150, left: 50, child: _buildRoomNode('Main Storage', Colors.red)),
                        Positioned(top: 50, left: 250, child: _buildRoomNode('Living Quarters', Colors.green)),
                        Positioned(top: 150, left: 250, child: _buildRoomNode('Medical Bay', Colors.orange)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  flex: 1,
                  child: selectedRoom == null 
                    ? const Center(child: Text('Select a room on the map')) 
                    : _buildRoomDetails(),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildRoomNode(String name, Color statusColor) {
    return InkWell(
      onTap: () {
        setState(() { selectedRoom = name; });
      },
      child: Container(
        width: 150, height: 80,
        decoration: BoxDecoration(
          color: statusColor.withOpacity(0.2),
          border: Border.all(color: statusColor, width: 2),
          borderRadius: BorderRadius.circular(8)
        ),
        child: Center(child: Text(name, style: const TextStyle(fontWeight: FontWeight.bold))),
      ),
    );
  }

  Widget _buildRoomDetails() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Room: $selectedRoom', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const Divider(),
            const Text('Inventory Levels:', style: TextStyle(fontWeight: FontWeight.bold)),
            const LinearProgressIndicator(value: 0.3, color: Colors.red, backgroundColor: Colors.grey),
            const SizedBox(height: 16),
            const Text('Personnel: 2', style: TextStyle(fontWeight: FontWeight.bold)),
            const ListTile(leading: Icon(Icons.person), title: Text('Dr. Sharma')),
            const ListTile(leading: Icon(Icons.person), title: Text('Eng. Kumar')),
            const Divider(),
            const Text('Emergency Equipment:', style: TextStyle(fontWeight: FontWeight.bold)),
            const Text('✅ Fire Extinguisher (Inspected)\\n✅ Medical Kit (Fully Stocked)'),
            const Spacer(),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Highlight Evacuation Route'),
            )
          ],
        ),
      ),
    );
  }
}
""")

# 5. Analytics Screen
write_file("lib/screens/analytics/analytics_screen.dart", """import 'package:flutter/material.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Advanced Analytics & syncfusion_flutter_charts go here'));
  }
}
""")

# 6. Reports Screen
write_file("lib/screens/reports/reports_screen.dart", """import 'package:flutter/material.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Report Generation Center', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          ListTile(
            leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
            title: const Text('Expedition Summary Report'),
            trailing: ElevatedButton(onPressed: () {}, child: const Text('Generate PDF')),
          ),
          ListTile(
            leading: const Icon(Icons.table_chart, color: Colors.green),
            title: const Text('Cargo Manifest'),
            trailing: ElevatedButton(onPressed: () {}, child: const Text('Export Excel')),
          ),
        ],
      ),
    );
  }
}
""")

# 7. Chatbot Widget
write_file("lib/screens/chatbot/chatbot_widget.dart", """import 'package:flutter/material.dart';

class ChatbotWidget extends StatefulWidget {
  const ChatbotWidget({super.key});

  @override
  State<ChatbotWidget> createState() => _ChatbotWidgetState();
}

class _ChatbotWidgetState extends State<ChatbotWidget> {
  final TextEditingController _ctrl = TextEditingController();
  final List<String> _msgs = ["System: Hello! How can I assist you with POLAR-OPS today?"];

  void _send() {
    if (_ctrl.text.isEmpty) return;
    setState(() {
      _msgs.add("You: ${_ctrl.text}");
      if (_ctrl.text.toLowerCase().contains("cargo")) {
        _msgs.add("Bot: CARGO-1042 is currently at Maitri Station. Status: DELIVERED.");
      } else {
        _msgs.add("Bot: Acknowledged. I am processing your request.");
      }
      _ctrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SizedBox(
        width: 400, height: 600,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: Theme.of(context).primaryColor,
              child: const Row(
                children: [
                  Icon(Icons.smart_toy, color: Colors.white),
                  SizedBox(width: 8),
                  Text('POLAR-AI Assistant', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _msgs.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(_msgs[index], style: TextStyle(color: _msgs[index].startsWith("You") ? Colors.blue : Colors.white)),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _ctrl,
                      decoration: const InputDecoration(hintText: 'Type "Where is cargo..."', border: OutlineInputBorder()),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  IconButton(icon: const Icon(Icons.send), onPressed: _send),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
""")

print("Successfully generated Flutter Web project structure.")
