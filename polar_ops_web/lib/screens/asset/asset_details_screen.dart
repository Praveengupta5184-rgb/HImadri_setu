import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/components/status_badge.dart';
import '../../services/api/api_client.dart';
import '../../services/auth/auth_service.dart';
import 'asset_form_screen.dart';

class AssetDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> asset;

  const AssetDetailsScreen({super.key, required this.asset});

  @override
  State<AssetDetailsScreen> createState() => _AssetDetailsScreenState();
}

class _AssetDetailsScreenState extends State<AssetDetailsScreen> {
  Map<String, dynamic>? _asset;
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _asset = widget.asset;
    _refreshAsset();
  }

  Future<void> _refreshAsset() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiClient.get('/assets/${widget.asset['id']}');
      if (mounted) {
        if (response.success && response.data != null) {
          setState(() {
            _asset = response.data as Map<String, dynamic>;
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = response.error ?? 'Failed to load asset';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _assignPersonnel() async {
    final personnelResponse = await ApiClient.get('/personnel');
    if (!personnelResponse.success || personnelResponse.data == null) return;

    final List<dynamic> personnel = personnelResponse.data as List<dynamic>;
    final availablePersonnel = personnel.where((p) {
      if (_asset!['personnelId'] != null && p['id'] == _asset!['personnelId']) return false;
      return true;
    }).toList();

    if (availablePersonnel.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No available personnel to assign')),
      );
      return;
    }

    String? selectedPersonnelId;
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.primaryNavy,
        title: const Text('Assign Personnel', style: TextStyle(color: Colors.white)),
        content: SizedBox(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: availablePersonnel.map((p) => RadioListTile<String>(
              title: Text('${p['name']} (${p['role']})', style: const TextStyle(color: Colors.white70)),
              value: p['id'].toString(),
              groupValue: selectedPersonnelId,
              onChanged: (v) => setState(() => selectedPersonnelId = v),
              activeColor: AppTheme.accentCyan,
            )).toList(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
          ElevatedButton(
            onPressed: selectedPersonnelId != null ? () => Navigator.pop(context) : null,
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentCyan, foregroundColor: AppTheme.primaryNavy),
            child: const Text('ASSIGN'),
          ),
        ],
      ),
    );

    if (selectedPersonnelId == null) return;

    setState(() => _isLoading = true);
    try {
      final response = await ApiClient.post('/assets/${_asset!['id']}/assign', {'personnelId': int.parse(selectedPersonnelId!)});
      if (mounted) {
        if (response.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Asset assigned successfully'), backgroundColor: AppTheme.statusHealthy),
          );
          await _refreshAsset();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response.error ?? 'Assignment failed'), backgroundColor: AppTheme.statusCritical),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.statusCritical),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _unassignPersonnel() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiClient.post('/assets/${_asset!['id']}/unassign', {});
      if (mounted) {
        if (response.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Asset unassigned successfully'), backgroundColor: AppTheme.statusHealthy),
          );
          await _refreshAsset();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response.error ?? 'Unassignment failed'), backgroundColor: AppTheme.statusCritical),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.statusCritical),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateStatus() async {
    final statuses = ['AVAILABLE', 'ASSIGNED', 'IN_USE', 'MAINTENANCE', 'DAMAGED', 'LOST', 'RETIRED'];
    String selectedStatus = _asset!['status'] ?? 'AVAILABLE';

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.primaryNavy,
        title: const Text('Update Status', style: TextStyle(color: Colors.white)),
        content: SizedBox(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: statuses.map((s) => RadioListTile<String>(
              title: Text(s, style: const TextStyle(color: Colors.white70)),
              value: s,
              groupValue: selectedStatus,
              onChanged: (v) => setState(() => selectedStatus = v!),
              activeColor: AppTheme.accentCyan,
            )).toList(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentCyan, foregroundColor: AppTheme.primaryNavy),
            child: const Text('UPDATE'),
          ),
        ],
      ),
    );

    if (selectedStatus == _asset!['status']) return;

    setState(() => _isLoading = true);
    try {
      final response = await ApiClient.patch('/assets/${_asset!['id']}/status', {'status': selectedStatus});
      if (mounted) {
        if (response.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Status updated successfully'), backgroundColor: AppTheme.statusHealthy),
          );
          await _refreshAsset();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response.error ?? 'Status update failed'), backgroundColor: AppTheme.statusCritical),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.statusCritical),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _editAsset() async {
    // Fetch reference data for form
    final missionsResponse = await ApiClient.get('/missions');
    final stationsResponse = await ApiClient.get('/stations');
    final personnelResponse = await ApiClient.get('/personnel');

    final missions = missionsResponse.success && missionsResponse.data != null 
        ? (missionsResponse.data as List).cast<Map<String, dynamic>>() 
        : <Map<String, dynamic>>[];
    final stations = stationsResponse.success && stationsResponse.data != null 
        ? (stationsResponse.data as List).cast<Map<String, dynamic>>() 
        : <Map<String, dynamic>>[];
    final personnel = personnelResponse.success && personnelResponse.data != null 
        ? (personnelResponse.data as List).cast<Map<String, dynamic>>() 
        : <Map<String, dynamic>>[];

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AssetFormScreen(
          asset: _asset,
          missions: missions,
          stations: stations,
          personnel: personnel,
        ),
      ),
    );

    if (result == true) {
      await _refreshAsset();
    }
  }

  @override
  Widget build(BuildContext context) {
    final asset = _asset ?? widget.asset;

    // Build the body content based on state
    Widget body;
    if (_isLoading) {
      body = const Center(child: CircularProgressIndicator(color: AppTheme.accentCyan));
    } else if (_errorMessage.isNotEmpty) {
      body = Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: AppTheme.statusCritical, size: 48),
            const SizedBox(height: AppTheme.spacingMd),
            Text(_errorMessage, style: const TextStyle(color: AppTheme.textMain)),
            const SizedBox(height: AppTheme.spacingMd),
            ElevatedButton(
              onPressed: _refreshAsset,
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentCyan, foregroundColor: AppTheme.primaryNavy),
              child: const Text('RETRY'),
            ),
          ],
        ),
      );
    } else {
      body = SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.accentCyan.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.precision_manufacturing, color: AppTheme.accentCyan, size: 32),
                ),
                const SizedBox(width: AppTheme.spacingMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        asset['assetTag'] ?? '—',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.accentCyan,
                        ),
                      ),
                      Text(
                        asset['name'] ?? '—',
                        style: const TextStyle(fontSize: 16, color: AppTheme.textMuted),
                      ),
                    ],
                  ),
                ),
                StatusBadge(
                  label: asset['status'] ?? 'UNKNOWN',
                  color: _getStatusColor(asset['status']),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingLg),

            // Basic Info Card
            _buildInfoCard(
              'Basic Information',
              Icons.info_outline,
              [
                _buildInfoRow('Asset Code', asset['assetTag']),
                _buildInfoRow('Name', asset['name']),
                _buildInfoRow('Category', asset['category']),
                _buildInfoRow('Description', asset['description']),
                _buildInfoRow('Serial Number', asset['serialNumber']),
                _buildInfoRow('Manufacturer', asset['manufacturer']),
                _buildInfoRow('Model', asset['model']),
                _buildInfoRow('Quantity', asset['quantity']?.toString()),
                _buildInfoRow('Location', asset['location']),
              ],
            ),

            // Status & Condition Card
            _buildInfoCard(
              'Status & Condition',
              Icons.monitor_heart,
              [
                _buildInfoRow('Status', asset['status'], 
                    badge: StatusBadge(label: asset['status'] ?? 'UNKNOWN', color: _getStatusColor(asset['status']))),
                _buildInfoRow('Condition', asset['condition'],
                    badge: StatusBadge(label: asset['condition'] ?? 'UNKNOWN', color: _getConditionColor(asset['condition']))),
                _buildInfoRow('Criticality', asset['criticality'],
                    badge: StatusBadge(label: asset['criticality'] ?? 'UNKNOWN', color: _getCriticalityColor(asset['criticality']))),
              ],
            ),

            // Assignment Card
            _buildAssignmentCard(asset),

            // Dates & Costs Card
            _buildInfoCard(
              'Dates & Costs',
              Icons.calendar_today,
              [
                _buildInfoRow('Purchase Date', asset['purchaseDate']),
                _buildInfoRow('Purchase Cost', asset['purchaseCost'] != null ? '\$${asset['purchaseCost']}' : '—'),
                _buildInfoRow('Last Maintenance', asset['lastMaintenanceDate']),
                _buildInfoRow('Next Maintenance', asset['nextMaintenanceDate']),
              ],
            ),

            // Mission/Station Card
            if (asset['missionId'] != null || asset['stationId'] != null)
              _buildInfoCard(
                'Mission & Station',
                Icons.account_balance,
                [
                  if (asset['missionId'] != null)
                    _buildInfoRow('Mission', asset['missionCode'] ?? asset['missionName'] ?? 'ID: ${asset['missionId']}'),
                  if (asset['stationId'] != null)
                    _buildInfoRow('Station', asset['stationName'] ?? 'ID: ${asset['stationId']}'),
                ],
              ),

            // Action Buttons
            if (AuthService.isAdmin || AuthService.isOfficer) ...[
              const SizedBox(height: AppTheme.spacingXl),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _asset!['status'] == 'ASSIGNED' || _asset!['status'] == 'IN_USE'
                          ? _unassignPersonnel
                          : _assignPersonnel,
                      icon: Icon(_asset!['status'] == 'ASSIGNED' || _asset!['status'] == 'IN_USE' 
                          ? Icons.person_remove : Icons.person_add),
                      label: Text(_asset!['status'] == 'ASSIGNED' || _asset!['status'] == 'IN_USE' 
                          ? 'UNASSIGN PERSONNEL' : 'ASSIGN PERSONNEL'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: _asset!['status'] == 'ASSIGNED' || _asset!['status'] == 'IN_USE' 
                            ? AppTheme.statusWarning : AppTheme.accentCyan,
                        foregroundColor: _asset!['status'] == 'ASSIGNED' || _asset!['status'] == 'IN_USE' 
                            ? AppTheme.primaryNavy : AppTheme.primaryNavy,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingMd),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _updateStatus,
                      icon: const Icon(Icons.swap_vert),
                      label: const Text('CHANGE STATUS'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: AppTheme.accentCyan.withValues(alpha: 0.5)),
                        foregroundColor: AppTheme.accentCyan,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.primaryNavy,
      appBar: AppBar(
        title: Text('Asset: ${asset['assetTag']}'),
        backgroundColor: AppTheme.secondaryNavy,
        foregroundColor: AppTheme.accentCyan,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshAsset,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _editAsset,
            tooltip: 'Edit Asset',
          ),
        ],
      ),
      body: body,
    );
  }

  Widget _buildInfoCard(String title, IconData icon, List<Widget> children) {
    return Card(
      color: AppTheme.secondaryNavy,
      margin: const EdgeInsets.only(bottom: AppTheme.spacingLg),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppTheme.accentCyan, size: 20),
                const SizedBox(width: AppTheme.spacingSm),
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textMain)),
              ],
            ),
            const SizedBox(height: AppTheme.spacingMd),
            ...children,
          ],
        ),
      ),
    );
  }

Widget _buildAssignmentCard(Map<String, dynamic> asset) {
    final isAssigned = asset['status'] == 'ASSIGNED' || asset['status'] == 'IN_USE';
    final personnelName = asset['personnelName'] ?? 'Unassigned';

    final List<Widget> children = [
      Row(
        children: [
          Icon(Icons.assignment_ind, color: AppTheme.accentCyan, size: 20),
          const SizedBox(width: AppTheme.spacingSm),
          Text('Assignment', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textMain)),
        ],
      ),
      const SizedBox(height: AppTheme.spacingMd),
      _buildInfoRow('Current Custodian', personnelName,
          badge: isAssigned 
              ? StatusBadge(label: 'ASSIGNED', color: AppTheme.statusHealthy)
              : StatusBadge(label: 'UNASSIGNED', color: AppTheme.textMuted)),
    ];

    if (asset['userId'] != null) {
      children.add(_buildInfoRow('Linked User', asset['userEmail'] ?? 'ID: ${asset['userId']}'));
    }

    return Card(
      color: AppTheme.secondaryNavy,
      margin: const EdgeInsets.only(bottom: AppTheme.spacingLg),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value, {Widget? badge}) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 14)),
          ),
          Expanded(
            child: Row(
              children: [
                Text(value, style: const TextStyle(color: AppTheme.textMain, fontSize: 14)),
                if (badge != null) ...[
                  const SizedBox(width: AppTheme.spacingSm),
                  badge,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'AVAILABLE': return AppTheme.statusHealthy;
      case 'ASSIGNED':
      case 'IN_USE': return AppTheme.statusWarning;
      case 'MAINTENANCE': return AppTheme.statusNeutral;
      case 'DAMAGED': return AppTheme.statusCritical;
      case 'LOST': return AppTheme.statusCritical;
      case 'RETIRED': return AppTheme.textMuted;
      default: return AppTheme.textMuted;
    }
  }

  Color _getConditionColor(String? condition) {
    switch (condition) {
      case 'EXCELLENT': return AppTheme.statusHealthy;
      case 'GOOD': return Colors.lightGreen;
      case 'FAIR': return AppTheme.statusWarning;
      case 'POOR': return AppTheme.statusCritical;
      default: return AppTheme.textMuted;
    }
  }

  Color _getCriticalityColor(String? criticality) {
    switch (criticality) {
      case 'CRITICAL': return AppTheme.statusCritical;
      case 'HIGH': return AppTheme.statusWarning;
      case 'MEDIUM': return AppTheme.statusNeutral;
      case 'LOW': return Colors.grey;
      default: return AppTheme.textMuted;
    }
  }
}