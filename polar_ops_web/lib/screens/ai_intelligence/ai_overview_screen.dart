import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/components/state_widgets.dart';
import '../../widgets/components/section_header.dart';
import '../../services/api/ai_agent_service.dart';
import 'mission_risk_panel.dart';
import 'cargo_intelligence_panel.dart';
import 'inventory_intelligence_panel.dart';

class AiOverviewScreen extends StatefulWidget {
  const AiOverviewScreen({super.key});

  @override
  State<AiOverviewScreen> createState() => _AiOverviewScreenState();
}

class _AiOverviewScreenState extends State<AiOverviewScreen> {
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _overviewData;

  @override
  void initState() {
    super.initState();
    _fetchOverview();
  }

  Future<void> _fetchOverview() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final response = await AiAgentService.getOverview();
    if (mounted) {
      if (response.success && response.data != null) {
        setState(() {
          _overviewData = response.data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = response.error ?? 'Failed to load AI Intelligence Overview';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _analyzeNow() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    await AiAgentService.analyzeMission();
    await _fetchOverview();
  }
  
  Widget _buildSummaryCard(String title, String value, String subtitle, IconData icon, Color color, {VoidCallback? onTap}) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title, style: const TextStyle(color: AppTheme.textMuted, fontWeight: FontWeight.bold)),
                  Icon(icon, color: color, size: 24),
                ],
              ),
              const SizedBox(height: AppTheme.spacingMd),
              Text(value, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: color)),
              const SizedBox(height: AppTheme.spacingXs),
              Text(subtitle, style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'AI Decision Intelligence',
            trailing: Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _analyzeNow,
                  icon: const Icon(Icons.psychology),
                  label: const Text('Analyze Now'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentCyan),
                ),
                const SizedBox(width: AppTheme.spacingMd),
                IconButton(
                  icon: const Icon(Icons.refresh, color: AppTheme.accentCyan),
                  onPressed: _fetchOverview,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spacingLg),
          if (_isLoading)
            StateWidgets.loadingState(message: 'Gathering operational intelligence...')
          else if (_error != null)
            StateWidgets.errorState(message: _error!, onRetry: _fetchOverview)
          else if (_overviewData == null)
            StateWidgets.emptyState(message: 'No AI data available.')
          else
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LayoutBuilder(
                      builder: (context, constraints) {
                        int crossAxisCount = constraints.maxWidth > 1200 ? 4 : (constraints.maxWidth > 800 ? 3 : (constraints.maxWidth > 600 ? 2 : 1));
                        
                        // Parse values safely
                        final missionRiskScore = _overviewData!['missionRiskScore']?.toString() ?? 'N/A';
                        final missionRiskLevel = _overviewData!['missionRiskLevel']?.toString() ?? 'UNKNOWN';
                        final pendingRecs = _overviewData!['pendingRecommendations']?.toString() ?? '0';
                        final agentStatus = _overviewData!['agentStatus']?.toString() ?? 'IDLE';

                        return GridView.count(
                          crossAxisCount: crossAxisCount,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: AppTheme.spacingMd,
                          mainAxisSpacing: AppTheme.spacingMd,
                          childAspectRatio: 1.8,
                          children: [
                            _buildSummaryCard(
                              'MISSION RISK', 
                              missionRiskScore, 
                              missionRiskLevel, 
                              Icons.warning_amber_rounded, 
                              missionRiskLevel == 'HIGH' || missionRiskLevel == 'CRITICAL' ? AppTheme.statusCritical : AppTheme.statusWarning,
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => const MissionRiskPanel()));
                              }
                            ),
                            _buildSummaryCard(
                              'CARGO INTELLIGENCE', 
                              '3 Critical', // Prototype: should parse from cargoRiskSummary
                              'Delay risk detected', 
                              Icons.local_shipping, 
                              AppTheme.accentCyan,
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => const CargoIntelligencePanel()));
                              }
                            ),
                            _buildSummaryCard(
                              'INVENTORY INTELLIGENCE', 
                              '2 Shortages', 
                              'Predicted in 7 days', 
                              Icons.inventory_2, 
                              AppTheme.statusWarning,
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => const InventoryIntelligencePanel()));
                              }
                            ),
                            _buildSummaryCard(
                              'RECOMMENDATIONS', 
                              '$pendingRecs Pending', 
                              'Require Officer Approval', 
                              Icons.fact_check, 
                              AppTheme.accentCyan,
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: AppTheme.spacingXl),
                    const Text('TOP ACTIVE RECOMMENDATIONS', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: AppTheme.spacingMd),
                    if (_overviewData!['topRecommendations'] == null || (_overviewData!['topRecommendations'] as List).isEmpty)
                      StateWidgets.emptyState(message: 'No pending recommendations require human approval.')
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: (_overviewData!['topRecommendations'] as List).length,
                        itemBuilder: (context, index) {
                          final rec = (_overviewData!['topRecommendations'] as List)[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: AppTheme.spacingMd),
                            child: Padding(
                              padding: const EdgeInsets.all(AppTheme.spacingLg),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('[${rec['priority'] ?? 'MEDIUM'}] ${rec['title'] ?? 'Recommendation'}', style: const TextStyle(color: AppTheme.accentCyan, fontSize: 16, fontWeight: FontWeight.bold)),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppTheme.statusCritical.withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(4),
                                          border: Border.all(color: AppTheme.statusCritical),
                                        ),
                                        child: Text('Risk: ${rec['riskScore'] ?? 'N/A'} / 100', style: const TextStyle(color: AppTheme.statusCritical, fontSize: 12, fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: AppTheme.spacingMd),
                                  const Text('Factors:', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                                  Text(rec['explanation'] ?? '', style: const TextStyle(color: Colors.white70)),
                                  const SizedBox(height: AppTheme.spacingSm),
                                  const Text('Suggested Action:', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                                  Text(rec['suggestedAction'] ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: AppTheme.spacingMd),
                                  const Divider(height: 24),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      OutlinedButton(
                                        onPressed: () async {
                                          await AiAgentService.rejectRecommendation(rec['id']);
                                          await _fetchOverview();
                                        },
                                        style: OutlinedButton.styleFrom(foregroundColor: AppTheme.statusCritical),
                                        child: const Text('REJECT'),
                                      ),
                                      const SizedBox(width: AppTheme.spacingMd),
                                      ElevatedButton(
                                        onPressed: () async {
                                          await AiAgentService.approveRecommendation(rec['id']);
                                          await _fetchOverview();
                                        },
                                        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.statusHealthy),
                                        child: const Text('APPROVE'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
