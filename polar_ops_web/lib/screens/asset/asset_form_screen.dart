import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/api/api_client.dart';
import '../../services/auth/auth_service.dart';

class AssetFormScreen extends StatefulWidget {
  final Map<String, dynamic>? asset; // null for create, asset data for edit
  final List<dynamic> missions;
  final List<dynamic> stations;
  final List<dynamic> personnel;

  const AssetFormScreen({
    super.key,
    this.asset,
    this.missions = const [],
    this.stations = const [],
    this.personnel = const [],
  });

  @override
  State<AssetFormScreen> createState() => _AssetFormScreenState();
}

class _AssetFormScreenState extends State<AssetFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String _errorMessage = '';
  String _successMessage = '';

  // Form controllers
  final _assetTagController = TextEditingController();
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _serialNumberController = TextEditingController();
  final _manufacturerController = TextEditingController();
  final _modelController = TextEditingController();
  final _quantityController = TextEditingController();
  final _locationController = TextEditingController();
  final _purchaseCostController = TextEditingController();
  final _notesController = TextEditingController();

  // Dropdown values
  String _selectedStatus = 'AVAILABLE';
  String _selectedCondition = 'GOOD';
  String _selectedCriticality = 'MEDIUM';
  String? _selectedMissionId;
  String? _selectedStationId;
  String? _selectedPersonnelId;
  DateTime? _purchaseDate;
  DateTime? _lastMaintenanceDate;
  DateTime? _nextMaintenanceDate;

  final List<String> _statuses = ['AVAILABLE', 'ASSIGNED', 'IN_USE', 'MAINTENANCE', 'DAMAGED', 'LOST', 'RETIRED'];
  final List<String> _conditions = ['EXCELLENT', 'GOOD', 'FAIR', 'POOR'];
  final List<String> _criticalities = ['LOW', 'MEDIUM', 'HIGH', 'CRITICAL'];

  bool get isEditing => widget.asset != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _populateFields();
    }
  }

  void _populateFields() {
    final a = widget.asset!;
    _assetTagController.text = a['assetTag'] ?? '';
    _nameController.text = a['name'] ?? '';
    _categoryController.text = a['category'] ?? '';
    _descriptionController.text = a['description'] ?? '';
    _serialNumberController.text = a['serialNumber'] ?? '';
    _manufacturerController.text = a['manufacturer'] ?? '';
    _modelController.text = a['model'] ?? '';
    _quantityController.text = (a['quantity'] ?? 1).toString();
    _locationController.text = a['location'] ?? '';
    _selectedStatus = a['status'] ?? 'AVAILABLE';
    _selectedCondition = a['condition'] ?? 'GOOD';
    _selectedCriticality = a['criticality'] ?? 'MEDIUM';
    _selectedMissionId = a['missionId']?.toString();
    _selectedStationId = a['stationId']?.toString();
    _selectedPersonnelId = a['personnelId']?.toString();
    _purchaseCostController.text = (a['purchaseCost'] ?? '').toString();
    _notesController.text = a['description'] ?? '';

    if (a['purchaseDate'] != null) {
      _purchaseDate = DateTime.tryParse(a['purchaseDate']);
    }
    if (a['lastMaintenanceDate'] != null) {
      _lastMaintenanceDate = DateTime.tryParse(a['lastMaintenanceDate']);
    }
    if (a['nextMaintenanceDate'] != null) {
      _nextMaintenanceDate = DateTime.tryParse(a['nextMaintenanceDate']);
    }
  }

  Future<void> _pickDate(BuildContext context, DateTime? initialDate, Function(DateTime) onPicked) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.dark(
            primary: AppTheme.accentCyan,
            onPrimary: AppTheme.primaryNavy,
            surface: AppTheme.secondaryNavy,
            onSurface: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) onPicked(picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _successMessage = '';
    });

    try {
      final body = {
        'assetTag': _assetTagController.text.trim(),
        'name': _nameController.text.trim(),
        'category': _categoryController.text.trim(),
        'description': _descriptionController.text.trim(),
        'serialNumber': _serialNumberController.text.trim(),
        'manufacturer': _manufacturerController.text.trim(),
        'model': _modelController.text.trim(),
        'quantity': int.tryParse(_quantityController.text.trim()) ?? 1,
        'status': _selectedStatus,
        'condition': _selectedCondition,
        'criticality': _selectedCriticality,
        'location': _locationController.text.trim(),
        'purchaseDate': _purchaseDate?.toIso8601String().split('T')[0],
        'purchaseCost': double.tryParse(_purchaseCostController.text.trim()),
        'lastMaintenanceDate': _lastMaintenanceDate?.toIso8601String().split('T')[0],
        'nextMaintenanceDate': _nextMaintenanceDate?.toIso8601String().split('T')[0],
        'missionId': _selectedMissionId != null ? int.tryParse(_selectedMissionId!) : null,
        'stationId': _selectedStationId != null ? int.tryParse(_selectedStationId!) : null,
        'personnelId': _selectedPersonnelId != null ? int.tryParse(_selectedPersonnelId!) : null,
      };

      final response = isEditing
          ? await ApiClient.put('/assets/${widget.asset!['id']}', body)
          : await ApiClient.post('/assets', body);

      if (!mounted) return;

      if (response.success) {
        setState(() {
          _successMessage = isEditing ? 'Asset updated successfully' : 'Asset created successfully';
          _isLoading = false;
        });
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) Navigator.pop(context, true);
        });
      } else {
        setState(() {
          _errorMessage = response.error ?? 'Operation failed';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _assetTagController.dispose();
    _nameController.dispose();
    _categoryController.dispose();
    _descriptionController.dispose();
    _serialNumberController.dispose();
    _manufacturerController.dispose();
    _modelController.dispose();
    _quantityController.dispose();
    _locationController.dispose();
    _purchaseCostController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryNavy,
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Asset' : 'Create Asset'),
        backgroundColor: AppTheme.secondaryNavy,
        foregroundColor: AppTheme.accentCyan,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingLg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(
                    isEditing ? Icons.edit : Icons.add,
                    size: 32,
                    color: AppTheme.accentCyan,
                  ),
                  const SizedBox(width: AppTheme.spacingMd),
                  Text(
                    isEditing ? 'Edit Asset' : 'Create New Asset',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textMain,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacingLg),

              // Error/Success messages
              if (_errorMessage.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(AppTheme.spacingMd),
                  margin: const EdgeInsets.only(bottom: AppTheme.spacingMd),
                  decoration: BoxDecoration(
                    color: AppTheme.statusCritical.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.statusCritical.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: AppTheme.statusCritical, size: 20),
                      const SizedBox(width: AppTheme.spacingSm),
                      Expanded(
                        child: Text(_errorMessage, style: const TextStyle(color: AppTheme.statusCritical)),
                      ),
                    ],
                  ),
                ),
              if (_successMessage.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(AppTheme.spacingMd),
                  margin: const EdgeInsets.only(bottom: AppTheme.spacingMd),
                  decoration: BoxDecoration(
                    color: AppTheme.statusHealthy.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.statusHealthy.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_outline, color: AppTheme.statusHealthy, size: 20),
                      const SizedBox(width: AppTheme.spacingSm),
                      Expanded(
                        child: Text(_successMessage, style: const TextStyle(color: AppTheme.statusHealthy)),
                      ),
                    ],
                  ),
                ),

              // Asset Identification Section
              _buildSectionHeader('Asset Identification', Icons.tag),
              const SizedBox(height: AppTheme.spacingMd),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _assetTagController,
                      enabled: !isEditing, // Asset tag cannot be changed after creation
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: isEditing ? 'Asset Code (read-only)' : 'Asset Code *',
                        labelStyle: const TextStyle(color: AppTheme.textMuted),
                        prefixIcon: const Icon(Icons.qr_code, color: AppTheme.accentCyan),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Asset code is required';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingMd),
                  Expanded(
                    child: TextFormField(
                      controller: _nameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Asset Name *',
                        labelStyle: const TextStyle(color: AppTheme.textMuted),
                        prefixIcon: const Icon(Icons.label, color: AppTheme.accentCyan),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Asset name is required';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacingMd),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _categoryController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Category *',
                        labelStyle: const TextStyle(color: AppTheme.textMuted),
                        prefixIcon: const Icon(Icons.category, color: AppTheme.accentCyan),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Category is required';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingMd),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedStatus,
                      items: _statuses.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                      onChanged: (v) => setState(() => _selectedStatus = v!),
                      decoration: InputDecoration(
                        labelText: 'Status *',
                        labelStyle: const TextStyle(color: AppTheme.textMuted),
                        prefixIcon: const Icon(Icons.flag, color: AppTheme.accentCyan),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppTheme.spacingLg),
              _buildSectionHeader('Specifications', Icons.settings),
              const SizedBox(height: AppTheme.spacingMd),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Description',
                  labelStyle: const TextStyle(color: AppTheme.textMuted),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: AppTheme.spacingMd),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _serialNumberController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Serial Number',
                        labelStyle: const TextStyle(color: AppTheme.textMuted),
                        prefixIcon: const Icon(Icons.numbers, color: AppTheme.accentCyan),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingMd),
                  Expanded(
                    child: TextFormField(
                      controller: _manufacturerController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Manufacturer',
                        labelStyle: const TextStyle(color: AppTheme.textMuted),
                        prefixIcon: const Icon(Icons.factory, color: AppTheme.accentCyan),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacingMd),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _modelController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Model',
                        labelStyle: const TextStyle(color: AppTheme.textMuted),
                        prefixIcon: const Icon(Icons.model_training, color: AppTheme.accentCyan),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingMd),
                  Expanded(
                    child: TextFormField(
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Quantity',
                        labelStyle: const TextStyle(color: AppTheme.textMuted),
                        prefixIcon: const Icon(Icons.production_quantity_limits, color: AppTheme.accentCyan),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppTheme.spacingLg),
              _buildSectionHeader('Status & Condition', Icons.monitor_heart),
              const SizedBox(height: AppTheme.spacingMd),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedCondition,
                      items: _conditions.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                      onChanged: (v) => setState(() => _selectedCondition = v!),
                      decoration: InputDecoration(
                        labelText: 'Condition *',
                        labelStyle: const TextStyle(color: AppTheme.textMuted),
                        prefixIcon: const Icon(Icons.star, color: AppTheme.accentCyan),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingMd),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedCriticality,
                      items: _criticalities.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                      onChanged: (v) => setState(() => _selectedCriticality = v!),
                      decoration: InputDecoration(
                        labelText: 'Criticality *',
                        labelStyle: const TextStyle(color: AppTheme.textMuted),
                        prefixIcon: const Icon(Icons.priority_high, color: AppTheme.accentCyan),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppTheme.spacingLg),
              _buildSectionHeader('Location & Assignment', Icons.location_on),
              const SizedBox(height: AppTheme.spacingMd),
              TextFormField(
                controller: _locationController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Location',
                  labelStyle: const TextStyle(color: AppTheme.textMuted),
                  prefixIcon: const Icon(Icons.place, color: AppTheme.accentCyan),
                ),
              ),
              const SizedBox(height: AppTheme.spacingMd),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedMissionId,
                      items: [
                        const DropdownMenuItem(value: null, child: Text('None')),
                        ...widget.missions.map((m) => DropdownMenuItem(
                          value: m['id'].toString(),
                          child: Text(m['missionCode'] ?? m['name'] ?? 'Mission ${m['id']}'),
                        )),
                      ],
                      onChanged: (v) => setState(() => _selectedMissionId = v),
                      decoration: InputDecoration(
                        labelText: 'Mission',
                        labelStyle: const TextStyle(color: AppTheme.textMuted),
                        prefixIcon: const Icon(Icons.rocket_launch, color: AppTheme.accentCyan),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingMd),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedStationId,
                      items: [
                        const DropdownMenuItem(value: null, child: Text('None')),
                        ...widget.stations.map((s) => DropdownMenuItem(
                          value: s['id'].toString(),
                          child: Text(s['name'] ?? 'Station ${s['id']}'),
                        )),
                      ],
                      onChanged: (v) => setState(() => _selectedStationId = v),
                      decoration: InputDecoration(
                        labelText: 'Station',
                        labelStyle: const TextStyle(color: AppTheme.textMuted),
                        prefixIcon: const Icon(Icons.account_balance, color: AppTheme.accentCyan),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacingMd),
              DropdownButtonFormField<String>(
                value: _selectedPersonnelId,
                items: [
                  const DropdownMenuItem(value: null, child: Text('Unassigned')),
                  ...widget.personnel.map((p) => DropdownMenuItem(
                    value: p['id'].toString(),
                    child: Text('${p['name']} (${p['role']})'),
                  )),
                ],
                onChanged: (v) => setState(() => _selectedPersonnelId = v),
                decoration: InputDecoration(
                  labelText: 'Assigned Personnel',
                  labelStyle: const TextStyle(color: AppTheme.textMuted),
                  prefixIcon: const Icon(Icons.person, color: AppTheme.accentCyan),
                ),
              ),

              const SizedBox(height: AppTheme.spacingLg),
              _buildSectionHeader('Dates & Costs', Icons.calendar_today),
              const SizedBox(height: AppTheme.spacingMd),
              Row(
                children: [
                  Expanded(
                    child: _buildDateField(
                      label: 'Purchase Date',
                      value: _purchaseDate,
                      onTap: () => _pickDate(context, _purchaseDate, (d) => setState(() => _purchaseDate = d)),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingMd),
                  Expanded(
                    child: TextFormField(
                      controller: _purchaseCostController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Purchase Cost',
                        labelStyle: const TextStyle(color: AppTheme.textMuted),
                        prefixIcon: const Icon(Icons.attach_money, color: AppTheme.accentCyan),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacingMd),
              Row(
                children: [
                  Expanded(
                    child: _buildDateField(
                      label: 'Last Maintenance',
                      value: _lastMaintenanceDate,
                      onTap: () => _pickDate(context, _lastMaintenanceDate, (d) => setState(() => _lastMaintenanceDate = d)),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingMd),
                  Expanded(
                    child: _buildDateField(
                      label: 'Next Maintenance',
                      value: _nextMaintenanceDate,
                      onTap: () => _pickDate(context, _nextMaintenanceDate, (d) => setState(() => _nextMaintenanceDate = d)),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppTheme.spacingLg),
              _buildSectionHeader('Notes', Icons.notes),
              const SizedBox(height: AppTheme.spacingMd),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Additional Notes',
                  labelStyle: const TextStyle(color: AppTheme.textMuted),
                  alignLabelWithHint: true,
                ),
              ),

              const SizedBox(height: AppTheme.spacingXl),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isLoading ? null : () => Navigator.pop(context),
                      icon: const Icon(Icons.cancel),
                      label: const Text('CANCEL'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: AppTheme.textMuted.withValues(alpha: 0.5)),
                        foregroundColor: AppTheme.textMuted,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingMd),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _submit,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryNavy),
                            )
                          : const Icon(Icons.save),
                      label: Text(isEditing ? 'UPDATE' : 'CREATE'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: AppTheme.accentCyan,
                        foregroundColor: AppTheme.primaryNavy,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacingXl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.accentCyan, size: 24),
        const SizedBox(width: AppTheme.spacingSm),
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textMain)),
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppTheme.textMuted),
          prefixIcon: const Icon(Icons.calendar_today, color: AppTheme.accentCyan),
          suffixIcon: value != null ? const Icon(Icons.check, color: AppTheme.statusHealthy, size: 18) : null,
        ),
        child: Text(
          value != null ? '${value.day}/${value.month}/${value.year}' : 'Select date',
          style: TextStyle(
            color: value != null ? Colors.white : AppTheme.textMuted,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}