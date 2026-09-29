import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../theme/app_theme.dart';
import '../../widgets/components/status_badge.dart';
import '../../services/api/api_client.dart';

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  List<dynamic> _incidents = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchIncidents();
  }

  Future<void> _fetchIncidents() async {
    setState(() => _isLoading = true);
    final response = await ApiClient.get('/emergencies');
    if (!mounted) return;
    setState(() {
      _incidents = response.success && response.data != null
          ? response.data as List<dynamic>
          : [];
      _isLoading = false;
    });
  }

  Future<void> _triggerSOS() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Dispatch SOS?'),
        content: const Text(
            'This creates a critical incident in the command system.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('CANCEL')),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('DISPATCH SOS')),
        ],
      ),
    );
    if (confirmed != true) return;
    final payload = {
      "type": "SOS / CRITICAL",
      "severity": "CRITICAL",
      "location": "Maitri Station Area",
      "reportedBy": "Cmdr. Sharma",
      "description": "Immediate emergency reported via SOS button."
    };

    final response = await ApiClient.post('/emergencies', payload);
    if (response.success) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('SOS Dispatched Successfully'),
        backgroundColor: AppTheme.statusCritical,
      ));
      _fetchIncidents();
    }
  }

  Future<void> _updateStatus(
      int incidentId, String newStatus, String notes) async {
    final payload = {
      "status": newStatus,
      "performedBy": "Cmdr. Sharma",
      "notes": notes
    };
    await ApiClient.put('/emergencies/$incidentId/status', payload);
    _fetchIncidents();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'REPORTED':
        return AppTheme.statusCritical;
      case 'ACKNOWLEDGED':
        return AppTheme.statusWarning;
      case 'RESPONDING':
        return AppTheme.statusNeutral;
      case 'CONTAINED':
        return Colors.lightGreen;
      case 'RESOLVED':
        return AppTheme.statusHealthy;
      default:
        return AppTheme.textMuted;
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
              const Text('Emergency Operations Center',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textMain)),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _fetchIncidents,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.secondaryNavy,
                      foregroundColor: AppTheme.accentCyan,
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingMd),
                  ElevatedButton.icon(
                    onPressed: _triggerSOS,
                    icon: const Icon(Icons.warning_amber_rounded),
                    label: const Text('TRIGGER SOS'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.statusCritical,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingLg),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Card(
                    color: AppTheme.secondaryNavy,
                    child: _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                                color: AppTheme.accentCyan))
                        : ListView.builder(
                            itemCount: _incidents.length,
                            itemBuilder: (context, index) {
                              final inc = _incidents[index];
                              final status = inc['status'] ?? 'UNKNOWN';
                              return ListTile(
                                title: Text(
                                    '${inc['type']} - ${inc['location']}',
                                    style: const TextStyle(
                                        color: AppTheme.textMain)),
                                subtitle: Text(
                                    'Reported: ${inc['reportedAt'] ?? '-'}',
                                    style: const TextStyle(
                                        color: AppTheme.textMuted)),
                                trailing: StatusBadge(
                                    label: status,
                                    color: _getStatusColor(status)),
                                onTap: () => _showIncidentDetails(inc),
                              );
                            },
                          ),
                  ),
                ),
                const SizedBox(width: AppTheme.spacingLg),
                Expanded(
                  flex: 2,
                  child: Card(
                    color: AppTheme.secondaryNavy,
                    clipBehavior: Clip.antiAlias,
                    child: FlutterMap(
                      options: const MapOptions(
                        initialCenter:
                            LatLng(-70.7667, 11.7333), // Maitri Station
                        initialZoom: 10.0,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        ),
                        const MarkerLayer(markers: []),
                      ],
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

  void _showIncidentDetails(dynamic incident) {
    showDialog(
      context: context,
      builder: (context) {
        final history = incident['auditHistory'] as List<dynamic>? ?? [];
        return AlertDialog(
          backgroundColor: AppTheme.primaryNavy,
          title: Text(
              'Incident #${incident['incidentId']} - ${incident['type']}',
              style: const TextStyle(color: AppTheme.textMain)),
          content: SizedBox(
            width: 600,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Location: ${incident['location']}',
                      style: const TextStyle(color: Colors.white70)),
                  Text('Severity: ${incident['severity']}',
                      style: const TextStyle(color: Colors.white70)),
                  Text('Reported By: ${incident['reportedBy']}',
                      style: const TextStyle(color: Colors.white70)),
                  const SizedBox(height: 16),
                  const Text('Description:',
                      style: TextStyle(
                          color: AppTheme.textMain,
                          fontWeight: FontWeight.bold)),
                  Text('${incident['description']}',
                      style: const TextStyle(color: Colors.white70)),
                  const SizedBox(height: 16),
                  const Text('Audit History:',
                      style: TextStyle(
                          color: AppTheme.textMain,
                          fontWeight: FontWeight.bold)),
                  ...history.map((h) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                            '• ${h['timestamp']}: ${h['action']} (by ${h['performedBy']})',
                            style: const TextStyle(
                                color: AppTheme.accentCyan, fontSize: 12)),
                      )),
                ],
              ),
            ),
          ),
          actions: [
            if (incident['status'] == 'REPORTED')
              TextButton(
                onPressed: () {
                  _updateStatus(incident['incidentId'], 'ACKNOWLEDGED',
                      'Incident recognized');
                  Navigator.pop(context);
                },
                child: const Text('ACKNOWLEDGE',
                    style: TextStyle(color: AppTheme.statusWarning)),
              ),
            if (incident['status'] == 'ACKNOWLEDGED')
              TextButton(
                onPressed: () {
                  _updateStatus(incident['incidentId'], 'RESPONDING',
                      'Deployed response team');
                  Navigator.pop(context);
                },
                child: const Text('DEPLOY RESPONSE',
                    style: TextStyle(color: AppTheme.statusNeutral)),
              ),
            if (incident['status'] == 'RESPONDING')
              TextButton(
                onPressed: () {
                  _updateStatus(
                      incident['incidentId'], 'CONTAINED', 'Threat contained');
                  Navigator.pop(context);
                },
                child: const Text('MARK CONTAINED',
                    style: TextStyle(color: Colors.lightGreen)),
              ),
            if (incident['status'] == 'CONTAINED')
              TextButton(
                onPressed: () {
                  _updateStatus(
                      incident['incidentId'], 'RESOLVED', 'All clear');
                  Navigator.pop(context);
                },
                child: const Text('RESOLVE INCIDENT',
                    style: TextStyle(color: AppTheme.statusHealthy)),
              ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CLOSE'),
            ),
          ],
        );
      },
    );
  }
}
