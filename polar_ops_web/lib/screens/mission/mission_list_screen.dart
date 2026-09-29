import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/components/state_widgets.dart';
import '../../widgets/components/section_header.dart';
import '../../services/api/mission_service.dart';
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

    return Padding(
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
    );
  }
}
