import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../theme/app_theme.dart';
import '../../services/api/api_client.dart';
import '../../widgets/components/state_widgets.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  bool _isLoading = true;
  String? _error;
  List<dynamic> _stations = [];
  List<dynamic> _trackers = [];

  @override
  void initState() {
    super.initState();
    _fetchStations();
  }

  Future<void> _fetchStations() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    final response = await ApiClient.get<List<dynamic>>('/stations');
    final trackersResponse = await ApiClient.get<List<dynamic>>('/trackers/active');

    if (mounted) {
      if (response.success && response.data != null) {
        setState(() {
          _stations = response.data!;
          if (trackersResponse.success && trackersResponse.data != null) {
            _trackers = trackersResponse.data!;
          }
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = response.error ?? 'Failed to load stations';
          _isLoading = false;
        });
      }
    }
  }

  void _showStationDetails(Map<String, dynamic> station) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.secondaryNavy,
        title: Text(station['name'] ?? 'Unknown Station',
            style: const TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Latitude: ${station['latitude']}',
                style: const TextStyle(color: AppTheme.textMuted)),
            Text('Longitude: ${station['longitude']}',
                style: const TextStyle(color: AppTheme.textMuted)),
            const SizedBox(height: 10),
            Text('Status: ${station['status']}',
                style: const TextStyle(color: AppTheme.statusHealthy)),
            const SizedBox(height: 10),
            Text(
                'Personnel Capacity: ${station['currentCapacity']}/${station['maxCapacity']}',
                style: const TextStyle(color: Colors.white)),
            Text('Type: ${station['type']}',
                style: const TextStyle(color: Colors.white)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close',
                style: TextStyle(color: AppTheme.accentCyan)),
          ),
        ],
      ),
    );
  }

  void _showTrackerDetails(Map<String, dynamic> tracker) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.secondaryNavy,
        title: const Text('Cargo Tracker', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Device ID: ${tracker['deviceId']}', style: const TextStyle(color: Colors.white)),
            Text('Cargo ID: ${tracker['cargoId']}', style: const TextStyle(color: Colors.white)),
            Text('Status: ${tracker['status']}', style: const TextStyle(color: AppTheme.statusWarning)),
            Text('Latitude: ${tracker['latitude']}', style: const TextStyle(color: AppTheme.textMuted)),
            Text('Longitude: ${tracker['longitude']}', style: const TextStyle(color: AppTheme.textMuted)),
            Text('Last Seen: ${tracker['lastSeen']}', style: const TextStyle(color: AppTheme.textMuted)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: AppTheme.accentCyan)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return StateWidgets.loadingState(
          message: 'Initializing Geospatial Subsystem...');
    }

    if (_error != null) {
      return StateWidgets.errorState(message: _error!, onRetry: _fetchStations);
    }

    return Stack(
      children: [
        FlutterMap(
          options: const MapOptions(
            initialCenter: LatLng(0, 0), // Equator
            initialZoom: 2.0,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'in.gov.moes.ncpor.polarops',
            ),
            MarkerLayer(
              markers: _stations
                  .map((s) {
                    final lat = s['latitude'] as double?;
                    final lng = s['longitude'] as double?;
                    if (lat == null || lng == null) return null;

                    return Marker(
                      point: LatLng(lat, lng),
                      width: 40,
                      height: 40,
                      child: GestureDetector(
                        onTap: () => _showStationDetails(s),
                        child: const Icon(
                          Icons.location_on,
                          color: AppTheme.accentCyan,
                          size: 40,
                        ),
                      ),
                    );
                  })
                  .whereType<Marker>()
                  .toList()
                ..addAll(_trackers.map((t) {
                  final lat = t['latitude'] as double?;
                  final lng = t['longitude'] as double?;
                  if (lat == null || lng == null) return null;

                  return Marker(
                    point: LatLng(lat, lng),
                    width: 40,
                    height: 40,
                    child: GestureDetector(
                      onTap: () => _showTrackerDetails(t),
                      child: const Icon(
                        Icons.local_shipping,
                        color: AppTheme.statusWarning,
                        size: 32,
                      ),
                    ),
                  );
                }).whereType<Marker>()),
            ),
          ],
        ),
        Positioned(
          top: 16,
          left: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
                color: AppTheme.secondaryNavy.withValues(alpha: .92),
                borderRadius: BorderRadius.circular(8)),
            child: const Row(children: [
              Icon(Icons.storage_outlined,
                  size: 16, color: AppTheme.accentCyan),
              SizedBox(width: 6),
              Text('DATABASE • STATION LOCATIONS',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
            ]),
          ),
        ),
      ],
    );
  }
}
