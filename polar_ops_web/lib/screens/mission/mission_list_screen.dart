import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/components/state_widgets.dart';
import '../../widgets/components/section_header.dart';
import '../../services/api/mission_service.dart';
import '../../services/auth/auth_service.dart';
import 'mission_details_screen.dart';

class MissionListScreen extends StatefulWidget {
  const MissionListScreen({super.key});

  @override
  State<MissionListScreen> createState() => _MissionListScreenState();
}

class _MissionListScreenState extends State<MissionListScreen> {
  bool _isLoading = true;
  String? _error;
  List<dynamic> _missions = [];

  @override
  void initState() {
    super.initState();
    _fetchMissions();
  }

  Future<void> _fetchMissions() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final response = await MissionService.getMissions();
    
    if (mounted) {
      if (response.success && response.data != null) {
        setState(() {
          _missions = response.data!;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = response.error ?? 'Unknown error loading missions';
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildMissionCard(dynamic mission) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingMd),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MissionDetailsScreen(missionCode: mission['missionCode']),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    mission['missionCode'] ?? 'UNKNOWN',
                    style: const TextStyle(
                      color: AppTheme.accentCyan,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(mission['status']).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: _getStatusColor(mission['status']).withValues(alpha: 0.5)),
                    ),
                    child: Text(
                      mission['status'] ?? 'UNKNOWN',
                      style: TextStyle(
                        color: _getStatusColor(mission['status']),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacingSm),
              Text(
                mission['missionName'] ?? 'Unnamed Mission',
                style: const TextStyle(
                  color: AppTheme.textMain,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppTheme.spacingSm),
              Text(
                mission['objective'] ?? 'No objective specified',
                style: const TextStyle(color: AppTheme.textMuted),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'ACTIVE': return AppTheme.statusHealthy;
      case 'PLANNED': return AppTheme.accentCyan;
      case 'CLOSED':
      case 'COMPLETED': return AppTheme.textMuted;
      default: return AppTheme.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return StateWidgets.loadingState(message: 'Loading missions...');
    }

    if (_error != null) {
      return StateWidgets.errorState(message: _error!, onRetry: _fetchMissions);
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              title: 'Missions',
              trailing: IconButton(
                icon: const Icon(Icons.refresh, color: AppTheme.accentCyan),
                onPressed: _fetchMissions,
              ),
            ),
            const SizedBox(height: AppTheme.spacingLg),
            if (_missions.isEmpty)
              Expanded(child: StateWidgets.emptyState(message: 'No missions found'))
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _missions.length,
                  itemBuilder: (context, index) {
                    return _buildMissionCard(_missions[index]);
                  },
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: AuthService.hasRole(['ADMIN', 'MISSION_OFFICER']) 
          ? FloatingActionButton(
              onPressed: () => _showCreateMissionDialog(context),
              backgroundColor: AppTheme.accentCyan,
              child: const Icon(Icons.add, color: AppTheme.primaryNavy),
            )
          : null,
    );
  }

  void _showCreateMissionDialog(BuildContext context) {
    final titleController = TextEditingController();
    final objectiveController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.secondaryNavy,
        title: const Text('Create New Mission', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Mission Title/Name',
                labelStyle: TextStyle(color: AppTheme.textMuted),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: objectiveController,
              decoration: const InputDecoration(
                labelText: 'Mission Objective',
                labelStyle: TextStyle(color: AppTheme.textMuted),
              ),
              style: const TextStyle(color: Colors.white),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () async {
              if (titleController.text.trim().isEmpty) return;
              final data = {
                'missionName': titleController.text.trim(),
                'objective': objectiveController.text.trim(),
                // In a real app, expedition selection would be here. Hardcoding ID 1 for now.
                'expedition': {'id': 1} 
              };
              Navigator.pop(ctx);
              final res = await MissionService.createMission(data);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(res.success ? 'Mission Created' : (res.error ?? 'Error creating mission')),
                  backgroundColor: res.success ? AppTheme.statusHealthy : AppTheme.statusCritical,
                ));
                if (res.success) _fetchMissions();
              }
            },
            child: const Text('CREATE', style: TextStyle(color: AppTheme.accentCyan)),
          ),
        ],
      ),
    );
  }
}
