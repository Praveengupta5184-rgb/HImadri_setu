import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../screens/dashboard/web_dashboard_screen.dart';
import '../screens/twin/digital_twin_screen.dart';
import '../screens/map/map_screen.dart';
import '../screens/cargo/cargo_screen.dart';
import '../screens/inventory/inventory_screen.dart';
import '../screens/personnel/personnel_screen.dart';
import '../screens/asset/asset_screen.dart';
import '../screens/emergency/emergency_screen.dart';
import '../screens/simulator/simulator_screen.dart';
import '../services/sync/sync_service.dart';
import '../services/auth/auth_service.dart';
import '../screens/auth/login_screen.dart';
import '../screens/reports/reports_screen.dart';
import '../screens/user/user_management_screen.dart';
import '../screens/mission/mission_list_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;
  bool _isOnline = true;
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _isOnline = SyncService.isOnline;
    _isSyncing = SyncService.isSyncing;

    SyncService.onStatusChange = (online) {
      if (mounted) {
        setState(() {
          _isOnline = online;
          _isSyncing = SyncService.isSyncing;
        });
      }
    };
  }

  final List<String> _baseDestinations = [
    'Mission Command',
    'Field Missions',
    'Geospatial Map',
    'Cargo Operations',
    'Inventory',
    'Personnel',
    'Assets',
    'Stations & Map',
    'Emergency Operations',
    'Digital Twin',
    'AI Risk & Vision',
    'Mission Simulator',
    'Reports',
  ];

  final List<IconData> _baseIcons = [
    Icons.dashboard,
    Icons.rocket_launch,
    Icons.map,
    Icons.local_shipping,
    Icons.inventory_2,
    Icons.people,
    Icons.precision_manufacturing,
    Icons.account_balance,
    Icons.warning,
    Icons.view_in_ar,
    Icons.psychology,
    Icons.science,
    Icons.picture_as_pdf,
  ];

  List<String> get _destinations {
    final list = List<String>.from(_baseDestinations);
    if (AuthService.isAdmin) {
      list.add('User Management');
    }
    return list;
  }

  List<IconData> get _icons {
    final list = List<IconData>.from(_baseIcons);
    if (AuthService.isAdmin) {
      list.add(Icons.admin_panel_settings);
    }
    return list;
  }


  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Tooltip(
                message: 'POLAR-OPS mission command',
                child: Icon(Icons.ac_unit, color: AppTheme.accentCyan)),
            const SizedBox(width: AppTheme.spacingSm),
            const Text('POLAR-OPS'),
            const SizedBox(width: AppTheme.spacingLg),
            Semantics(
              button: true,
              label: 'Connection and offline sync status',
              child: GestureDetector(
                onTap: _showSyncDialog,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _isSyncing
                        ? AppTheme.statusWarning.withValues(alpha: 0.15)
                        : (_isOnline
                            ? AppTheme.statusHealthy.withValues(alpha: 0.15)
                            : AppTheme.statusCritical.withValues(alpha: 0.15)),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: _isSyncing
                            ? AppTheme.statusWarning.withValues(alpha: 0.5)
                            : (_isOnline
                                ? AppTheme.statusHealthy.withValues(alpha: 0.5)
                                : AppTheme.statusCritical
                                    .withValues(alpha: 0.5))),
                  ),
                  child: Row(
                    children: [
                      Icon(
                          _isSyncing
                              ? Icons.sync
                              : (_isOnline ? Icons.wifi : Icons.wifi_off),
                          size: 14,
                          color: _isSyncing
                              ? AppTheme.statusWarning
                              : (_isOnline
                                  ? AppTheme.statusHealthy
                                  : AppTheme.statusCritical)),
                      const SizedBox(width: 4),
                      Text(
                          _isSyncing
                              ? 'SYNCING...'
                              : (_isOnline
                                  ? 'CONNECTED'
                                  : 'OFFLINE - LOCAL CACHE'),
                          style: TextStyle(
                              color: _isSyncing
                                  ? AppTheme.statusWarning
                                  : (_isOnline
                                      ? AppTheme.statusHealthy
                                      : AppTheme.statusCritical),
                              fontSize: 12,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Logged In',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  Text(AuthService.currentUserRole ?? 'Unknown',
                      style: const TextStyle(
                          fontSize: 10, color: AppTheme.accentCyan)),
                ],
              ),
            ),
          ),
          PopupMenuButton<String>(
            icon: const CircleAvatar(
              backgroundColor: AppTheme.accentCyan,
              child: Icon(Icons.person, color: AppTheme.primaryNavy),
            ),
            onSelected: (value) async {
              if (value == 'logout') {
                await AuthService.logout();
                if (mounted) {
                  Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const LoginScreen()));
                }
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'logout',
                child: Text('Logout'),
              ),
            ],
          ),
          const SizedBox(width: AppTheme.spacingMd),
        ],
      ),
      body: Row(
        children: [
          SingleChildScrollView(
            child: NavigationRail(
              extended: isDesktop,
              selectedIndex: _selectedIndex,
              onDestinationSelected: (int index) =>
                  setState(() => _selectedIndex = index),
              destinations: List.generate(_destinations.length, (index) {
                return NavigationRailDestination(
                  icon: Tooltip(
                      message: _destinations[index],
                      child: Icon(_icons[index])),
                  selectedIcon: Icon(_icons[index],
                      semanticLabel: '${_destinations[index]}, selected'),
                  label: Text(_destinations[index]),
                );
              }),
            ),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return const WebDashboardScreen();
      case 1:
        return const MissionListScreen();
      case 2:
        return const MapScreen();
      case 3:
        return const CargoScreen();
      case 4:
        return const InventoryScreen();
      case 5:
        return const PersonnelScreen();
      case 6:
        return const AssetScreen();
      case 7:
        return const MapScreen();
      case 8:
        return const EmergencyScreen();
      case 9:
        return const DigitalTwinScreen();
      case 10:
        return const CargoScreen();
      case 11:
        return const SimulatorScreen();
      case 12:
        return const ReportsScreen();
      case 13:
        return const UserManagementScreen();
      default:
        return const WebDashboardScreen();
    }
  }

  void _showSyncDialog() {
    showDialog(
      context: context,
      builder: (context) => const SyncAuditDialog(),
    );
  }
}

class SyncAuditDialog extends StatefulWidget {
  const SyncAuditDialog({super.key});
  @override
  State<SyncAuditDialog> createState() => _SyncAuditDialogState();
}

class _SyncAuditDialogState extends State<SyncAuditDialog> {
  @override
  void initState() {
    super.initState();
    SyncService.onSyncLogChange = () {
      if (mounted) setState(() {});
    };
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.primaryNavy,
      title: const Text('Offline Sync Audit Log',
          style: TextStyle(color: Colors.white)),
      content: SizedBox(
        width: 500,
        height: 400,
        child: SyncService.syncLog.isEmpty
            ? const Center(
                child: Text('No sync operations recorded.',
                    style: TextStyle(color: Colors.white54)))
            : ListView.builder(
                itemCount: SyncService.syncLog.length,
                itemBuilder: (context, index) {
                  final log = SyncService.syncLog[index];
                  return ListTile(
                    title: Text(log['message'] ?? '',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 13)),
                    subtitle: Text(log['time'] ?? '',
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 11)),
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CLOSE'),
        ),
      ],
    );
  }
}
