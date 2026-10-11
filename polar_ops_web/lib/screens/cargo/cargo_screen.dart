import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../theme/app_theme.dart';
import '../../services/api/api_client.dart';
import '../../services/auth/auth_service.dart';
import '../../services/cargo_service.dart';

import 'cargo_list_view.dart';
import 'create_cargo_view.dart';
import 'cargo_details_dialog.dart';

class CargoScreen extends StatefulWidget {
  const CargoScreen({Key? key}) : super(key: key);

  @override
  State<CargoScreen> createState() => _CargoScreenState();
}

class _CargoScreenState extends State<CargoScreen> {
  List<dynamic> _cargoList = [];
  bool _isLoading = true;

  // Image inspection states
  PlatformFile? _selectedFile;
  bool _isUploading = false;
  Map<String, dynamic>? _inspectionResult;

  @override
  void initState() {
    super.initState();
    _fetchCargo();
  }

  Future<void> _fetchCargo() async {
    setState(() => _isLoading = true);
    final response = await CargoService.getAllCargo();
    if (!mounted) return;
    setState(() {
      _cargoList = response.success && response.data != null
          ? response.data as List<dynamic>
          : [];
      _isLoading = false;
    });
  }

  Future<void> _pickAndUploadImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true, 
    );

    if (result != null && result.files.single.bytes != null) {
      setState(() {
        _selectedFile = result.files.single;
        _isUploading = true;
        _inspectionResult = null;
      });

      try {
        var request = http.MultipartRequest(
          'POST',
          Uri.parse('${ApiClient.baseUrl}/cargo/intelligence/inspect'),
        );

        if (AuthService.currentToken != null) {
          request.headers['Authorization'] = 'Bearer ${AuthService.currentToken}';
        }

        request.files.add(
          http.MultipartFile.fromBytes(
            'file',
            _selectedFile!.bytes!,
            filename: _selectedFile!.name,
          ),
        );

        var streamedResponse = await request.send();
        var response = await http.Response.fromStream(streamedResponse);

        if (response.statusCode == 200) {
          setState(() {
            _inspectionResult = jsonDecode(response.body);
          });
          _fetchCargo();
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Image inspection failed.')));
        }
      } catch (_) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Upload failed.')));
      } finally {
        setState(() => _isUploading = false);
      }
    }
  }

  void _showRiskProfile(int cargoId) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final response = await CargoService.getRiskProfile(cargoId, destinationStation: 'Maitri');
      if (mounted) Navigator.pop(context); 

      if (response.success && response.data != null) {
        _buildRiskDialog(response.data as Map<String, dynamic>);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to load risk profile')));
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _showCargoDetails(int id) {
    final cargo = _cargoList.firstWhere((c) => c['id'] == id, orElse: () => null);
    if (cargo != null) {
      showDialog(
        context: context,
        builder: (context) => CargoDetailsDialog(
          cargo: cargo,
          onUpdated: _fetchCargo,
        ),
      );
    }
  }

  void _buildRiskDialog(Map<String, dynamic> riskData) {
    final factors = riskData['factorContribution'] as Map<String, dynamic>? ?? {};
    final weather = riskData['activeWeather'] as Map<String, dynamic>?;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.primaryNavy,
        title: Row(
          children: [
            const Icon(Icons.warning, color: AppTheme.statusWarning),
            const SizedBox(width: 8),
            const Text('AI Risk Engine Analysis', style: TextStyle(color: AppTheme.textMain)),
          ],
        ),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Model Version: ${riskData['modelVersion']}', style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                Text('Timestamp: ${riskData['timestamp']}', style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Risk Score:', style: TextStyle(color: Colors.white, fontSize: 16)),
                    Text('${riskData['score']}/100', style: const TextStyle(color: AppTheme.statusCritical, fontSize: 24, fontWeight: FontWeight.bold)),
                  ],
                ),
                Text('Risk Level: ${riskData['riskLevel']}', style: const TextStyle(color: AppTheme.statusWarning, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                const Text('Risk Factor Breakdown:', style: TextStyle(color: AppTheme.accentCyan, fontWeight: FontWeight.bold)),
                const Divider(color: AppTheme.textMuted),
                ...factors.entries.map((e) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(e.key, style: const TextStyle(color: Colors.white70)),
                          Text('+${e.value}', style: const TextStyle(color: AppTheme.statusCritical, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CLOSE')),
        ],
      ),
    );
  }

  Widget _buildIntelligencePanel() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.secondaryNavy,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.accentCyan.withValues(alpha: 0.2)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Barcode & Image Inspection', style: TextStyle(color: AppTheme.accentCyan, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: (_isUploading || !AuthService.hasRole(['LOGISTICS_OFFICER'])) ? null : _pickAndUploadImage,
            icon: const Icon(Icons.camera_alt),
            label: Text(_isUploading ? 'Inspecting...' : 'Upload Image for Inspection'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AuthService.hasRole(['LOGISTICS_OFFICER']) ? AppTheme.statusNeutral : Colors.grey,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          if (_inspectionResult != null) ...[
            const SizedBox(height: 24),
            const Text('INSPECTION RESULT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildResultRow('Passed', _inspectionResult!['passed'].toString()),
            _buildResultRow('Damage Detected', _inspectionResult!['damageDetected'].toString()),
            const SizedBox(height: 8),
            Text('Notes: ${_inspectionResult!['notes']}', style: const TextStyle(color: Colors.white70, fontSize: 13)),
          ]
        ],
      ),
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 130, child: Text(label, style: const TextStyle(color: Colors.white54, fontSize: 13))),
          Expanded(child: Text(value, style: const TextStyle(color: Colors.white, fontSize: 13))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppTheme.primaryNavy,
        appBar: AppBar(
          backgroundColor: AppTheme.secondaryNavy,
          automaticallyImplyLeading: false,
          toolbarHeight: 0,
          bottom: const TabBar(
            indicatorColor: AppTheme.accentCyan,
            labelColor: AppTheme.accentCyan,
            unselectedLabelColor: Colors.white54,
            tabs: [
              Tab(text: 'CARGO DASHBOARD & REGISTRY', icon: Icon(Icons.dashboard)),
              Tab(text: 'CREATE / PACK CARGO', icon: Icon(Icons.add_box)),
              Tab(text: 'AI INSPECTION & INTELLIGENCE', icon: Icon(Icons.psychology)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: List
            SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: CargoListView(
                cargoList: _cargoList,
                isLoading: _isLoading,
                onRefresh: _fetchCargo,
                onViewRisk: _showRiskProfile,
                onViewDetails: _showCargoDetails,
              ),
            ),
            // Tab 2: Create
            SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: CreateCargoView(
                onCargoCreated: () {
                  _fetchCargo();
                  DefaultTabController.of(context).animateTo(0);
                },
              ),
            ),
            // Tab 3: Intelligence
            SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: _buildIntelligencePanel(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
