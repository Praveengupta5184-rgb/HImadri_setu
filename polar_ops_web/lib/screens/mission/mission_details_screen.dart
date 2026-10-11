import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/components/state_widgets.dart';
import '../../widgets/components/metric_card.dart';
import '../../services/api/mission_service.dart';
import '../../services/auth/auth_service.dart';
import 'mission_map_panel.dart';

class MissionDetailsScreen extends StatefulWidget {
  final String missionCode;
  const MissionDetailsScreen({super.key, required this.missionCode});

  @override
  State<MissionDetailsScreen> createState() => _MissionDetailsScreenState();
}

class _MissionDetailsScreenState extends State<MissionDetailsScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _dashboard;
  List<dynamic> _teams = [];
  List<dynamic> _targets = [];
  List<dynamic> _assignments = [];
  List<dynamic> _members = [];
  List<dynamic> _locations = [];
  late TabController _tabController;

  static const _officerRoles = ['ADMIN', 'MISSION_OFFICER', 'STATION_OFFICER', 'LOGISTICS_OFFICER'];

  bool get _isOfficer => AuthService.hasRole(_officerRoles);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
    _fetchAll();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchAll() async {
    setState(() { _isLoading = true; _error = null; });

    final results = await Future.wait([
      MissionService.getMissionDashboard(widget.missionCode),
      MissionService.getTeams(widget.missionCode),
      MissionService.getTargets(widget.missionCode),
      MissionService.getAssignments(widget.missionCode),
      MissionService.getMembers(widget.missionCode),
      MissionService.getLocations(widget.missionCode),
    ]);

    if (!mounted) return;

    final dashRes = results[0];
    if (!dashRes.success) {
      setState(() { _error = dashRes.error; _isLoading = false; });
      return;
    }

    setState(() {
      _dashboard = dashRes.data as Map<String, dynamic>?;
      _teams = (results[1].data as List<dynamic>?) ?? [];
      _targets = (results[2].data as List<dynamic>?) ?? [];
      _assignments = (results[3].data as List<dynamic>?) ?? [];
      _members = (results[4].data as List<dynamic>?) ?? [];
      _locations = (results[5].data as List<dynamic>?) ?? [];
      _isLoading = false;
    });
  }

  Future<void> _updateMissionStatus(String newStatus) async {
    setState(() => _isLoading = true);
    final response = await MissionService.updateMissionStatus(widget.missionCode, newStatus);
    if (!mounted) return;
    if (response.success) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Mission status updated to $newStatus')));
      _fetchAll();
    } else {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update status: ${response.error}'), backgroundColor: AppTheme.statusCritical));
    }
  }

  Widget _buildOverview() {
    final m = _dashboard?['mission'] as Map<String, dynamic>?;
    if (m == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mission header card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(m['missionCode'] ?? '-',
                          style: const TextStyle(color: AppTheme.accentCyan,
                              fontSize: 22, fontWeight: FontWeight.bold,
                              letterSpacing: 1.5)),
                      Row(
                        children: [
                          _statusBadge(m['status']),
                          if (_isOfficer && m['status'] == 'PLANNED') ...[
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () => _updateMissionStatus('ACTIVE'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.statusHealthy,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                minimumSize: const Size(0, 0),
                              ),
                              child: const Text('ACTIVATE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(m['missionName'] ?? '-',
                      style: const TextStyle(color: AppTheme.textMain,
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(m['objective'] ?? '-',
                      style: const TextStyle(color: AppTheme.textMuted)),
                  if (m['startDate'] != null || m['endDate'] != null) ...[
                    const SizedBox(height: 8),
                    Row(children: [
                      const Icon(Icons.date_range, size: 14, color: AppTheme.textMuted),
                      const SizedBox(width: 4),
                      Text('${m['startDate'] ?? '-'}  →  ${m['endDate'] ?? '-'}',
                          style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                    ]),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spacingMd),
          // Dashboard metrics grid
          const Text('MISSION DASHBOARD',
              style: TextStyle(color: AppTheme.accentCyan,
                  fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1)),
          const SizedBox(height: AppTheme.spacingSm),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 2.5,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: [
              MetricCard(
                  title: 'Teams',
                  value: '${_dashboard?['teamCount'] ?? 0}',
                  icon: Icons.groups,
                  iconColor: AppTheme.accentCyan),
              MetricCard(
                  title: 'Active Personnel',
                  value: '${_dashboard?['activePersonnel'] ?? 0}',
                  icon: Icons.person,
                  iconColor: AppTheme.statusHealthy),
              MetricCard(
                  title: 'Targets',
                  value: '${_dashboard?['targetCount'] ?? 0}',
                  icon: Icons.flag,
                  iconColor: AppTheme.statusWarning),
              MetricCard(
                  title: 'Assignments',
                  value: '${_dashboard?['assignmentCount'] ?? 0}',
                  icon: Icons.assignment,
                  iconColor: AppTheme.accentCyan),
              MetricCard(
                  title: 'Active Emergencies',
                  value: '${_dashboard?['activeEmergencies'] ?? 0}',
                  icon: Icons.warning,
                  iconColor: (_dashboard?['activeEmergencies'] ?? 0) > 0
                      ? AppTheme.statusCritical : AppTheme.statusHealthy),
              MetricCard(
                  title: 'Readiness',
                  value: '${_dashboard?['readiness'] ?? 0}%',
                  icon: Icons.health_and_safety,
                  iconColor: _readinessColor(_dashboard?['readiness'] ?? 0)),
            ],
          ),
          const SizedBox(height: AppTheme.spacingMd),
          // Progress bars
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('OPERATIONAL PROGRESS',
                      style: TextStyle(color: Colors.white,
                          fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 12),
                  _progressBar('Target Progress',
                      ((_dashboard?['targetProgress'] ?? 0.0) as num).toDouble()),
                  const SizedBox(height: 8),
                  _progressBar('Assignment Progress',
                      ((_dashboard?['assignmentProgress'] ?? 0.0) as num).toDouble()),
                  const SizedBox(height: 8),
                  _progressBar('Overall Mission Progress',
                      ((_dashboard?['missionProgress'] ?? 0.0) as num).toDouble()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _progressBar(String label, double value) {
    final pct = value.clamp(0.0, 100.0);
    Color barColor = AppTheme.statusHealthy;
    if (pct < 50) barColor = AppTheme.statusCritical;
    else if (pct < 75) barColor = AppTheme.statusWarning;

    return Row(children: [
      SizedBox(width: 160, child: Text(label,
          style: const TextStyle(color: AppTheme.textMuted, fontSize: 12))),
      Expanded(child: LinearProgressIndicator(
          value: pct / 100,
          backgroundColor: AppTheme.primaryNavy,
          valueColor: AlwaysStoppedAnimation<Color>(barColor))),
      SizedBox(width: 48, child: Text(' ${pct.toStringAsFixed(1)}%',
          style: const TextStyle(color: Colors.white, fontSize: 12),
          textAlign: TextAlign.right)),
    ]);
  }

  Widget _buildTeams() {
    if (_teams.isEmpty) return StateWidgets.emptyState(message: 'No teams found');
    return ListView.builder(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      itemCount: _teams.length,
      itemBuilder: (ctx, i) {
        final t = _teams[i];
        final teamMembers = _members.where((m) {
          final team = m['team'];
          return team != null && team['id'] == t['id'];
        }).toList();
        return Card(
          margin: const EdgeInsets.only(bottom: AppTheme.spacingMd),
          child: ExpansionTile(
            leading: const Icon(Icons.groups, color: AppTheme.accentCyan),
            title: Text(t['teamCode'] ?? '-',
                style: const TextStyle(color: AppTheme.accentCyan,
                    fontWeight: FontWeight.bold)),
            subtitle: Text(
                '${t['teamName'] ?? '-'}' + 
                (t['teamLeader'] != null ? ' • Lead: ${t['teamLeader']['name']}' : ''),
                style: const TextStyle(color: AppTheme.textMain)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _statusBadge(t['status']),
                if (_isOfficer) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.person_add, size: 20),
                    tooltip: 'Add Personnel',
                    onPressed: () => _showAddPersonnelDialog(t['id']),
                    color: AppTheme.accentCyan,
                  ),
                  IconButton(
                    icon: const Icon(Icons.star_outline, size: 20),
                    tooltip: 'Assign Team Leader',
                    onPressed: () => _showAssignLeaderDialog(t['id']),
                    color: AppTheme.statusWarning,
                  ),
                ],
              ],
            ),
            children: [
              if (teamMembers.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(AppTheme.spacingMd),
                  child: Text('No active members in this team.',
                      style: TextStyle(color: AppTheme.textMuted)),
                )
              else
                ...teamMembers.map((m) {
                  final p = m['personnel'] as Map<String, dynamic>?;
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.accentCyan.withValues(alpha: 0.2),
                      child: Text((p?['name'] ?? '?')[0].toUpperCase(),
                          style: const TextStyle(color: AppTheme.accentCyan)),
                    ),
                    title: Text(p?['name'] ?? 'Unknown',
                        style: const TextStyle(color: AppTheme.textMain)),
                    subtitle: Text(p?['designation'] ?? p?['role'] ?? '-',
                        style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                    trailing: _statusBadge(m['membershipStatus']),
                  );
                }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTargets() {
    if (_targets.isEmpty) return StateWidgets.emptyState(message: 'No targets found');
    return ListView.builder(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      itemCount: _targets.length,
      itemBuilder: (ctx, i) {
        final t = _targets[i];
        final progress = (t['completedValue'] ?? 0.0) as num;
        final total = (t['targetValue'] ?? 1.0) as num;
        final pct = total > 0 ? (progress / total).clamp(0.0, 1.0).toDouble() : 0.0;

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
                    Expanded(
                      child: Text(t['title'] ?? 'Untitled Target',
                          style: const TextStyle(color: AppTheme.textMain,
                              fontWeight: FontWeight.bold, fontSize: 15)),
                    ),
                    _statusBadge(t['status']),
                  ],
                ),
                if (t['description'] != null) ...[
                  const SizedBox(height: 4),
                  Text(t['description'],
                      style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
                const SizedBox(height: 8),
                Row(children: [
                  const Icon(Icons.groups, size: 12, color: AppTheme.textMuted),
                  const SizedBox(width: 4),
                  Text('Team: ${(t['team'] as Map?)?.containsKey('teamName') == true ? t['team']['teamName'] : (t['team'] as Map?)?['id'] ?? '-'}',
                      style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                  if (t['deadline'] != null) ...[
                    const SizedBox(width: 12),
                    const Icon(Icons.schedule, size: 12, color: AppTheme.textMuted),
                    const SizedBox(width: 4),
                    Text('Due: ${t['deadline']}',
                        style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                  ],
                ]),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(child: LinearProgressIndicator(
                      value: pct,
                      backgroundColor: AppTheme.primaryNavy,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          pct >= 1.0 ? AppTheme.statusHealthy
                              : pct > 0.5 ? AppTheme.statusWarning
                              : AppTheme.statusCritical))),
                  const SizedBox(width: 8),
                  Text('${(pct * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(color: Colors.white, fontSize: 12)),
                ]),
                if (_isOfficer) ...[
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () => _showUpdateTargetDialog(t),
                      icon: const Icon(Icons.edit, size: 14),
                      label: const Text('UPDATE PROGRESS', style: TextStyle(fontSize: 11)),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAssignments() {
    if (_assignments.isEmpty) return StateWidgets.emptyState(message: 'No assignments found');
    return ListView.builder(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      itemCount: _assignments.length,
      itemBuilder: (ctx, i) {
        final a = _assignments[i];
        final p = a['personnel'] as Map<String, dynamic>?;
        final progress = (a['completedValue'] ?? 0.0) as num;
        final total = (a['targetValue'] ?? 1.0) as num;
        final pct = total > 0 ? (progress / total).clamp(0.0, 1.0).toDouble() : 0.0;

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
                    Expanded(
                      child: Text(a['title'] ?? 'Untitled Assignment',
                          style: const TextStyle(color: AppTheme.textMain,
                              fontWeight: FontWeight.bold, fontSize: 15)),
                    ),
                    _statusBadge(a['status']),
                  ],
                ),
                const SizedBox(height: 6),
                Row(children: [
                  const Icon(Icons.person, size: 12, color: AppTheme.textMuted),
                  const SizedBox(width: 4),
                  Text('Personnel: ${p?['name'] ?? '-'}',
                      style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                  if (a['priority'] != null) ...[
                    const SizedBox(width: 12),
                    const Icon(Icons.priority_high, size: 12, color: AppTheme.textMuted),
                    const SizedBox(width: 4),
                    Text('Priority: ${a['priority']}',
                        style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                  ],
                ]),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(child: LinearProgressIndicator(
                      value: pct,
                      backgroundColor: AppTheme.primaryNavy,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          pct >= 1.0 ? AppTheme.statusHealthy
                              : pct > 0.5 ? AppTheme.statusWarning
                              : AppTheme.statusCritical))),
                  const SizedBox(width: 8),
                  Text('${(pct * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(color: Colors.white, fontSize: 12)),
                ]),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showUpdateTargetDialog(Map<String, dynamic> target) {
    final controller = TextEditingController(
        text: '${target['completedValue'] ?? 0}');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.secondaryNavy,
        title: Text('Update: ${target['title']}',
            style: const TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Completed Value',
            labelStyle: TextStyle(color: AppTheme.textMuted),
          ),
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx),
              child: const Text('CANCEL')),
          TextButton(
            onPressed: () async {
              final val = double.tryParse(controller.text);
              if (val == null) return;
              Navigator.pop(ctx);
              final res = await MissionService.updateTargetProgress(
                  widget.missionCode, target['id'], val);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(res.success
                      ? 'Target updated successfully'
                      : (res.error ?? 'Update failed')),
                  backgroundColor: res.success
                      ? AppTheme.statusHealthy : AppTheme.statusCritical,
                ));
                if (res.success) _fetchAll();
              }
            },
            child: const Text('UPDATE'),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(String? status) {
    Color c;
    switch (status) {
      case 'ACTIVE': c = AppTheme.statusHealthy; break;
      case 'PLANNED': c = AppTheme.accentCyan; break;
      case 'CLOSED':
      case 'COMPLETED': c = AppTheme.textMuted; break;
      case 'ASSIGNED': c = AppTheme.statusWarning; break;
      default: c = AppTheme.textMuted;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: c.withValues(alpha: 0.4)),
      ),
      child: Text(status ?? '-',
          style: TextStyle(color: c, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  Color _readinessColor(num v) {
    if (v >= 80) return AppTheme.statusHealthy;
    if (v >= 50) return AppTheme.statusWarning;
    return AppTheme.statusCritical;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.missionCode,
            style: const TextStyle(color: AppTheme.accentCyan,
                fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchAll,
            tooltip: 'Refresh',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Overview'),
            Tab(icon: Icon(Icons.groups), text: 'Teams'),
            Tab(icon: Icon(Icons.flag), text: 'Targets'),
            Tab(icon: Icon(Icons.assignment), text: 'Assignments'),
            Tab(icon: Icon(Icons.map), text: 'Map & Location'),
          ],
        ),
      ),
      body: _isLoading
          ? StateWidgets.loadingState(message: 'Loading mission data...')
          : _error != null
              ? StateWidgets.errorState(message: _error!, onRetry: _fetchAll)
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOverview(),
                    _buildTeams(),
                    _buildTargets(),
                    _buildAssignments(),
                    MissionMapPanel(
                      missionCode: widget.missionCode,
                      locations: _locations,
                      onRefresh: _fetchAll,
                    ),
                  ],
                ),
      floatingActionButton: (_isOfficer && _tabController.index == 1)
          ? FloatingActionButton(
              onPressed: () => _showCreateTeamDialog(),
              backgroundColor: AppTheme.accentCyan,
              child: const Icon(Icons.add, color: AppTheme.primaryNavy),
            )
          : null,
    );
  }

  void _showCreateTeamDialog() {
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.secondaryNavy,
        title: const Text('Create New Team', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Team Name',
            labelStyle: TextStyle(color: AppTheme.textMuted),
          ),
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) return;
              final data = {
                'teamName': nameController.text.trim(),
              };
              Navigator.pop(ctx);
              final res = await MissionService.createTeam(widget.missionCode, data);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(res.success ? 'Team Created' : (res.error ?? 'Error creating team')),
                  backgroundColor: res.success ? AppTheme.statusHealthy : AppTheme.statusCritical,
                ));
                if (res.success) _fetchAll();
              }
            },
            child: const Text('CREATE', style: TextStyle(color: AppTheme.accentCyan)),
          ),
        ],
      ),
    );
  }

  void _showAddPersonnelDialog(int teamId) {
    final personnelIdController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.secondaryNavy,
        title: const Text('Add Personnel to Team', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: personnelIdController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Personnel ID',
            hintText: 'Enter valid Personnel ID (e.g. 1, 2)',
            labelStyle: TextStyle(color: AppTheme.textMuted),
          ),
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () async {
              final pId = int.tryParse(personnelIdController.text.trim());
              if (pId == null) return;
              
              Navigator.pop(ctx);
              final res = await MissionService.addPersonnelToTeam(widget.missionCode, teamId, pId);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(res.success ? 'Personnel Added' : (res.error ?? 'Error adding personnel')),
                  backgroundColor: res.success ? AppTheme.statusHealthy : AppTheme.statusCritical,
                ));
                if (res.success) _fetchAll();
              }
            },
            child: const Text('ADD', style: TextStyle(color: AppTheme.accentCyan)),
          ),
        ],
      ),
    );
  }

  void _showAssignLeaderDialog(int teamId) {
    final personnelIdController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.secondaryNavy,
        title: const Text('Assign Team Leader', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: personnelIdController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Personnel ID',
            hintText: 'Enter valid Personnel ID (e.g. 1, 2)',
            labelStyle: TextStyle(color: AppTheme.textMuted),
          ),
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () async {
              final pId = int.tryParse(personnelIdController.text.trim());
              if (pId == null) return;
              
              Navigator.pop(ctx);
              final res = await MissionService.assignTeamLeader(widget.missionCode, teamId, pId);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(res.success ? 'Team Leader Assigned' : (res.error ?? 'Error assigning leader')),
                  backgroundColor: res.success ? AppTheme.statusHealthy : AppTheme.statusCritical,
                ));
                if (res.success) _fetchAll();
              }
            },
            child: const Text('ASSIGN', style: TextStyle(color: AppTheme.accentCyan)),
          ),
        ],
      ),
    );
  }
}
