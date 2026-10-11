import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/components/state_widgets.dart';
import '../../widgets/components/section_header.dart';
import '../../services/api/api_client.dart';

class AgentScreen extends StatefulWidget {
  const AgentScreen({super.key});

  @override
  State<AgentScreen> createState() => _AgentScreenState();
}

class _AgentScreenState extends State<AgentScreen> {
  bool _isLoading = true;
  String? _error;
  List<dynamic> _recommendations = [];

  @override
  void initState() {
    super.initState();
    _fetchRecommendations();
  }

  Future<void> _fetchRecommendations() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    // the backend route is /api/v1/agent/recommendations
    final response = await ApiClient.get<List<dynamic>>('/agent/recommendations');
    if (mounted) {
      if (response.success && response.data != null) {
        setState(() {
          _recommendations = response.data!;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = response.error ?? 'Failed to load recommendations';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _approveRecommendation(int id) async {
    final response = await ApiClient.post('/agent/recommendations/$id/approve', {});
    if (response.success) {
      _fetchRecommendations();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to approve: ${response.error}')));
      }
    }
  }

  Future<void> _rejectRecommendation(int id) async {
    final response = await ApiClient.post('/agent/recommendations/$id/reject', {});
    if (response.success) {
      _fetchRecommendations();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to reject: ${response.error}')));
      }
    }
  }

  Widget _buildRecommendationCard(Map<String, dynamic> rec) {
    final bool isPending = rec['status'] == 'PENDING';
    final bool isApproved = rec['status'] == 'APPROVED';

    Color statusColor = AppTheme.statusWarning;
    if (isApproved) statusColor = AppTheme.statusHealthy;
    else if (rec['status'] == 'REJECTED') statusColor = AppTheme.statusCritical;

    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingMd),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('RECOMMENDATION #${rec['id']}',
                    style: const TextStyle(color: AppTheme.accentCyan, fontWeight: FontWeight.bold)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: statusColor),
                  ),
                  child: Text(rec['status'] ?? 'UNKNOWN',
                      style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingMd),
            Text(rec['action'] ?? '', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: AppTheme.spacingSm),
            const Text('Explanation:', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
            Text(rec['explanation'] ?? '', style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: AppTheme.spacingMd),
            Row(
              children: [
                const Icon(Icons.psychology, size: 16, color: AppTheme.accentCyan),
                const SizedBox(width: 4),
                Text('Confidence: ${(rec['confidenceScore'] * 100).toStringAsFixed(1)}%',
                    style: const TextStyle(color: AppTheme.accentCyan, fontWeight: FontWeight.bold)),
              ],
            ),
            if (isPending) ...[
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => _rejectRecommendation(rec['id']),
                    style: OutlinedButton.styleFrom(foregroundColor: AppTheme.statusCritical),
                    child: const Text('REJECT'),
                  ),
                  const SizedBox(width: AppTheme.spacingMd),
                  ElevatedButton(
                    onPressed: () => _approveRecommendation(rec['id']),
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.statusHealthy),
                    child: const Text('APPROVE'),
                  ),
                ],
              ),
            ]
          ],
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
            title: 'Autonomous Agent',
            trailing: IconButton(
              icon: const Icon(Icons.refresh, color: AppTheme.accentCyan),
              onPressed: _fetchRecommendations,
            ),
          ),
          const SizedBox(height: AppTheme.spacingLg),
          if (_isLoading)
            StateWidgets.loadingState(message: 'Consulting Autonomous Agent...')
          else if (_error != null)
            StateWidgets.errorState(message: _error!, onRetry: _fetchRecommendations)
          else if (_recommendations.isEmpty)
            StateWidgets.emptyState(message: 'No pending AI recommendations.')
          else
            Expanded(
              child: ListView.builder(
                itemCount: _recommendations.length,
                itemBuilder: (context, index) {
                  return _buildRecommendationCard(_recommendations[index]);
                },
              ),
            ),
        ],
      ),
    );
  }
}
