import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
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
  Map<String, dynamic>? _metrics;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    final incidentsRes = await ApiClient.get('/emergencies');
    final metricsRes = await ApiClient.get('/emergencies/dashboard');
    if (!mounted) return;
    setState(() {
      _incidents = incidentsRes.success && incidentsRes.data != null
          ? incidentsRes.data as List<dynamic>
          : [];
      // Sort so newest is first
      _incidents.sort((a, b) {
        final dateA = a['createdAt'] ?? a['reportedAt'] ?? '';
        final dateB = b['createdAt'] ?? b['reportedAt'] ?? '';
        return dateB.compareTo(dateA);
      });
      _metrics = metricsRes.success && metricsRes.data != null
          ? metricsRes.data as Map<String, dynamic>
          : null;
      _isLoading = false;
    });
  }

  Future<void> _triggerSOS() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Dispatch SOS?'),
        content: const Text(
            'This creates a critical incident in the command system. This action will alert all authorized personnel.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('CANCEL')),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.statusCritical),
              child: const Text('DISPATCH SOS', style: TextStyle(color: Colors.white))),
        ],
      ),
    );
    if (confirmed != true) return;

    double? lat;
    double? lng;
    String locationSource = "SOS";
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission != LocationPermission.denied && permission != LocationPermission.deniedForever) {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 10),
        );
        lat = position.latitude;
        lng = position.longitude;
        locationSource = "DEVICE_GPS";
      }
    } catch (e) {
      // Ignore GPS failure and proceed with SOS
    }

    final payload = {
      "type": "SOS",
      "severity": "CRITICAL",
      "location": lat != null && lng != null ? "${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}" : "Unknown",
      "latitude": lat,
      "longitude": lng,
      "locationSource": locationSource,
      "reportedBy": "CurrentUser",
      "description": "Immediate emergency reported via SOS button."
    };

    final response = await ApiClient.post('/emergencies', payload);
    if (response.success) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(lat != null ? 'SOS Dispatched with Location' : 'SOS Dispatched. Location unavailable.'),
        backgroundColor: AppTheme.statusCritical,
      ));
      _fetchData();
    }
  }

  Future<void> _updateStatus(int incidentId, String newStatus, String notes) async {
    final payload = {
      "status": newStatus,
      "performedBy": "CurrentUser",
      "notes": notes
    };
    await ApiClient.put('/emergencies/$incidentId/status', payload);
    _fetchData();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'REPORTED': return AppTheme.statusCritical;
      case 'ACKNOWLEDGED': return AppTheme.statusWarning;
      case 'ASSIGNED': return Colors.orange;
      case 'EN_ROUTE': return AppTheme.statusNeutral;
      case 'ON_SCENE': return AppTheme.accentCyan;
      case 'RESOLVED': return AppTheme.statusHealthy;
      default: return AppTheme.textMuted;
    }
  }

  Widget _buildMetricCard(String title, String value, Color color) {
    return Expanded(
      child: Card(
        color: AppTheme.secondaryNavy,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
              const SizedBox(height: 8),
              Text(value, style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  void _showCreateEmergencyDialog() {
    String type = 'Other';
    String severity = 'MEDIUM';
    String description = '';
    int peopleAffected = 0;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: AppTheme.primaryNavy,
              title: const Text('Create Emergency Incident', style: TextStyle(color: AppTheme.textMain)),
              content: SizedBox(
                width: 400,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<String>(
                        value: type,
                        dropdownColor: AppTheme.secondaryNavy,
                        style: const TextStyle(color: AppTheme.textMain),
                        decoration: const InputDecoration(labelText: 'Type'),
                        items: ['Medical', 'Fire', 'Accident / Injury', 'Missing Personnel', 'Severe Weather', 'Vehicle / Transport Failure', 'Equipment Failure', 'Station Incident', 'Other']
                            .map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                        onChanged: (v) => setState(() => type = v!),
                      ),
                      DropdownButtonFormField<String>(
                        value: severity,
                        dropdownColor: AppTheme.secondaryNavy,
                        style: const TextStyle(color: AppTheme.textMain),
                        decoration: const InputDecoration(labelText: 'Severity'),
                        items: ['LOW', 'MEDIUM', 'HIGH', 'CRITICAL']
                            .map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                        onChanged: (v) => setState(() => severity = v!),
                      ),
                      TextFormField(
                        initialValue: peopleAffected.toString(),
                        style: const TextStyle(color: AppTheme.textMain),
                        decoration: const InputDecoration(labelText: 'People Affected'),
                        keyboardType: TextInputType.number,
                        onChanged: (v) => peopleAffected = int.tryParse(v) ?? 0,
                      ),
                      TextFormField(
                        style: const TextStyle(color: AppTheme.textMain),
                        decoration: const InputDecoration(labelText: 'Description'),
                        maxLines: 3,
                        onChanged: (v) => description = v,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('CANCEL'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    final payload = {
                      "type": type,
                      "severity": severity,
                      "peopleAffected": peopleAffected,
                      "description": description,
                      "locationSource": "MANUAL",
                      "reportedBy": "CurrentUser"
                    };
                    await ApiClient.post('/emergencies', payload);
                    _fetchData();
                  },
                  child: const Text('CREATE EMERGENCY'),
                ),
              ],
            );
          },
        );
      },
    );
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
              const Text('Emergency Operations',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textMain)),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _showCreateEmergencyDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Create Emergency'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.secondaryNavy,
                      foregroundColor: AppTheme.textMain,
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingMd),
                  ElevatedButton.icon(
                    onPressed: _fetchData,
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
                    label: const Text('🔴 SEND SOS'),
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
          if (_metrics != null)
            Row(
              children: [
                _buildMetricCard('Active Emergencies', "${_metrics!['activeEmergencies'] ?? 0}", AppTheme.statusCritical),
                _buildMetricCard('High Priority', "${_metrics!['highPriority'] ?? 0}", Colors.orange),
                _buildMetricCard('Pending Response', "${_metrics!['pendingResponse'] ?? 0}", AppTheme.statusWarning),
                _buildMetricCard('Resolved Today', "${_metrics!['resolvedToday'] ?? 0}", AppTheme.statusHealthy),
                _buildMetricCard('Personnel At Risk', "${_metrics!['personnelAtRisk'] ?? 0}", Colors.redAccent),
              ],
            ),
          const SizedBox(height: AppTheme.spacingLg),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Card(
                    color: AppTheme.secondaryNavy,
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator(color: AppTheme.accentCyan))
                        : _incidents.isEmpty
                            ? const Center(child: Text('No active emergencies.', style: TextStyle(color: AppTheme.textMuted)))
                            : ListView.builder(
                                itemCount: _incidents.length,
                                itemBuilder: (context, index) {
                                  final inc = _incidents[index];
                                  final status = inc['status'] ?? 'UNKNOWN';
                                  final emergencyId = inc['emergencyId'] ?? 'ID_${inc['incidentId']}';
                                  return ListTile(
                                    title: Text('$emergencyId - ${inc['type']}', style: const TextStyle(color: AppTheme.textMain, fontWeight: FontWeight.bold)),
                                    subtitle: Text('Location: ${inc['location'] ?? 'Unknown'} | Reported: ${inc['reportedAt'] ?? inc['createdAt'] ?? '-'}', style: const TextStyle(color: AppTheme.textMuted)),
                                    trailing: StatusBadge(label: status, color: _getStatusColor(status)),
                                    onTap: () => _showIncidentDetails(inc),
                                  );
                                },
                              ),
                  ),
                ),
                const SizedBox(width: AppTheme.spacingLg),
                Expanded(
                  flex: 3,
                  child: Card(
                    color: AppTheme.secondaryNavy,
                    clipBehavior: Clip.antiAlias,
                    child: FlutterMap(
                      options: MapOptions(
                        initialCenter: const LatLng(-70.7667, 11.7333),
                        initialZoom: 10.0,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        ),
                        MarkerLayer(
                          markers: _incidents.where((i) => i['latitude'] != null && i['longitude'] != null).map((i) {
                            return Marker(
                              point: LatLng(i['latitude'], i['longitude']),
                              width: 40,
                              height: 40,
                              child: GestureDetector(
                                onTap: () => _showIncidentDetails(i),
                                child: const Icon(Icons.location_on, color: AppTheme.statusCritical, size: 40),
                              ),
                            );
                          }).toList(),
                        ),
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
          title: Text('${incident['emergencyId'] ?? 'Incident'} - ${incident['type']}', style: const TextStyle(color: AppTheme.textMain)),
          content: SizedBox(
            width: 800,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Severity: ${incident['severity']}', style: const TextStyle(color: Colors.white70)),
                        Text('Status: ${incident['status']}', style: TextStyle(color: _getStatusColor(incident['status'] ?? ''))),
                        Text('Location: ${incident['location'] ?? 'Unknown'}', style: const TextStyle(color: Colors.white70)),
                        Text('Reporter: ${incident['reportedBy'] ?? 'Unknown'}', style: const TextStyle(color: Colors.white70)),
                        Text('Created: ${incident['createdAt'] ?? incident['reportedAt'] ?? 'Unknown'}', style: const TextStyle(color: Colors.white70)),
                        if (incident['peopleAffected'] != null) Text('People Affected: ${incident['peopleAffected']}', style: const TextStyle(color: Colors.white70)),
                        const SizedBox(height: 16),
                        const Text('Description:', style: TextStyle(color: AppTheme.textMain, fontWeight: FontWeight.bold)),
                        Text('${incident['description'] ?? 'No description.'}', style: const TextStyle(color: Colors.white70)),
                        if (incident['resolution'] != null) ...[
                          const SizedBox(height: 16),
                          const Text('Resolution:', style: TextStyle(color: AppTheme.statusHealthy, fontWeight: FontWeight.bold)),
                          Text('${incident['resolution']}', style: const TextStyle(color: Colors.white70)),
                        ],
                        const SizedBox(height: 16),
                        const Text('Audit Timeline:', style: TextStyle(color: AppTheme.textMain, fontWeight: FontWeight.bold)),
                        ...history.map((h) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Text('• ${h['timestamp']}: ${h['action']} (by ${h['performedBy']})', style: const TextStyle(color: AppTheme.accentCyan, fontSize: 12)),
                            )),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            if (incident['status'] == 'REPORTED')
              TextButton(
                onPressed: () {
                  _updateStatus(incident['incidentId'], 'ACKNOWLEDGED', 'Incident recognized');
                  Navigator.pop(context);
                },
                child: const Text('ACKNOWLEDGE', style: TextStyle(color: AppTheme.statusWarning)),
              ),
            if (incident['status'] == 'ACKNOWLEDGED')
              TextButton(
                onPressed: () {
                  _updateStatus(incident['incidentId'], 'ASSIGNED', 'Assigned Response Team');
                  Navigator.pop(context);
                },
                child: const Text('ASSIGN RESPONSE', style: TextStyle(color: Colors.orange)),
              ),
            if (incident['status'] == 'ASSIGNED')
              TextButton(
                onPressed: () {
                  _updateStatus(incident['incidentId'], 'EN_ROUTE', 'Response team is en route');
                  Navigator.pop(context);
                },
                child: const Text('MARK EN ROUTE', style: TextStyle(color: AppTheme.statusNeutral)),
              ),
            if (incident['status'] == 'EN_ROUTE')
              TextButton(
                onPressed: () {
                  _updateStatus(incident['incidentId'], 'ON_SCENE', 'Response team arrived on scene');
                  Navigator.pop(context);
                },
                child: const Text('MARK ON SCENE', style: TextStyle(color: AppTheme.accentCyan)),
              ),
            if (incident['status'] == 'ON_SCENE' || incident['status'] == 'CONTAINED')
              TextButton(
                onPressed: () {
                  _updateStatus(incident['incidentId'], 'RESOLVED', 'Emergency resolved');
                  Navigator.pop(context);
                },
                child: const Text('RESOLVE', style: TextStyle(color: AppTheme.statusHealthy)),
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
