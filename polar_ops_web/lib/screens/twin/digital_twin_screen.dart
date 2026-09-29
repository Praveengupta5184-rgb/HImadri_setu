import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/api/api_client.dart';

class DigitalTwinScreen extends StatefulWidget {
  const DigitalTwinScreen({super.key});

  @override
  State<DigitalTwinScreen> createState() => _DigitalTwinScreenState();
}

class _DigitalTwinScreenState extends State<DigitalTwinScreen> {
  // Illustrative spatial layout. Details are retrieved from the digital-twin API.
  final List<Map<String, dynamic>> _mockAreas = [
    {
      "name": "Main Block A",
      "type": "Living",
      "x": 50.0,
      "y": 100.0,
      "w": 120.0,
      "h": 80.0
    },
    {
      "name": "Main Block B",
      "type": "Living",
      "x": 180.0,
      "y": 100.0,
      "w": 120.0,
      "h": 80.0
    },
    {
      "name": "Dining Hall",
      "type": "Common",
      "x": 50.0,
      "y": 190.0,
      "w": 250.0,
      "h": 60.0
    },
    {
      "name": "Generator Room 1",
      "type": "Utility",
      "x": 50.0,
      "y": 260.0,
      "w": 100.0,
      "h": 80.0
    },
    {
      "name": "Generator Room 2",
      "type": "Utility",
      "x": 160.0,
      "y": 260.0,
      "w": 100.0,
      "h": 80.0
    },
    {
      "name": "Lab Block",
      "type": "Science",
      "x": 320.0,
      "y": 100.0,
      "w": 100.0,
      "h": 150.0
    },
    {
      "name": "Vehicle Bay",
      "type": "Garage",
      "x": 440.0,
      "y": 100.0,
      "w": 120.0,
      "h": 150.0
    },
  ];

  Map<String, dynamic>? _selectedAreaDetails;
  String? _selectedAreaName;
  bool _isLoadingDetails = false;

  Future<void> _fetchAreaDetails(String areaName) async {
    setState(() {
      _selectedAreaName = areaName;
      _isLoadingDetails = true;
    });

    try {
      final response = await ApiClient.get('/twin/areas/$areaName/details');
      if (response.success && response.data != null) {
        setState(() {
          _selectedAreaDetails = response.data as Map<String, dynamic>;
        });
      }
    } catch (_) {
    } finally {
      setState(() {
        _isLoadingDetails = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Maitri Station — Digital Twin',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textMain)),
                  Text(
                      'DERIVED LAYOUT • DATABASE-BACKED AREA DETAILS • NOT A FLOOR PLAN',
                      style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.statusWarning,
                          letterSpacing: 1.0)),
                ],
              ),
              const Tooltip(
                message:
                    'Use Mission Simulator for available what-if scenarios.',
                child: Chip(
                  avatar: Icon(Icons.science_outlined,
                      size: 16, color: AppTheme.statusWarning),
                  label: Text('SIMULATION AVAILABLE IN MISSION SIMULATOR'),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingLg),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Card(
                    color: AppTheme.secondaryNavy,
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      children: [
                        // Background grid
                        Positioned.fill(
                          child: CustomPaint(
                            painter: GridPainter(),
                          ),
                        ),
                        // Render areas
                        ..._mockAreas.map((area) {
                          final isSelected = _selectedAreaName == area['name'];
                          return Positioned(
                            left: area['x'],
                            top: area['y'],
                            width: area['w'],
                            height: area['h'],
                            child: GestureDetector(
                              onTap: () => _fetchAreaDetails(area['name']),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppTheme.accentCyan
                                          .withValues(alpha: 0.4)
                                      : AppTheme.accentCyan
                                          .withValues(alpha: 0.1),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppTheme.accentCyan
                                        : AppTheme.accentCyan
                                            .withValues(alpha: 0.5),
                                    width: isSelected ? 2 : 1,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    area['name'],
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : AppTheme.accentCyan,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: AppTheme.spacingMd),
                Expanded(
                  flex: 1,
                  child: Card(
                    color: AppTheme.secondaryNavy,
                    child: Padding(
                      padding: const EdgeInsets.all(AppTheme.spacingMd),
                      child: _buildDetailsPanel(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsPanel() {
    if (_selectedAreaName == null) {
      return const Center(
          child: Text(
              'Select a module to retrieve its current database records.',
              style: TextStyle(color: AppTheme.textMuted)));
    }
    if (_isLoadingDetails) {
      return const Center(
          child: CircularProgressIndicator(color: AppTheme.accentCyan));
    }
    if (_selectedAreaDetails == null) {
      return const Center(
          child: Text(
              'Area details are unavailable. Select the area again to retry.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.statusWarning)));
    }

    final personnel =
        _selectedAreaDetails!['personnel'] as List<dynamic>? ?? [];
    final assets = _selectedAreaDetails!['assets'] as List<dynamic>? ?? [];
    final inventory =
        _selectedAreaDetails!['inventory'] as List<dynamic>? ?? [];
    final incidents =
        _selectedAreaDetails!['incidents'] as List<dynamic>? ?? [];

    bool isEmergency = incidents.isNotEmpty;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on,
                  color: isEmergency
                      ? AppTheme.statusCritical
                      : AppTheme.accentCyan),
              const SizedBox(width: 8),
              Expanded(
                  child: Text(_selectedAreaName!,
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textMain))),
            ],
          ),
          const Divider(color: AppTheme.textMuted),
          if (isEmergency) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              color: AppTheme.statusCritical.withValues(alpha: 0.2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('ACTIVE EMERGENCIES',
                      style: TextStyle(
                          color: AppTheme.statusCritical,
                          fontWeight: FontWeight.bold)),
                  ...incidents.map((inc) => Text('• ${inc['type']}',
                      style: const TextStyle(color: Colors.white))),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          _buildSection('Personnel (${personnel.length})', Icons.people,
              personnel.map((p) => '${p['name']} (${p['role']})').toList()),
          _buildSection(
              'Assets (${assets.length})',
              Icons.precision_manufacturing,
              assets.map((a) => '${a['name']} - ${a['condition']}').toList()),
          _buildSection(
              'Inventory (${inventory.length})',
              Icons.inventory_2,
              inventory
                  .map((i) =>
                      '${i['name']}: ${i['quantityAvailable']} ${i['unit']}')
                  .toList()),
        ],
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, List<String> items) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppTheme.textMuted),
              const SizedBox(width: 8),
              Text(title,
                  style: const TextStyle(
                      color: AppTheme.accentCyan, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          if (items.isEmpty)
            const Text('No records found.',
                style: TextStyle(color: AppTheme.textMuted, fontSize: 12))
          else
            ...items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text('• $item',
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 13)),
                )),
        ],
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.textMuted.withValues(alpha: 0.1)
      ..strokeWidth = 1;

    for (double i = 0; i < size.width; i += 20) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += 20) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
