import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/components/state_widgets.dart';
import '../../services/api/ai_agent_service.dart';

class InventoryIntelligencePanel extends StatefulWidget {
  const InventoryIntelligencePanel({super.key});

  @override
  State<InventoryIntelligencePanel> createState() => _InventoryIntelligencePanelState();
}

class _InventoryIntelligencePanelState extends State<InventoryIntelligencePanel> {
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
    final response = await AiAgentService.getInventoryRisks();
    if (mounted) {
      if (response.success && response.data != null) {
        setState(() { _data = response.data as List; _isLoading = false; });
      } else {
        setState(() { _error = response.error ?? 'Failed to load inventory intelligence'; _isLoading = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryNavy,
      appBar: AppBar(
        backgroundColor: AppTheme.secondaryNavy,
        title: const Text('INVENTORY INTELLIGENCE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? StateWidgets.loadingState(message: 'Analyzing inventory models...')
          : _error != null
              ? StateWidgets.errorState(message: _error!, onRetry: _fetchData)
              : _data == null || _data!.isEmpty
                  ? StateWidgets.emptyState(message: 'No inventory shortages detected.')
                  : Padding(
                      padding: const EdgeInsets.all(AppTheme.spacingLg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Predicted Shortages: ${_data!.length}', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
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
                                            Text(item['itemName'] ?? 'UNKNOWN', style: const TextStyle(color: AppTheme.statusWarning, fontSize: 18, fontWeight: FontWeight.bold)),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(color: AppTheme.statusWarning.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(4), border: Border.all(color: AppTheme.statusWarning)),
                                              child: Text('Prob: ${(item['shortageProbability'] * 100).toStringAsFixed(0)}%', style: const TextStyle(color: AppTheme.statusWarning, fontSize: 12, fontWeight: FontWeight.bold)),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: AppTheme.spacingSm),
                                        Text('Category: ${item['category']}', style: const TextStyle(color: Colors.white)),
                                        Text('Current Quantity: ${item['currentQuantity']}', style: const TextStyle(color: Colors.white)),
                                        Text('Predicted Req: ${item['predictedRequirement']}', style: const TextStyle(color: Colors.white)),
                                        Text('Expected Shortage in: ${item['expectedShortageDays']} Days', style: const TextStyle(color: AppTheme.statusCritical, fontWeight: FontWeight.bold)),
                                        const Divider(color: AppTheme.textMuted),
                                        const Text('Risk Factors:', style: TextStyle(color: AppTheme.statusWarning, fontWeight: FontWeight.bold)),
                                        if (item['reasons'] != null)
                                          ...((item['reasons'] as List).map((f) => Text('- $f', style: const TextStyle(color: Colors.white)))),
                                        const SizedBox(height: AppTheme.spacingSm),
                                        Text('Recommendation: ${item['recommendation']}', style: const TextStyle(color: AppTheme.accentCyan, fontStyle: FontStyle.italic)),
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
