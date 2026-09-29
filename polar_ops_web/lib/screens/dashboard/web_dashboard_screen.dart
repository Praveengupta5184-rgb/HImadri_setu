import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/components/state_widgets.dart';
import '../../widgets/components/section_header.dart';
import '../../widgets/components/metric_card.dart';
import '../../services/api/api_client.dart';
import '../map/map_screen.dart';

class WebDashboardScreen extends StatefulWidget {
  const WebDashboardScreen({super.key});

  @override
  State<WebDashboardScreen> createState() => _WebDashboardScreenState();
}

class _WebDashboardScreenState extends State<WebDashboardScreen> {
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _dashboardData;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    final response = await ApiClient.get<Map<String, dynamic>>('/dashboard');
    if (mounted) {
      if (response.success && response.data != null) {
        setState(() {
          _dashboardData = response.data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = response.error ?? 'Unknown error';
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildHeroArea() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      decoration: BoxDecoration(
        color: AppTheme.secondaryNavy,
        borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.accentCyan.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('MISSION COMMAND',
                  style: TextStyle(
                      color: AppTheme.accentCyan,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2)),
              Text('POLAR EXPEDITION OPERATIONAL MANAGEMENT',
                  style: TextStyle(
                      color: Colors.white, fontSize: 14, letterSpacing: 1.2)),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: const [
              Text('DATABASE COUNTS • DERIVED READINESS',
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
              Text('MAP TILES REQUIRE NETWORK ACCESS',
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
              SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.check_circle,
                      color: AppTheme.statusHealthy, size: 14),
                  SizedBox(width: 4),
                  Text('COMMAND DATA CONNECTED',
                      style: TextStyle(
                          color: AppTheme.statusHealthy,
                          fontWeight: FontWeight.bold,
                          fontSize: 12)),
                ],
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildMissionReadiness() {
    if (_dashboardData == null) return const SizedBox.shrink();
    final readiness = _dashboardData!['missionReadiness'];
    if (readiness == null) return const SizedBox.shrink();

    final score = readiness['overallScore'] ?? 0;
    Color scoreColor = AppTheme.statusHealthy;
    if (score < 80) scoreColor = AppTheme.statusWarning;
    if (score < 60) scoreColor = AppTheme.statusCritical;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('MISSION READINESS',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
            const SizedBox(height: AppTheme.spacingMd),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Center(
                    child: Column(
                      children: [
                        Text('$score%',
                            style: TextStyle(
                                color: scoreColor,
                                fontSize: 42,
                                fontWeight: FontWeight.bold)),
                        const Text('OVERALL SCORE',
                            style: TextStyle(
                                color: AppTheme.textMuted, fontSize: 10)),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      _buildReadinessBar('Cargo', readiness['cargoReadiness']),
                      _buildReadinessBar(
                          'Inventory', readiness['inventoryReadiness']),
                      _buildReadinessBar(
                          'Personnel', readiness['personnelReadiness']),
                      _buildReadinessBar('Assets', readiness['assetReadiness']),
                      _buildReadinessBar(
                          'Emergency', readiness['emergencyReadiness']),
                    ],
                  ),
                )
              ],
            ),
            const Divider(),
            const Text('INTELLIGENCE PANEL - RECOMMENDATIONS',
                style: TextStyle(color: AppTheme.accentCyan, fontSize: 12)),
            const SizedBox(height: 8),
            ...(readiness['reasons'] as List<dynamic>)
                .map((reason) => Row(
                      children: [
                        const Icon(Icons.info_outline,
                            color: AppTheme.statusWarning, size: 14),
                        const SizedBox(width: 8),
                        Text(reason.toString(),
                            style: const TextStyle(
                                color: AppTheme.textMuted, fontSize: 12)),
                      ],
                    ))
                .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildReadinessBar(String label, int value) {
    Color barColor = AppTheme.statusHealthy;
    if (value < 90) barColor = AppTheme.statusWarning;
    if (value < 70) barColor = AppTheme.statusCritical;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          SizedBox(
              width: 80,
              child: Text(label,
                  style: const TextStyle(
                      color: AppTheme.textMuted, fontSize: 12))),
          Expanded(
            child: LinearProgressIndicator(
              value: value / 100,
              backgroundColor: AppTheme.primaryNavy,
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
            ),
          ),
          SizedBox(
              width: 40,
              child: Text(' $value%',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                  textAlign: TextAlign.right)),
        ],
      ),
    );
  }

  Widget _buildCoreKPIs() {
    if (_dashboardData == null) return const SizedBox.shrink();
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 2.5,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [
        MetricCard(
            title: 'Active Expeditions',
            value: _dashboardData!['activeExpeditions'].toString(),
            icon: Icons.map,
            iconColor: AppTheme.accentCyan),
        MetricCard(
            title: 'Cargo In Transit',
            value: _dashboardData!['cargoInTransit'].toString(),
            icon: Icons.local_shipping,
            iconColor: AppTheme.statusWarning),
        MetricCard(
            title: 'Inventory Alerts',
            value: _dashboardData!['inventoryCriticalItems'].toString(),
            icon: Icons.inventory,
            iconColor: AppTheme.statusCritical),
        MetricCard(
            title: 'Personnel Deployed',
            value: _dashboardData!['personnelDeployed'].toString(),
            icon: Icons.people,
            iconColor: AppTheme.statusHealthy),
        MetricCard(
            title: 'Critical Assets',
            value: _dashboardData!['criticalAssets'].toString(),
            icon: Icons.precision_manufacturing,
            iconColor: AppTheme.accentCyan),
        MetricCard(
            title: 'Active Emergencies',
            value: _dashboardData!['activeEmergencies'].toString(),
            icon: Icons.warning,
            iconColor: _dashboardData!['activeEmergencies'] > 0
                ? AppTheme.statusCritical
                : AppTheme.statusHealthy),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return StateWidgets.loadingState(
          message: 'Initializing Mission Command...');
    }

    if (_error != null) {
      return StateWidgets.errorState(message: _error!, onRetry: _fetchData);
    }

    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              title: 'Dashboard',
              trailing: IconButton(
                icon: const Icon(Icons.refresh, color: AppTheme.accentCyan),
                onPressed: _fetchData,
              ),
            ),
            _buildHeroArea(),
            const SizedBox(height: AppTheme.spacingLg),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      _buildCoreKPIs(),
                      const SizedBox(height: AppTheme.spacingLg),
                      SizedBox(
                        height: 400,
                        child: Card(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Padding(
                                padding: EdgeInsets.all(AppTheme.spacingMd),
                                child: Text('OPERATIONAL MAP',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold)),
                              ),
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                      bottom: Radius.circular(4)),
                                  child:
                                      const MapScreen(), // Reuse phase 3 component
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppTheme.spacingLg),
                Expanded(
                  flex: 1,
                  child: _buildMissionReadiness(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
