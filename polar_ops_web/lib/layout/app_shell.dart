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
import '../screens/mission/my_team_screen.dart';
import '../screens/mission/mission_list_screen.dart';
import '../screens/ai_intelligence/ai_overview_screen.dart';
import '../screens/user/user_management_screen.dart';
import '../services/api/notification_service.dart';
import 'package:showcaseview/showcaseview.dart';
import '../services/tour/tour_keys.dart';
import '../services/tour/tour_service.dart';
import '../widgets/tour/tour_step_widget.dart';
import '../widgets/tour/tour_welcome_widget.dart';

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
    
    // Connect notifications
    Future.microtask(() {
      NotificationService().connect('1'); // TODO: Use real user ID
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowTour();
    });
  }

  Future<void> _checkAndShowTour() async {
    final shouldShow = await TourService.shouldShowTour();
    if (shouldShow) {
      if (!mounted) return;
      _startTour();
    }
  }

  void _startTour() {
    try {
      ShowCaseWidget.of(context).startShowCase(TourKeys.allKeys);
    } catch (_) {}
  }

  GlobalKey? _getTourKeyForIndex(int index) {
    switch (index) {
      case 0: return TourKeys.dashboard;
      case 1: return TourKeys.mission;
      case 4: return TourKeys.cargo;
      case 5: return TourKeys.inventory;
      case 6: return TourKeys.personnel;
      case 7: return TourKeys.asset;
      case 8: return TourKeys.map;
      case 9: return TourKeys.emergency;
      case 10: return TourKeys.twin;
      case 11: return TourKeys.ai;
      case 13: return TourKeys.reports;
      default: return null;
    }
  }

  String _getTourTitleForIndex(int index) {
    switch (index) {
      case 0: return 'Mission Command';
      case 1: return 'Mission Management';
      case 4: return 'Cargo Operations';
      case 5: return 'Inventory';
      case 6: return 'Teams & Personnel';
      case 7: return 'Assets';
      case 8: return 'Geospatial Map';
      case 9: return 'Emergency Operations';
      case 10: return 'Digital Twin';
      case 11: return 'AI Decision Intelligence';
      case 13: return 'Reports';
      default: return '';
    }
  }

  String _getTourDescForIndex(int index) {
    switch (index) {
      case 0: return "Mission Command is the operational control center.\n\nIt provides a live overview of active expeditions, cargo in transit, deployed personnel, inventory alerts, critical assets and active emergencies.\n\nThese values come from actual backend operational data.";
      case 1: return "Create and manage polar expedition missions here.\n\nCREATE MISSION → PLANNED → ACTIVATE → ACTIVE → COMPLETE / CLOSE\n\nOnly ACTIVE missions appear as Active Expeditions on the Dashboard.";
      case 4: return "Cargo moves through a controlled operational lifecycle.\n\nCREATE → READY → DISPATCH → IN TRANSIT → ARRIVED → DELIVERED\n\nWhen cargo is dispatched, its status becomes IN TRANSIT and the Dashboard Cargo in Transit count updates from backend data.";
      case 5: return "Inventory tracks consumable and stock-based resources such as supplies, fuel, medical supplies, batteries and other consumables.\n\nLow-stock and shortage conditions generate Inventory Alerts.";
      case 6: return "Every expedition can contain operational teams.\n\nMISSION → TEAM → PERSONNEL → ASSIGN → DEPLOY\n\nOnly active/deployed operational assignments contribute to Personnel Deployed on the Dashboard.";
      case 7: return "Assets represent identifiable reusable equipment and operational resources.\n\nREGISTER → ASSIGN → TRACK → MAINTAIN → RETURN / RETIRE\n\nCritical asset conditions contribute to the Critical Assets dashboard metric.";
      case 8: return "Use the map for operational situational awareness.\n\nDisplays Stations, Authorized personnel locations, Cargo tracking, Emergency locations, and Operational locations.";
      case 9: return "Any authorized field/team member can raise an emergency or SOS.\n\nSOS / EMERGENCY → GPS LOCATION → INCIDENT CREATED → AUTHORIZED ALERT → ACKNOWLEDGE → ASSIGN RESPONDER → EN ROUTE → ON SCENE → RESOLVE";
      case 10: return "Digital Twin is a digital operational representation of the physical polar station.\n\nIt connects station spaces with operational information such as authorized personnel, assets, inventory and emergency resources.";
      case 11: return "AI Decision Intelligence analyzes operational data to identify risks and provide explainable recommendations.\n\nOBSERVE → DETECT / PREDICT → EXPLAIN → RECOMMEND → HUMAN APPROVAL\n\nThe human Mission Officer remains the final decision authority.";
      case 13: return "Reports provide historical and consolidated operational information.\n\nDashboard = current operational situation.\nAI = risk analysis and decision support.\nReports = historical and operational records.";
      default: return "";
    }
  }

  @override
  void dispose() {
    NotificationService().disconnect();
    super.dispose();
  }

  final List<String> _baseDestinations = [
    'Mission Command',
    'Mission Management',
    'My Team',
    'Geospatial Map',
    'Cargo Operations',
    'Inventory',
    'Personnel',
    'Assets',
    'Stations & Map',
    'Emergency Operations',
    'Digital Twin',
    'AI Decision Intelligence',
    'Mission Simulator',
    'Reports',
  ];

  final List<IconData> _baseIcons = [
    Icons.dashboard,
    Icons.rocket_launch,
    Icons.groups,
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
          Showcase.withWidget(
            key: TourKeys.help,
            container: const TourWelcomeWidget(),
            child: IconButton(
              tooltip: 'How to Use POLAR-OPS',
              icon: const Icon(Icons.help_outline, color: AppTheme.accentCyan),
              onPressed: () {
                _startTour();
              },
            ),
          ),
          AnimatedBuilder(
            animation: NotificationService(),
            builder: (context, child) {
              final unreadCount = NotificationService().unreadNotifications.length;
              return PopupMenuButton<int>(
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.notifications, color: AppTheme.accentCyan),
                    if (unreadCount > 0)
                      Positioned(
                        right: -4,
                        top: -4,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: AppTheme.statusCritical,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            '$unreadCount',
                            style: const TextStyle(color: Colors.white, fontSize: 10),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                  ],
                ),
                onSelected: (id) {
                  NotificationService().markAsRead(id);
                },
                itemBuilder: (context) {
                  final notifications = NotificationService().unreadNotifications;
                  if (notifications.isEmpty) {
                    return [const PopupMenuItem(enabled: false, child: Text('No new notifications'))];
                  }
                  return notifications.map((n) {
                    return PopupMenuItem<int>(
                      value: n['id'],
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(n['title'] ?? 'Alert', style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text(n['message'] ?? '', style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    );
                  }).toList();
                },
              );
            }
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: NavigationRail(
                      extended: isDesktop,
                      selectedIndex: _selectedIndex,
                      onDestinationSelected: (int index) =>
                          setState(() => _selectedIndex = index),
                      destinations: List.generate(_destinations.length, (index) {
                        final tourKey = _getTourKeyForIndex(index);
                        Widget iconWidget = Icon(_icons[index]);
                        if (tourKey != null) {
                          iconWidget = Showcase.withWidget(
                            key: tourKey,
                            container: TourStepWidget(
                              title: _getTourTitleForIndex(index),
                              description: _getTourDescForIndex(index),
                              narration: _getTourDescForIndex(index)
                                  .replaceAll('\n', '. '),
                            ),
                            child: iconWidget,
                          );
                        }
                        return NavigationRailDestination(
                          icon: Tooltip(
                              message: _destinations[index],
                              child: iconWidget),
                          selectedIcon: Icon(_icons[index],
                              semanticLabel:
                                  '${_destinations[index]}, selected'),
                          label: Text(_destinations[index]),
                        );
                      }),
                    ),
                  ),
                ),
              );
            },
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
        return MissionListScreen();
      case 2:
        return const MyTeamScreen();
      case 3:
        return const MapScreen();
      case 4:
        return const CargoScreen();
      case 5:
        return const InventoryScreen();
      case 6:
        return const PersonnelScreen();
      case 7:
        return const AssetScreen();
      case 8:
        return const MapScreen();
      case 9:
        return const EmergencyScreen();
      case 10:
        return const DigitalTwinScreen();
      case 11:
        return AiOverviewScreen();
      case 12:
        return const SimulatorScreen();
      case 13:
        return const ReportsScreen();
      case 14:
        return UserManagementScreen();
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
