import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/components/status_badge.dart';
import '../../services/api/api_client.dart';
import '../../services/auth/auth_service.dart';
import 'asset_form_screen.dart';
import 'asset_details_screen.dart';

class AssetScreen extends StatefulWidget {
  const AssetScreen({super.key});

  @override
  State<AssetScreen> createState() => _AssetScreenState();
}

class _AssetScreenState extends State<AssetScreen> {
  List<dynamic> _assets = [];
  List<dynamic> _filteredAssets = [];
  bool _isLoading = true;
  String _errorMessage = '';

  // Filter state
  String _searchQuery = '';
  String _statusFilter = 'ALL';
  String _categoryFilter = 'ALL';
  String _locationFilter = 'ALL';
  String _criticalityFilter = 'ALL';
  bool _showOnlyAssigned = false;
  bool _showOnlyAvailable = false;

  // Reference data for filters
  List<String> _categories = ['ALL'];
  List<String> _locations = ['ALL'];

  final List<String> _statusOptions = ['ALL', 'AVAILABLE', 'ASSIGNED', 'IN_USE', 'MAINTENANCE', 'DAMAGED', 'LOST', 'RETIRED'];
  final List<String> _criticalityOptions = ['ALL', 'LOW', 'MEDIUM', 'HIGH', 'CRITICAL'];

  @override
  void initState() {
    super.initState();
    _fetchAssets();
  }

  Future<void> _fetchAssets() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final response = await ApiClient.get('/assets');
      if (mounted) {
        if (response.success && response.data != null) {
          setState(() {
            _assets = response.data as List<dynamic>;
            _applyFilters();
            _extractFilterOptions();
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = response.error ?? 'Failed to load assets';
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

  void _extractFilterOptions() {
    final categories = _assets.map((a) => a['category']?.toString()).where((c) => c != null && c.isNotEmpty).toSet().toList()..sort();
    final locations = _assets.map((a) => a['location']?.toString()).where((l) => l != null && l.isNotEmpty).toSet().toList()..sort();

    setState(() {
      _categories = ['ALL', ...categories.cast<String>()];
      _locations = ['ALL', ...locations.cast<String>()];
    });
  }

  void _applyFilters() {
    List<dynamic> filtered = List.from(_assets);

    // Search query
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((a) {
        return (a['assetTag']?.toString().toLowerCase().contains(query) ?? false) ||
               (a['name']?.toString().toLowerCase().contains(query) ?? false) ||
               (a['serialNumber']?.toString().toLowerCase().contains(query) ?? false);
      }).toList();
    }

    // Status filter
    if (_statusFilter != 'ALL') {
      filtered = filtered.where((a) => a['status'] == _statusFilter).toList();
    }

    // Category filter
    if (_categoryFilter != 'ALL') {
      filtered = filtered.where((a) => a['category'] == _categoryFilter).toList();
    }

    // Location filter
    if (_locationFilter != 'ALL') {
      filtered = filtered.where((a) => a['location'] == _locationFilter).toList();
    }

    // Criticality filter
    if (_criticalityFilter != 'ALL') {
      filtered = filtered.where((a) => a['criticality'] == _criticalityFilter).toList();
    }

    // Assignment filters
    if (_showOnlyAssigned) {
      filtered = filtered.where((a) => a['status'] == 'ASSIGNED' || a['status'] == 'IN_USE').toList();
    }
    if (_showOnlyAvailable) {
      filtered = filtered.where((a) => a['status'] == 'AVAILABLE').toList();
    }

    setState(() {
      _filteredAssets = filtered;
    });
  }

  void _clearFilters() {
    setState(() {
      _searchQuery = '';
      _statusFilter = 'ALL';
      _categoryFilter = 'ALL';
      _locationFilter = 'ALL';
      _criticalityFilter = 'ALL';
      _showOnlyAssigned = false;
      _showOnlyAvailable = false;
      _applyFilters();
    });
  }

  bool _hasActiveFilters() {
    return _searchQuery.isNotEmpty ||
           _statusFilter != 'ALL' ||
           _categoryFilter != 'ALL' ||
           _locationFilter != 'ALL' ||
           _criticalityFilter != 'ALL' ||
           _showOnlyAssigned ||
           _showOnlyAvailable;
  }

  void _openCreateAsset() async {
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
          missions: missions,
          stations: stations,
          personnel: personnel,
        ),
      ),
    );

    if (result == true) {
      _fetchAssets();
    }
  }

  void _openEditAsset(Map<String, dynamic> asset) async {
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
          asset: asset,
          missions: missions,
          stations: stations,
          personnel: personnel,
        ),
      ),
    );

    if (result == true) {
      _fetchAssets();
    }
  }

  void _openAssetDetails(Map<String, dynamic> asset) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AssetDetailsScreen(asset: asset),
      ),
    );

    if (result == true) {
      _fetchAssets();
    }
  }

  List<Widget> _buildFilterChips() {
    return [
      _buildDropdownFilter('Status', _statusFilter, _statusOptions, (v) => setState(() { _statusFilter = v; _applyFilters(); })),
      _buildDropdownFilter('Category', _categoryFilter, _categories, (v) => setState(() { _categoryFilter = v; _applyFilters(); })),
      _buildDropdownFilter('Location', _locationFilter, _locations, (v) => setState(() { _locationFilter = v; _applyFilters(); })),
      _buildDropdownFilter('Criticality', _criticalityFilter, _criticalityOptions, (v) => setState(() { _criticalityFilter = v; _applyFilters(); })),
      FilterChip(
        label: const Text('Assigned Only', style: TextStyle(color: Colors.white)),
        selected: _showOnlyAssigned,
        onSelected: (v) { setState(() { _showOnlyAssigned = v; if (v) _showOnlyAvailable = false; _applyFilters(); }); },
        selectedColor: AppTheme.accentCyan.withValues(alpha: 0.3),
        checkmarkColor: AppTheme.accentCyan,
      ),
      FilterChip(
        label: const Text('Available Only', style: TextStyle(color: Colors.white)),
        selected: _showOnlyAvailable,
        onSelected: (v) { setState(() { _showOnlyAvailable = v; if (v) _showOnlyAssigned = false; _applyFilters(); }); },
        selectedColor: AppTheme.accentCyan.withValues(alpha: 0.3),
        checkmarkColor: AppTheme.accentCyan,
      ),
    ];
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Asset Management', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textMain)),
        Row(
          children: [
            if (AuthService.isAdmin || AuthService.isOfficer)
              ElevatedButton.icon(
                onPressed: _openCreateAsset,
                icon: const Icon(Icons.add),
                label: const Text('ADD ASSET'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentCyan,
                  foregroundColor: AppTheme.primaryNavy,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            const SizedBox(width: AppTheme.spacingMd),
            ElevatedButton.icon(
              onPressed: _fetchAssets,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.secondaryNavy,
                foregroundColor: AppTheme.accentCyan,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchAndFilters() {
    return Card(
      color: AppTheme.secondaryNavy,
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search bar
            TextField(
              style: const TextStyle(color: Colors.white),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                  _applyFilters();
                });
              },
              decoration: InputDecoration(
                labelText: 'Search assets...',
                labelStyle: const TextStyle(color: AppTheme.textMuted),
                prefixIcon: const Icon(Icons.search, color: AppTheme.accentCyan),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: AppTheme.textMuted),
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                            _applyFilters();
                          });
                        },
                      )
                    : null,
              ),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            // Filter row
            Wrap(
              spacing: AppTheme.spacingMd,
              runSpacing: AppTheme.spacingSm,
              children: _buildFilterChips(),
            ),
            _hasActiveFilters()
                ? Padding(
                    padding: const EdgeInsets.only(top: AppTheme.spacingMd),
                    child: TextButton.icon(
                      onPressed: _clearFilters,
                      icon: const Icon(Icons.clear_all, color: AppTheme.textMuted),
                      label: const Text('Clear Filters', style: TextStyle(color: AppTheme.textMuted)),
                    ),
                  )
                : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.inventory_2_outlined, size: 64, color: AppTheme.textMuted),
          const SizedBox(height: AppTheme.spacingMd),
          Text(
            _hasActiveFilters() ? 'No assets match your filters' : 'No assets found',
            style: const TextStyle(color: AppTheme.textMuted, fontSize: 16),
          ),
          if (_hasActiveFilters()) ...[
            const SizedBox(height: AppTheme.spacingMd),
            OutlinedButton(
              onPressed: _clearFilters,
              child: const Text('CLEAR FILTERS'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAssetTable() {
    if (_filteredAssets.isEmpty) {
      return _buildEmptyState();
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: DataTable(
          columnSpacing: 24,
          headingRowColor: WidgetStateProperty.all(AppTheme.primaryNavy),
          columns: const [
            DataColumn(label: Text('Asset Tag', style: TextStyle(color: AppTheme.textMuted, fontSize: 11))),
            DataColumn(label: Text('Name', style: TextStyle(color: AppTheme.textMuted, fontSize: 11))),
            DataColumn(label: Text('Category', style: TextStyle(color: AppTheme.textMuted, fontSize: 11))),
            DataColumn(label: Text('Location', style: TextStyle(color: AppTheme.textMuted, fontSize: 11))),
            DataColumn(label: Text('Condition', style: TextStyle(color: AppTheme.textMuted, fontSize: 11))),
            DataColumn(label: Text('Criticality', style: TextStyle(color: AppTheme.textMuted, fontSize: 11))),
            DataColumn(label: Text('Status', style: TextStyle(color: AppTheme.textMuted, fontSize: 11))),
            DataColumn(label: Text('Assigned To', style: TextStyle(color: AppTheme.textMuted, fontSize: 11))),
            DataColumn(label: Text('Actions', style: TextStyle(color: AppTheme.textMuted, fontSize: 11))),
          ],
          rows: _filteredAssets.map((a) {
            final condition = a['condition'] ?? 'UNKNOWN';
            final criticality = a['criticality'] ?? 'UNKNOWN';
            final status = a['status'] ?? 'UNKNOWN';
            final isAssigned = a['status'] == 'ASSIGNED' || a['status'] == 'IN_USE';
            return DataRow(
              onSelectChanged: (_) => _openAssetDetails(a),
              cells: [
                DataCell(Text(a['assetTag'] ?? '—', style: const TextStyle(color: AppTheme.accentCyan, fontWeight: FontWeight.bold, fontSize: 13))),
                DataCell(Text(a['name'] ?? '—', style: const TextStyle(color: AppTheme.textMain, fontSize: 13))),
                DataCell(Text(a['category'] ?? '—', style: const TextStyle(color: Colors.white70, fontSize: 13))),
                DataCell(Text(a['location'] ?? '—', style: const TextStyle(color: AppTheme.textMain, fontSize: 13))),
                DataCell(StatusBadge(label: condition, color: _getConditionColor(condition))),
                DataCell(StatusBadge(label: criticality, color: _getCriticalityColor(criticality))),
                DataCell(StatusBadge(label: status, color: _getStatusColor(status))),
                DataCell(Text(
                  isAssigned ? (a['personnelName'] ?? 'Assigned') : 'Unassigned',
                  style: TextStyle(
                    color: isAssigned ? AppTheme.statusHealthy : AppTheme.textMuted,
                    fontSize: 13,
                  ),
                )),
                DataCell(Row(
                  mainAxisSize: MainAxisSize.min,
                  children: _buildActionButtons(a),
                )),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  List<Widget> _buildActionButtons(Map<String, dynamic> asset) {
    return [
      IconButton(
        icon: const Icon(Icons.visibility, color: AppTheme.accentCyan, size: 18),
        onPressed: () => _openAssetDetails(asset),
        tooltip: 'View Details',
      ),
      if (AuthService.isAdmin || AuthService.isOfficer)
        IconButton(
          icon: const Icon(Icons.edit, color: AppTheme.statusNeutral, size: 18),
          onPressed: () => _openEditAsset(asset),
          tooltip: 'Edit',
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.accentCyan));
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: AppTheme.statusCritical, size: 48),
            const SizedBox(height: AppTheme.spacingMd),
            Text(_errorMessage, style: const TextStyle(color: AppTheme.textMain)),
            const SizedBox(height: AppTheme.spacingMd),
            ElevatedButton(
              onPressed: _fetchAssets,
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentCyan, foregroundColor: AppTheme.primaryNavy),
              child: const Text('RETRY'),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: AppTheme.spacingLg),
          _buildSearchAndFilters(),
          const SizedBox(height: AppTheme.spacingLg),
          Expanded(
            child: Card(
              color: AppTheme.secondaryNavy,
              child: _buildAssetTable(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownFilter(String label, String value, List<String> options, Function(String) onChanged) {
    return SizedBox(
      width: 180,
      child: DropdownButtonFormField<String>(
        initialValue: value,
        items: options.map((o) => DropdownMenuItem(value: o, child: Text(o, style: const TextStyle(fontSize: 12)))).toList(),
        onChanged: (v) => onChanged(v!),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
          isDense: true,
        ),
        style: const TextStyle(color: Colors.white, fontSize: 12),
        dropdownColor: AppTheme.secondaryNavy,
        isExpanded: true,
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