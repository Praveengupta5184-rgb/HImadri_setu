import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/auth/auth_service.dart';
import '../../services/user/user_management_service.dart';
import '../../widgets/components/state_widgets.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> _pendingUsers = [];
  List<dynamic> _allUsers = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchUsers();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchUsers() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    final pendingResult = await UserManagementService.fetchPendingUsers();
    final allResult = await UserManagementService.fetchAllUsers();

    if (!mounted) return;
    setState(() {
      _pendingUsers = pendingResult.success && pendingResult.data != null
          ? pendingResult.data!
          : [];
      _allUsers = allResult.success && allResult.data != null
          ? allResult.data!
          : [];
      _isLoading = false;
      if (!pendingResult.success && !allResult.success) {
        _error = pendingResult.error ?? allResult.error ?? 'Unknown error';
      }
    });
  }

  Future<void> _approveUser(int userId) async {
    final result = await UserManagementService.approveUser(userId);
    if (!mounted) return;
    if (result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('User approved successfully'),
            backgroundColor: AppTheme.statusHealthy),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(result.error ?? 'Approval failed'),
            backgroundColor: AppTheme.statusCritical),
      );
    }
    _fetchUsers();
  }

  Future<void> _rejectUser(int userId) async {
    final result = await UserManagementService.rejectUser(userId);
    if (!mounted) return;
    if (result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('User rejected'),
            backgroundColor: AppTheme.statusWarning),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(result.error ?? 'Rejection failed'),
            backgroundColor: AppTheme.statusCritical),
      );
    }
    _fetchUsers();
  }

  Future<void> _assignRole(int userId, String currentRole) async {
    String selectedRole = currentRole;
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.primaryNavy,
        title: const Text('Assign System Role',
            style: TextStyle(color: Colors.white)),
        content: SizedBox(
          width: 320,
           child: DropdownButtonFormField<String>(
            initialValue: selectedRole,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppTheme.primaryNavy,
              border: OutlineInputBorder(
                  borderSide: BorderSide(color: AppTheme.textMuted.withValues(alpha: 0.3)),
                  borderRadius: BorderRadius.circular(8)),
            ),
            dropdownColor: AppTheme.secondaryNavy,
            style: const TextStyle(color: Colors.white),
            items: UserManagementService.systemRoles.map((role) {
              return DropdownMenuItem(
                value: role,
                child: Text(role),
              );
            }).toList(),
            onChanged: (v) => selectedRole = v!,
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('CANCEL')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentCyan, foregroundColor: AppTheme.primaryNavy),
            child: const Text('ASSIGN'),
          ),
        ],
      ),
    );

    if (result != true) return;
    final assignResult = await UserManagementService.assignRole(userId, selectedRole);
    if (!mounted) return;
    if (assignResult.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Role updated to $selectedRole'), backgroundColor: AppTheme.statusHealthy),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(assignResult.error ?? 'Role assignment failed'), backgroundColor: AppTheme.statusCritical),
      );
    }
    _fetchUsers();
  }

  Widget _buildUserTable(List<dynamic> users,
      {bool showActions = false}) {
    if (users.isEmpty) {
      return StateWidgets.emptyState(message: 'No users found.');
    }
    return SingleChildScrollView(
      child: DataTable(
        columnSpacing: 20,
        headingRowColor:
            WidgetStateProperty.all(AppTheme.secondaryNavy),
        columns: [
          const DataColumn(
              label: Text('ID',
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 11))),
          const DataColumn(
              label: Text('Name',
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 11))),
          const DataColumn(
              label: Text('Email',
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 11))),
          const DataColumn(
              label: Text('Role',
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 11))),
          const DataColumn(
              label: Text('Status',
                  style:
                  TextStyle(color: AppTheme.textMuted, fontSize: 11))),
          if (showActions)
            const DataColumn(
                label: Text('Actions',
                    style:
                    TextStyle(color: AppTheme.textMuted, fontSize: 11))),
        ],
        rows: users.map((u) {
          final id = u['id'];
          final name = u['name'] ?? '—';
          final email = u['email'] ?? '—';
          final role = u['role'] ?? 'PERSONNEL';
          final status = u['status'] ?? 'ACTIVE';
          return DataRow(cells: [
            DataCell(Text('$id',
                style:
                    const TextStyle(color: AppTheme.textMain, fontSize: 13))),
            DataCell(Text('$name',
                style:
                    const TextStyle(color: AppTheme.textMain, fontSize: 13))),
            DataCell(Text('$email',
                style:
                    const TextStyle(color: AppTheme.textMuted, fontSize: 13))),
            DataCell(
              Text('$role',
                  style: TextStyle(
                      color: role == 'ADMIN'
                          ? AppTheme.statusCritical
                          : AppTheme.accentCyan,
                      fontSize: 13)),
            ),
            DataCell(_buildStatusBadge(status)),
            if (showActions)
              DataCell(_buildActionButtons(id, role, status)),
          ]);
        }).toList(),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        color = AppTheme.statusHealthy;
        break;
      case 'PENDING':
        color = AppTheme.statusWarning;
        break;
      case 'REJECTED':
        color = AppTheme.statusCritical;
        break;
      default:
        color = AppTheme.textMuted;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(status,
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildActionButtons(int userId, String role, String status) {
    if (status == 'PENDING') {
      return Row(
        children: [
          Tooltip(
            message: 'Approve user',
            child: IconButton(
              icon: const Icon(Icons.check_circle,
                  color: AppTheme.statusHealthy, size: 18),
              onPressed: () => _approveUser(userId),
            ),
          ),
          Tooltip(
            message: 'Reject user',
            child: IconButton(
              icon: const Icon(Icons.cancel,
                  color: AppTheme.statusCritical, size: 18),
              onPressed: () => _rejectUser(userId),
            ),
          ),
        ],
      );
    }
    return Row(
      children: [
        Tooltip(
          message: 'Assign role',
          child: IconButton(
            icon: const Icon(Icons.edit,
                color: AppTheme.accentCyan, size: 18),
            onPressed: () => _assignRole(userId, role),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!AuthService.isAdmin) {
      return const Scaffold(
        body: Center(
          child: Text('Access denied. Admin privileges required.',
              style: TextStyle(color: AppTheme.textMuted)),
        ),
      );
    }

    return Scaffold(
      body: _isLoading
          ? StateWidgets.loadingState(message: 'Loading user management...')
          : _error.isNotEmpty
              ? StateWidgets.errorState(message: _error, onRetry: _fetchUsers)
              : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding:
                            const EdgeInsets.all(AppTheme.spacingMd),
                        child: Text('USER MANAGEMENT',
                            style: TextStyle(
                                color: AppTheme.accentCyan,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2)),
                      ),
                      TabBar(
                        controller: _tabController,
                        indicatorColor: AppTheme.accentCyan,
                        labelColor: AppTheme.accentCyan,
                        unselectedLabelColor: AppTheme.textMuted,
                        tabs: const [
                          Tab(text: 'PENDING APPROVAL',),
                          Tab(text: 'ALL USERS'),
                        ],
                      ),
                      const SizedBox(height: 0),
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            RefreshIndicator(
                              onRefresh: _fetchUsers,
                              child: _buildUserTable(_pendingUsers,
                                  showActions: true),
                            ),
                            RefreshIndicator(
                              onRefresh: _fetchUsers,
                              child: _buildUserTable(_allUsers,
                                  showActions: true),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
  }
}
