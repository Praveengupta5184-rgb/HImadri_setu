import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:universal_html/html.dart' as html;
import '../../theme/app_theme.dart';
import '../../services/api/mission_service.dart';
import '../../services/auth/auth_service.dart';

enum _GpsState { idle, requesting, active, denied, unavailable, sent, error }

class MissionMapPanel extends StatefulWidget {
  final String missionCode;
  final List<dynamic> locations;
  final VoidCallback onRefresh;

  const MissionMapPanel({
    super.key,
    required this.missionCode,
    required this.locations,
    required this.onRefresh,
  });

  @override
  State<MissionMapPanel> createState() => _MissionMapPanelState();
}

class _MissionMapPanelState extends State<MissionMapPanel> {
  _GpsState _gpsState = _GpsState.idle;
  String _gpsMessage = 'GPS not active';
  double? _lastLat;
  double? _lastLng;
  DateTime? _lastLocationTime;

  // personnelId of the currently authenticated user, resolved from members list.
  int? _myPersonnelId;

  @override
  void initState() {
    super.initState();
    _resolvePersonnelId();
  }

  @override
  void didUpdateWidget(MissionMapPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.locations != widget.locations) {
      _resolvePersonnelId();
    }
  }

  void _resolvePersonnelId() {
    // locations list contains personnel objects. If one matches the
    // current auth role/email, we can extract the personnel id.
    // For now leave null — users who are FIELD_OPERATOR and active
    // members will see the submit button disabled with a clear message
    // until we have the personnel→user linkage surfaced by the backend.
    // Officers can monitor the map without submitting their own location.
  }

  Future<void> _requestGps() async {
    setState(() {
      _gpsState = _GpsState.requesting;
      _gpsMessage = 'Requesting GPS permission from browser...';
    });

    try {
      final geolocation = html.window.navigator.geolocation;

      geolocation.getCurrentPosition(
        timeout: const Duration(seconds: 10),
        enableHighAccuracy: true,
      ).then((pos) {
        if (!mounted) return;
        setState(() {
          _lastLat = pos.coords!.latitude!.toDouble();
          _lastLng = pos.coords!.longitude!.toDouble();
          _lastLocationTime = DateTime.now();
          _gpsState = _GpsState.active;
          _gpsMessage = 'GPS active — real coordinates received';
        });
      }).catchError((e) {
        if (!mounted) return;
        final errMsg = e.toString();
        if (errMsg.contains('1') || errMsg.toLowerCase().contains('denied')) {
          setState(() {
            _gpsState = _GpsState.denied;
            _gpsMessage = 'GPS permission denied by user.';
          });
        } else if (errMsg.contains('2')) {
          setState(() {
            _gpsState = _GpsState.unavailable;
            _gpsMessage = 'Position unavailable — check device GPS.';
          });
        } else {
          setState(() {
            _gpsState = _GpsState.error;
            _gpsMessage = 'GPS error: $errMsg';
          });
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _gpsState = _GpsState.unavailable;
          _gpsMessage = 'Geolocation not supported in this browser.';
        });
      }
    }
  }

  Future<void> _submitLocation() async {
    if (_lastLat == null || _lastLng == null) return;

    if (_myPersonnelId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Personnel ID not resolved. Ensure you are an active member of this mission.'),
            backgroundColor: AppTheme.statusWarning,
          ),
        );
      }
      return;
    }

    setState(() {
      _gpsState = _GpsState.requesting;
      _gpsMessage = 'Submitting location to backend...';
    });

    final res = await MissionService.submitLocation(
      widget.missionCode,
      _myPersonnelId!,
      _lastLat!,
      _lastLng!,
      'MOVING',
    );

    if (!mounted) return;

    if (res.success) {
      setState(() {
        _gpsState = _GpsState.sent;
        _gpsMessage = 'Location submitted successfully.';
      });
      widget.onRefresh();
    } else {
      setState(() {
        _gpsState = _GpsState.error;
        _gpsMessage = res.error ?? 'Submission failed.';
      });
    }
  }

  Color _freshnessColor(String? freshness) {
    switch (freshness) {
      case 'LIVE':
        return AppTheme.statusHealthy;
      case 'RECENT':
        return AppTheme.accentCyan;
      case 'STALE':
        return AppTheme.statusWarning;
      case 'OFFLINE':
        return AppTheme.statusCritical;
      default:
        return AppTheme.textMuted;
    }
  }

  IconData _freshnessIcon(String? freshness) {
    switch (freshness) {
      case 'LIVE':
        return Icons.gps_fixed;
      case 'RECENT':
        return Icons.gps_not_fixed;
      case 'STALE':
        return Icons.signal_wifi_statusbar_connected_no_internet_4;
      case 'OFFLINE':
        return Icons.gps_off;
      default:
        return Icons.location_off;
    }
  }

  Widget _buildGpsPanel() {
    final isOfficer = AuthService.hasRole([
      'ADMIN',
      'MISSION_OFFICER',
      'STATION_OFFICER',
      'LOGISTICS_OFFICER',
    ]);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('YOUR LOCATION',
                style: TextStyle(
                    color: AppTheme.accentCyan,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1)),
            const SizedBox(height: 8),
            Row(children: [
              Icon(_gpsIconForState(), size: 18, color: _gpsColorForState()),
              const SizedBox(width: 6),
              Expanded(
                  child: Text(_gpsMessage,
                      style:
                          TextStyle(color: _gpsColorForState(), fontSize: 12))),
            ]),
            if (_lastLat != null) ...[
              const SizedBox(height: 4),
              Text(
                  '${_lastLat!.toStringAsFixed(6)}, ${_lastLng!.toStringAsFixed(6)}',
                  style: const TextStyle(
                      color: AppTheme.textMuted, fontSize: 11)),
              if (_lastLocationTime != null)
                Text('At: ${_lastLocationTime!.toLocal()}',
                    style: const TextStyle(
                        color: AppTheme.textMuted, fontSize: 10)),
            ],
            const SizedBox(height: 8),
            Wrap(spacing: 8, children: [
              OutlinedButton.icon(
                onPressed:
                    _gpsState == _GpsState.requesting ? null : _requestGps,
                icon: const Icon(Icons.gps_fixed, size: 14),
                label: const Text('GET GPS', style: TextStyle(fontSize: 11)),
              ),
              if (_lastLat != null && !isOfficer)
                ElevatedButton.icon(
                  onPressed: _gpsState == _GpsState.requesting
                      ? null
                      : _submitLocation,
                  icon: const Icon(Icons.upload, size: 14),
                  label:
                      const Text('SUBMIT', style: TextStyle(fontSize: 11)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentCyan,
                    foregroundColor: AppTheme.primaryNavy,
                  ),
                ),
            ]),
            const SizedBox(height: 4),
            const Text(
              'GPS requires browser permission and a secure context (HTTPS/localhost).',
              style: TextStyle(color: AppTheme.textMuted, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  IconData _gpsIconForState() {
    switch (_gpsState) {
      case _GpsState.requesting:
        return Icons.hourglass_top;
      case _GpsState.active:
        return Icons.gps_fixed;
      case _GpsState.sent:
        return Icons.check_circle;
      case _GpsState.denied:
        return Icons.gps_off;
      case _GpsState.unavailable:
        return Icons.location_disabled;
      case _GpsState.error:
        return Icons.error_outline;
      default:
        return Icons.location_searching;
    }
  }

  Color _gpsColorForState() {
    switch (_gpsState) {
      case _GpsState.active:
        return AppTheme.statusHealthy;
      case _GpsState.sent:
        return AppTheme.statusHealthy;
      case _GpsState.denied:
        return AppTheme.statusCritical;
      case _GpsState.error:
        return AppTheme.statusCritical;
      case _GpsState.unavailable:
        return AppTheme.statusWarning;
      default:
        return AppTheme.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasLocations = widget.locations.isNotEmpty;

    LatLng mapCenter = const LatLng(0, 0);
    double zoom = 2.0;
    if (hasLocations) {
      final first = widget.locations.first;
      final lat = (first['latitude'] as num?)?.toDouble();
      final lng = (first['longitude'] as num?)?.toDouble();
      if (lat != null && lng != null) {
        mapCenter = LatLng(lat, lng);
        zoom = 10.0;
      }
    }

    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              FlutterMap(
                options: MapOptions(
                  initialCenter: mapCenter,
                  initialZoom: zoom,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'in.gov.moes.ncpor.polarops',
                  ),
                  MarkerLayer(
                    markers: widget.locations.expand((loc) {
                      final lat = (loc['latitude'] as num?)?.toDouble();
                      final lng = (loc['longitude'] as num?)?.toDouble();
                      if (lat == null || lng == null) return <Marker>[];
                      final freshness = loc['freshness'] as String?;
                      final p = loc['personnel'] as Map<String, dynamic>?;
                      return [
                        Marker(
                          point: LatLng(lat, lng),
                          width: 48,
                          height: 48,
                          child: GestureDetector(
                            onTap: () => _showPersonnelDetail(loc),
                            child: Tooltip(
                              message:
                                  '${p?['name'] ?? 'Unknown'} · $freshness',
                              child: Icon(
                                _freshnessIcon(freshness),
                                color: _freshnessColor(freshness),
                                size: 36,
                              ),
                            ),
                          ),
                        ),
                      ];
                    }).toList(),
                  ),
                ],
              ),
              // Legend overlay
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryNavy.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('PERSONNEL LOCATIONS',
                          style: TextStyle(
                              color: AppTheme.accentCyan,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                              letterSpacing: 1)),
                      const Text(
                          'Source: Backend API · Freshness from server',
                          style: TextStyle(
                              color: AppTheme.textMuted, fontSize: 9)),
                      const SizedBox(height: 4),
                      _legendItem(AppTheme.statusHealthy, 'LIVE (<60s)'),
                      _legendItem(AppTheme.accentCyan, 'RECENT (<1h)'),
                      _legendItem(AppTheme.statusWarning, 'STALE (>1h)'),
                      _legendItem(AppTheme.statusCritical, 'OFFLINE'),
                    ],
                  ),
                ),
              ),
              // Refresh
              Positioned(
                top: 12,
                right: 12,
                child: FloatingActionButton.small(
                  heroTag: 'mission_map_refresh',
                  onPressed: widget.onRefresh,
                  backgroundColor: AppTheme.secondaryNavy,
                  child:
                      const Icon(Icons.refresh, color: AppTheme.accentCyan),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: _buildGpsPanel(),
        ),
      ],
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(children: [
      Icon(Icons.circle, size: 8, color: color),
      const SizedBox(width: 4),
      Text(label, style: const TextStyle(color: Colors.white, fontSize: 9)),
    ]);
  }

  void _showPersonnelDetail(Map<String, dynamic> loc) {
    final p = loc['personnel'] as Map<String, dynamic>?;
    final t = loc['missionTeam'] as Map<String, dynamic>?;
    final freshness = loc['freshness'] as String?;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.secondaryNavy,
        title: Row(children: [
          Icon(_freshnessIcon(freshness), color: _freshnessColor(freshness)),
          const SizedBox(width: 8),
          Text(p?['name'] ?? 'Unknown',
              style: const TextStyle(color: Colors.white)),
        ]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _detailRow('Mission', loc['mission']?['missionCode'] ?? '-'),
            _detailRow('Team', t?['teamName'] ?? '-'),
            _detailRow('Role', p?['designation'] ?? p?['role'] ?? '-'),
            _detailRow('Latitude', '${loc['latitude']}'),
            _detailRow('Longitude', '${loc['longitude']}'),
            _detailRow('Movement', loc['movementStatus'] ?? '-'),
            _detailRow('Recorded At', loc['recordedAt'] ?? '-'),
            _detailRow('Freshness', freshness ?? '-',
                valueColor: _freshnessColor(freshness)),
            _detailRow(
                'Age',
                loc['ageSeconds'] != null
                    ? '${loc['ageSeconds']}s ago'
                    : '-'),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(_),
              child: const Text('CLOSE')),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(children: [
        SizedBox(
            width: 90,
            child: Text('$label:',
                style:
                    const TextStyle(color: AppTheme.textMuted, fontSize: 12))),
        Expanded(
            child: Text(value,
                style: TextStyle(
                    color: valueColor ?? Colors.white,
                    fontSize: 12,
                    fontWeight: valueColor != null
                        ? FontWeight.bold
                        : FontWeight.normal))),
      ]),
    );
  }
}
