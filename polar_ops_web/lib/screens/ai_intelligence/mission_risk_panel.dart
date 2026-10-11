import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/components/state_widgets.dart';
import '../../services/api/ai_agent_service.dart';

class MissionRiskPanel extends StatefulWidget {
  const MissionRiskPanel({super.key});

  @override
  State<MissionRiskPanel> createState() => _MissionRiskPanelState();
}

class _MissionRiskPanelState extends State<MissionRiskPanel> {
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _data;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() { _isLoading = true; _error = null; });
    final response = await AiAgentService.getMissionRisk();
    if (mounted) {
      if (response.success && response.data != null) {
        setState(() { _data = response.data; _isLoading = false; });
      } else {
        setState(() { _error = response.error ?? 'Failed to load mission risk'; _isLoading = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryNavy,
      appBar: AppBar(
        backgroundColor: AppTheme.secondaryNavy,
        title: const Text('MISSION RISK ANALYSIS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? StateWidgets.loadingState(message: 'Analyzing mission risk...')
          : _error != null
              ? StateWidgets.errorState(message: _error!, onRetry: _fetchData)
              : _data == null
                  ? StateWidgets.emptyState(message: 'No data available.')
                  : Padding(
                      padding: const EdgeInsets.all(AppTheme.spacingLg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Overall Risk: ${_data!['overallScore']?.toString() ?? '0'} / 100', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                          Text('Risk Level: ${_data!['riskLevel']}', style: TextStyle(color: _data!['riskLevel'] == 'HIGH' ? AppTheme.statusCritical : AppTheme.accentCyan, fontSize: 18)),
                          const SizedBox(height: AppTheme.spacingLg),
                          const Text('AI Explanation:', style: TextStyle(color: AppTheme.textMuted, fontSize: 16)),
                          const SizedBox(height: AppTheme.spacingSm),
                          Text(_data!['explanation'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 16)),
                          const SizedBox(height: AppTheme.spacingXl),
                          const Text('Contributing Factors:', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: AppTheme.spacingMd),
                          if (_data!['factors'] != null)
                            Expanded(
                              child: ListView.builder(
                                itemCount: (_data!['factors'] as List).length,
                                itemBuilder: (context, index) {
                                  final factor = (_data!['factors'] as List)[index];
                                  return Card(
                                    color: AppTheme.secondaryNavy,
                                    margin: const EdgeInsets.only(bottom: AppTheme.spacingMd),
                                    child: ListTile(
                                      title: Text(factor['factorName'] ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                      subtitle: Text(factor['description'] ?? '', style: const TextStyle(color: AppTheme.textMuted)),
                                      trailing: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(factor['riskLevel'] ?? '', style: TextStyle(color: factor['riskLevel'] == 'LOW' ? AppTheme.statusHealthy : (factor['riskLevel'] == 'HIGH' ? AppTheme.statusCritical : AppTheme.statusWarning), fontWeight: FontWeight.bold)),
                                          Text('+${factor['contribution']}', style: const TextStyle(color: AppTheme.accentCyan, fontSize: 12)),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
    );
  }
}
