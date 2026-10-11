import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/api/team_service.dart';

class MyTeamScreen extends StatefulWidget {
  const MyTeamScreen({super.key});

  @override
  State<MyTeamScreen> createState() => _MyTeamScreenState();
}

class _MyTeamScreenState extends State<MyTeamScreen> {
  final _teamIdController = TextEditingController();
  bool _isLoading = false;
  bool _isLoadingMyTeams = true;
  String? _error;
  Map<String, dynamic>? _teamData;
  List<dynamic> _myTeams = [];

  @override
  void initState() {
    super.initState();
    _loadMyTeams();
  }

  @override
  void dispose() {
    _teamIdController.dispose();
    super.dispose();
  }

  Future<void> _loadMyTeams() async {
    setState(() => _isLoadingMyTeams = true);
    final res = await TeamService.getMyTeams();
    if (mounted) {
      setState(() {
        _myTeams = (res.data ?? []);
        _isLoadingMyTeams = false;
      });
    }
  }

  Future<void> _lookupTeam() async {
    final code = _teamIdController.text.trim();
    if (code.isEmpty) {
      setState(() => _error = 'Enter a Team ID.');
      return;
    }
    setState(() {
      _isLoading = true;
      _error = null;
      _teamData = null;
    });

    final res = await TeamService.getTeamMembers(code);
    if (!mounted) return;

    if (res.success) {
      setState(() {
        _teamData = res.data;
        _isLoading = false;
      });
    } else {
      String errorMsg;
      if (res.error != null && res.error!.contains('403')) {
        errorMsg = 'ACCESS DENIED — You are not authorized to view this team.';
      } else if (res.error != null && res.error!.contains('404')) {
        errorMsg = 'Team not found.';
      } else if (res.error != null && res.error!.contains('401')) {
        errorMsg = 'Session expired. Please log in again.';
      } else {
        errorMsg = res.error ?? 'Unable to load team data. Check backend connection.';
      }
      setState(() {
        _error = errorMsg;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Icon(Icons.groups, color: AppTheme.accentCyan, size: 28),
              const SizedBox(width: AppTheme.spacingSm),
              const Text(
                'TEAM MEMBER LOOKUP',
                style: TextStyle(
                  color: AppTheme.accentCyan,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Enter a Team ID to view authorized team member information.',
            style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
          ),

          const SizedBox(height: AppTheme.spacingMd),

          // My Teams hint
          if (_isLoadingMyTeams)
            const SizedBox.shrink()
          else if (_myTeams.isNotEmpty) ...[
            Card(
              color: AppTheme.secondaryNavy,
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacingMd),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'YOUR ACTIVE TEAMS',
                      style: TextStyle(
                        color: AppTheme.accentCyan,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingSm),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _myTeams.map((t) {
                        final code = t['teamCode'] ?? '';
                        final name = t['teamName'] ?? '';
                        return ActionChip(
                          label: Text(
                            name.isNotEmpty ? '$name ($code)' : code,
                            style: const TextStyle(
                                color: AppTheme.accentCyan, fontSize: 12),
                          ),
                          backgroundColor:
                              AppTheme.accentCyan.withOpacity(0.1),
                          side: const BorderSide(
                              color: AppTheme.accentCyan, width: 0.5),
                          onPressed: () {
                            _teamIdController.text = code;
                            _lookupTeam();
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spacingMd),
          ],

          // Search Card
          Card(
            color: AppTheme.secondaryNavy,
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'TEAM ID LOOKUP',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingMd),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _teamIdController,
                          style: const TextStyle(color: AppTheme.textMain),
                          decoration: InputDecoration(
                            labelText: 'Team ID (e.g. TEAM-ALPHA-001)',
                            labelStyle:
                                const TextStyle(color: AppTheme.textMuted),
                            prefixIcon: const Icon(Icons.badge,
                                color: AppTheme.accentCyan),
                            border: const OutlineInputBorder(),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: AppTheme.accentCyan.withOpacity(0.3)),
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: AppTheme.accentCyan),
                            ),
                          ),
                          onSubmitted: (_) => _lookupTeam(),
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacingMd),
                      ElevatedButton.icon(
                        onPressed: _isLoading ? null : _lookupTeam,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accentCyan,
                          foregroundColor: AppTheme.primaryNavy,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 16),
                        ),
                        icon: _isLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppTheme.primaryNavy))
                            : const Icon(Icons.search),
                        label:
                            Text(_isLoading ? 'LOADING...' : 'VIEW TEAM'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppTheme.spacingMd),

          // Error display
          if (_error != null)
            Card(
              color: _error!.contains('ACCESS DENIED')
                  ? AppTheme.statusCritical.withOpacity(0.12)
                  : AppTheme.statusWarning.withOpacity(0.12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: _error!.contains('ACCESS DENIED')
                      ? AppTheme.statusCritical
                      : AppTheme.statusWarning,
                  width: 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacingMd),
                child: Row(
                  children: [
                    Icon(
                      _error!.contains('ACCESS DENIED')
                          ? Icons.block
                          : Icons.info_outline,
                      color: _error!.contains('ACCESS DENIED')
                          ? AppTheme.statusCritical
                          : AppTheme.statusWarning,
                      size: 20,
                    ),
                    const SizedBox(width: AppTheme.spacingSm),
                    Expanded(
                      child: Text(
                        _error!,
                        style: TextStyle(
                          color: _error!.contains('ACCESS DENIED')
                              ? AppTheme.statusCritical
                              : AppTheme.statusWarning,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Team result
          if (_teamData != null) _buildTeamView(_teamData!),
        ],
      ),
    );
  }

  Widget _buildTeamView(Map<String, dynamic> data) {
    final members = (data['members'] as List<dynamic>?) ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Team Header
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data['teamName'] ?? data['teamCode'] ?? 'TEAM',
                          style: const TextStyle(
                            color: AppTheme.accentCyan,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                        Text(
                          data['teamCode'] ?? '-',
                          style: const TextStyle(
                              color: AppTheme.textMuted, fontSize: 13),
                        ),
                      ],
                    ),
                    _statusBadge(data['status'] ?? 'UNKNOWN'),
                  ],
                ),
                const Divider(height: 24),
                _infoRow('Mission', '${data['missionName'] ?? '-'} (${data['missionCode'] ?? '-'})'),
                _infoRow('Team Lead', data['teamLeadName'] ?? 'Not assigned'),
                _infoRow('Active Members', '${data['memberCount'] ?? members.length}'),
              ],
            ),
          ),
        ),

        const SizedBox(height: AppTheme.spacingMd),
        const Text(
          'TEAM MEMBERS',
          style: TextStyle(
            color: AppTheme.accentCyan,
            fontSize: 13,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: AppTheme.spacingSm),

        if (members.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(AppTheme.spacingMd),
              child: Text(
                'No active members found for this team.',
                style: TextStyle(color: AppTheme.textMuted),
              ),
            ),
          )
        else
          ...members.map((m) => _buildMemberCard(m)).toList(),
      ],
    );
  }

  Widget _buildMemberCard(Map<String, dynamic> m) {
    final location = m['location'] as Map<String, dynamic>?;
    final hasLocation = location != null;
    final updatedAt = location?['updatedAt']?.toString();
    final availability = m['availability'] ?? '-';

    Color statusColor = AppTheme.textMuted;
    if (availability == 'DEPLOYED') statusColor = AppTheme.statusHealthy;
    else if (availability == 'IN_TRANSIT') statusColor = AppTheme.statusWarning;
    else if (availability == 'MOBILIZING') statusColor = AppTheme.accentCyan;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: AppTheme.accentCyan.withOpacity(0.15),
              radius: 22,
              child: Text(
                (m['name'] ?? 'P').substring(0, 1).toUpperCase(),
                style: const TextStyle(
                    color: AppTheme.accentCyan,
                    fontWeight: FontWeight.bold,
                    fontSize: 18),
              ),
            ),
            const SizedBox(width: AppTheme.spacingMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        m['name'] ?? '-',
                        style: const TextStyle(
                            color: AppTheme.textMain,
                            fontWeight: FontWeight.bold,
                            fontSize: 15),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: statusColor, width: 0.5),
                        ),
                        child: Text(
                          availability,
                          style: TextStyle(
                              color: statusColor,
                              fontSize: 10,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Role: ${m['role'] ?? '-'}  ·  ID: ${m['personnelId'] ?? '-'}',
                    style: const TextStyle(
                        color: AppTheme.textMuted, fontSize: 12),
                  ),
                  const SizedBox(height: 6),
                  if (hasLocation) ...[
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            size: 14, color: AppTheme.statusWarning),
                        const SizedBox(width: 4),
                        Text(
                          'Last known: ${_formatCoord(location!['latitude'])}, ${_formatCoord(location['longitude'])}',
                          style: const TextStyle(
                              color: AppTheme.textMuted, fontSize: 12),
                        ),
                      ],
                    ),
                    if (updatedAt != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2, left: 18),
                        child: Text(
                          'Updated: ${_formatTimestamp(updatedAt)}',
                          style: const TextStyle(
                              color: AppTheme.textMuted, fontSize: 11),
                        ),
                      ),
                  ] else
                    const Row(
                      children: [
                        Icon(Icons.location_off,
                            size: 14, color: AppTheme.textMuted),
                        SizedBox(width: 4),
                        Text(
                          'Location: Not available',
                          style: TextStyle(
                              color: AppTheme.textMuted, fontSize: 12),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label,
                style: const TextStyle(
                    color: AppTheme.textMuted, fontSize: 13)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    color: AppTheme.textMain,
                    fontSize: 13,
                    fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(String status) {
    Color c = AppTheme.textMuted;
    if (status == 'ACTIVE') c = AppTheme.statusHealthy;
    else if (status == 'INACTIVE') c = AppTheme.statusWarning;
    else if (status == 'CLOSED') c = AppTheme.statusCritical;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: c.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: c, width: 1),
      ),
      child: Text(status,
          style: TextStyle(
              color: c, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  String _formatCoord(dynamic val) {
    if (val == null) return '?';
    if (val is double) return val.toStringAsFixed(5);
    return val.toString();
  }

  String _formatTimestamp(String ts) {
    try {
      final dt = DateTime.parse(ts).toLocal();
      final now = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inMinutes < 2) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      return '${diff.inDays}d ago';
    } catch (_) {
      return ts;
    }
  }
}
