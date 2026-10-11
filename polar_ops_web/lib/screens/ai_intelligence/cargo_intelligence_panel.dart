import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/components/state_widgets.dart';
import '../../services/api/ai_agent_service.dart';

class CargoIntelligencePanel extends StatefulWidget {
  const CargoIntelligencePanel({super.key});

  @override
  State<CargoIntelligencePanel> createState() => _CargoIntelligencePanelState();
}

class _CargoIntelligencePanelState extends State<CargoIntelligencePanel> {
  bool _isLoading = true;
  String? _error;
  List<dynamic>? _data;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() { _isLoading = true; _error = null; });
    final response = await AiAgentService.getCargoRisks();
    if (mounted) {
      if (response.success && response.data != null) {
        setState(() { _data = response.data as List; _isLoading = false; });
      } else {
        setState(() { _error = response.error ?? 'Failed to load cargo intelligence'; _isLoading = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryNavy,
      appBar: AppBar(
        backgroundColor: AppTheme.secondaryNavy,
        title: const Text('CARGO INTELLIGENCE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? StateWidgets.loadingState(message: 'Analyzing cargo logistics...')
          : _error != null
              ? StateWidgets.errorState(message: _error!, onRetry: _fetchData)
              : _data == null || _data!.isEmpty
                  ? StateWidgets.emptyState(message: 'No critical cargo detected.')
                  : Padding(
                      padding: const EdgeInsets.all(AppTheme.spacingLg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Total Critical Cargo: ${_data!.length}', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: AppTheme.spacingMd),
                          Expanded(
                            child: ListView.builder(
                              itemCount: _data!.length,
                              itemBuilder: (context, index) {
                                final item = _data![index];
                                return Card(
                                  color: AppTheme.secondaryNavy,
                                  margin: const EdgeInsets.only(bottom: AppTheme.spacingMd),
                                  child: Padding(
                                    padding: const EdgeInsets.all(AppTheme.spacingLg),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(item['cargoId'] ?? 'UNKNOWN', style: const TextStyle(color: AppTheme.accentCyan, fontSize: 18, fontWeight: FontWeight.bold)),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(color: AppTheme.statusCritical.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(4), border: Border.all(color: AppTheme.statusCritical)),
                                              child: Text('Risk: ${item['riskScore']} / 100', style: const TextStyle(color: AppTheme.statusCritical, fontSize: 12, fontWeight: FontWeight.bold)),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: AppTheme.spacingSm),
                                        Text('Name: ${item['name']}', style: const TextStyle(color: Colors.white)),
                                        Text('Status: ${item['currentStatus']}', style: const TextStyle(color: Colors.white)),
                                        Text('Route: ${item['origin']} -> ${item['destination']}', style: const TextStyle(color: AppTheme.textMuted)),
                                        const Divider(color: AppTheme.textMuted),
                                        const Text('Risk Factors:', style: TextStyle(color: AppTheme.accentCyan, fontWeight: FontWeight.bold)),
                                        if (item['riskFactors'] != null)
                                          ...((item['riskFactors'] as List).map((f) => Text('- $f', style: const TextStyle(color: Colors.white)))),
                                        const SizedBox(height: AppTheme.spacingSm),
                                        Text('Recommendation: ${item['recommendation']}', style: const TextStyle(color: AppTheme.statusWarning, fontStyle: FontStyle.italic)),
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
