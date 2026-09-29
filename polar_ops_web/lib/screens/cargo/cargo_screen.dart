import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../theme/app_theme.dart';
import '../../widgets/components/status_badge.dart';
import '../../widgets/components/section_header.dart';
import '../../services/api/api_client.dart';
import '../../services/auth/auth_service.dart';

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
    final response = await ApiClient.get('/cargo');
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
      withData: true, // important for web
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
          Uri.parse('http://localhost:8080/api/v1/cargo/intelligence/inspect'),
        );

        if (AuthService.currentToken != null) {
          request.headers['Authorization'] =
              'Bearer ${AuthService.currentToken}';
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
          // Refresh cargo list to see updated risks
          _fetchCargo();
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text(
                  'Image inspection could not be completed. Please try again.')));
        }
      } catch (_) {
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text(
                  'Image upload failed. Check your connection and try again.')));
      } finally {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryNavy,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(title: 'CARGO LOGISTICS & INTELLIGENCE'),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: _buildCargoList(),
                ),
                const SizedBox(width: 24),
                Expanded(
                  flex: 1,
                  child: _buildIntelligencePanel(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCargoList() {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Cargo Registry',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: Icon(Icons.refresh, color: AppTheme.accentCyan),
                onPressed: _fetchCargo,
              )
            ],
          ),
          const SizedBox(height: 16),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _cargoList.length,
              separatorBuilder: (context, index) =>
                  const Divider(color: Colors.white10),
              itemBuilder: (context, index) {
                final cargo = _cargoList[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'ID: ${cargo['cargoId'] ?? 'N/A'} - ${cargo['category'] ?? 'UNKNOWN'}',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Dest: ${cargo['destination'] ?? 'N/A'} | Weight: ${cargo['weight'] ?? 0} kg | Risk: ${cargo['riskScore'] ?? 0}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      StatusBadge(
                        label: cargo['currentStatus'] ?? 'UNKNOWN',
                        color: AppTheme.accentCyan,
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.analytics,
                            color: AppTheme.statusWarning),
                        tooltip: 'View Risk Analysis',
                        onPressed: () => _showRiskProfile(cargo['id']),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Future<void> _showRiskProfile(int cargoId) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final response = await ApiClient.get(
          '/cargo/$cargoId/risk-profile?destinationStation=Maitri');
      Navigator.pop(context); // close loader

      if (response.success && response.data != null) {
        _buildRiskDialog(response.data as Map<String, dynamic>);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to load risk profile')));
      }
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _buildRiskDialog(Map<String, dynamic> riskData) {
    final factors =
        riskData['factorContribution'] as Map<String, dynamic>? ?? {};
    final weather = riskData['activeWeather'] as Map<String, dynamic>?;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.primaryNavy,
        title: Row(
          children: [
            const Icon(Icons.warning, color: AppTheme.statusWarning),
            const SizedBox(width: 8),
            Text('AI Risk Engine Analysis',
                style: const TextStyle(color: AppTheme.textMain)),
          ],
        ),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Model Version: ${riskData['modelVersion']}',
                    style: const TextStyle(
                        color: AppTheme.textMuted, fontSize: 12)),
                Text('Timestamp: ${riskData['timestamp']}',
                    style: const TextStyle(
                        color: AppTheme.textMuted, fontSize: 12)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total Risk Score:',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 16)),
                    Text('${riskData['score']}/100',
                        style: TextStyle(
                            color: AppTheme.statusCritical,
                            fontSize: 24,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
                Text('Risk Level: ${riskData['riskLevel']}',
                    style: const TextStyle(
                        color: AppTheme.statusWarning,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                const Text('Risk Factor Breakdown:',
                    style: TextStyle(
                        color: AppTheme.accentCyan,
                        fontWeight: FontWeight.bold)),
                const Divider(color: AppTheme.textMuted),
                ...factors.entries.map((e) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(e.key,
                              style: const TextStyle(color: Colors.white70)),
                          Text('+${e.value}',
                              style: const TextStyle(
                                  color: AppTheme.statusCritical,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    )),
                if (weather != null) ...[
                  const SizedBox(height: 16),
                  const Text('Live Environmental Intelligence:',
                      style: TextStyle(
                          color: AppTheme.accentCyan,
                          fontWeight: FontWeight.bold)),
                  const Divider(color: AppTheme.textMuted),
                  Text('Source: ${weather['source']}',
                      style: const TextStyle(
                          color: AppTheme.textMuted, fontSize: 12)),
                  Text('Station: ${weather['station']}',
                      style: const TextStyle(color: Colors.white70)),
                  Text(
                      'Temperature: ${weather['temperature']} ${weather['temperatureUnit']}',
                      style: const TextStyle(color: Colors.white70)),
                  Text(
                      'Wind: ${weather['windSpeed']} ${weather['windSpeedUnit']}',
                      style: const TextStyle(color: Colors.white70)),
                ]
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CLOSE'),
          ),
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
          Text(
            'Barcode & Image Inspection',
            style: TextStyle(
              color: AppTheme.accentCyan,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
              'DATABASE AUDIT • ZXING BARCODE PARSING • DAMAGE DETECTION STATUS IN RESULT',
              style: TextStyle(
                  color: AppTheme.textMuted, fontSize: 11, letterSpacing: .4)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed:
                (_isUploading || !AuthService.hasRole(['LOGISTICS_OFFICER']))
                    ? null
                    : _pickAndUploadImage,
            icon: const Icon(Icons.camera_alt),
            label: Text(
                _isUploading ? 'Inspecting...' : 'Upload Image for Inspection'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AuthService.hasRole(['LOGISTICS_OFFICER'])
                  ? AppTheme.statusNeutral
                  : Colors.grey,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          if (!AuthService.hasRole(['LOGISTICS_OFFICER']))
            const Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: Text('LOGISTICS_OFFICER role required',
                  style:
                      TextStyle(color: AppTheme.statusCritical, fontSize: 12)),
            ),
          const SizedBox(height: 24),
          if (_inspectionResult != null) ...[
            Text(
              'INSPECTION RESULT',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildResultRow(
                'Cargo Linked',
                _inspectionResult!['cargoPackage']?['cargoId'] ??
                    'Unknown Cargo'),
            _buildResultRow('Inspector', _inspectionResult!['inspectorName']),
            _buildResultRow('Passed', _inspectionResult!['passed'].toString()),
            _buildResultRow('Damage Detected',
                _inspectionResult!['damageDetected'].toString()),
            _buildResultRow('Model',
                '${_inspectionResult!['modelName']} (${_inspectionResult!['modelVersion']})'),
            _buildResultRow(
                'Confidence', '${_inspectionResult!['confidence']}'),
            const SizedBox(height: 8),
            Text(
              'Notes: ${_inspectionResult!['notes']}',
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ] else if (_selectedFile != null && !_isUploading) ...[
            Text('Inspection failed.',
                style: TextStyle(color: AppTheme.statusCritical)),
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
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(color: Colors.white54, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
