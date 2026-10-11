import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../theme/app_theme.dart';
import '../../../services/cargo_service.dart';
import '../../../services/auth/auth_service.dart';
import '../../../widgets/components/status_badge.dart';

class CargoDetailsDialog extends StatefulWidget {
  final Map<String, dynamic> cargo;
  final VoidCallback onUpdated;

  const CargoDetailsDialog({Key? key, required this.cargo, required this.onUpdated}) : super(key: key);

  @override
  State<CargoDetailsDialog> createState() => _CargoDetailsDialogState();
}

class _CargoDetailsDialogState extends State<CargoDetailsDialog> {
  List<dynamic> _trackingEvents = [];
  bool _isLoadingTracking = true;

  final _statusRemarksController = TextEditingController();
  final _statusLocationController = TextEditingController();
  String _selectedStatus = 'PACKED';

  final List<String> _validStatuses = [
    'CREATED', 'PACKED', 'READY_FOR_DISPATCH', 'DISPATCHED', 
    'IN_TRANSIT', 'ARRIVED_AT_HUB', 'OUT_FOR_DELIVERY', 'DELIVERED',
    'DELAYED', 'DAMAGED', 'LOST', 'CANCELLED'
  ];

  @override
  void initState() {
    super.initState();
    _fetchTrackingHistory();
    _selectedStatus = widget.cargo['currentStatus'] ?? 'PACKED';
    if (!_validStatuses.contains(_selectedStatus)) {
      _selectedStatus = 'PACKED';
    }
  }
  
  @override
  void dispose() {
    _statusRemarksController.dispose();
    _statusLocationController.dispose();
    super.dispose();
  }

  Future<void> _fetchTrackingHistory() async {
    setState(() => _isLoadingTracking = true);
    final response = await CargoService.getTrackingHistory(widget.cargo['id']);
    if (mounted) {
      setState(() {
        _trackingEvents = response.success && response.data != null ? response.data as List<dynamic> : [];
        _isLoadingTracking = false;
      });
    }
  }

  Future<void> _printQrCode() async {
    final doc = pw.Document();
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text('POLAR-OPS', style: pw.TextStyle(fontSize: 32, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 32),
                pw.Text('Cargo ID: ${widget.cargo['cargoId'] ?? widget.cargo['id']}', style: const pw.TextStyle(fontSize: 24)),
                pw.Text('Cargo Name: ${widget.cargo['name'] ?? 'N/A'}', style: const pw.TextStyle(fontSize: 18)),
                pw.Text('Destination: ${widget.cargo['destination'] ?? 'N/A'}', style: const pw.TextStyle(fontSize: 18)),
                pw.SizedBox(height: 64),
                pw.BarcodeWidget(
                  data: widget.cargo['qrCode'] ?? widget.cargo['cargoId'] ?? widget.cargo['id'].toString(),
                  barcode: pw.Barcode.qrCode(),
                  width: 300,
                  height: 300,
                ),
                pw.SizedBox(height: 64),
                pw.Text('Scan to identify and track cargo', style: const pw.TextStyle(fontSize: 16)),
              ]
            )
          );
        },
      ),
    );
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => doc.save());
  }

  Future<void> _updateStatus() async {
    final response = await CargoService.updateStatus(
      widget.cargo['id'], 
      _selectedStatus, 
      AuthService.currentUserRole ?? 'UNKNOWN',
      location: _statusLocationController.text,
      remarks: _statusRemarksController.text
    );
    
    if (response.success) {
      widget.onUpdated();
      _fetchTrackingHistory();
      _statusRemarksController.clear();
      _statusLocationController.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Status updated successfully')));
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: ${response.error}')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.primaryNavy,
      title: Text('Cargo Details: ${widget.cargo['cargoId']}', style: const TextStyle(color: Colors.white)),
      content: SizedBox(
        width: 600,
        height: 500,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left column: Info & Actions
            Expanded(
              flex: 1,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('DETAILS', style: TextStyle(color: AppTheme.accentCyan, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                        child: QrImageView(
                          data: widget.cargo['cargoId'] ?? widget.cargo['id'].toString(),
                          version: QrVersions.auto,
                          size: 100.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text('QR Identifier: ${widget.cargo['qrCode'] ?? widget.cargo['cargoId'] ?? widget.cargo['id']}', style: const TextStyle(color: Colors.white54, fontSize: 10)),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        OutlinedButton.icon(
                          onPressed: _printQrCode,
                          icon: const Icon(Icons.download, size: 16),
                          label: const Text('Download QR'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.accentCyan,
                            side: const BorderSide(color: AppTheme.accentCyan),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: _printQrCode,
                          icon: const Icon(Icons.print, size: 16),
                          label: const Text('Print QR'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.accentCyan,
                            foregroundColor: AppTheme.primaryNavy,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow('Name', widget.cargo['name'] ?? 'N/A'),
                    _buildInfoRow('Origin', widget.cargo['origin'] ?? 'N/A'),
                    _buildInfoRow('Destination', widget.cargo['destination'] ?? 'N/A'),
                    _buildInfoRow('Weight', '${widget.cargo['weight'] ?? 0} kg'),
                    _buildInfoRow('Quantity', '${widget.cargo['quantity'] ?? 1}'),
                    _buildInfoRow('Priority', widget.cargo['priority'] ?? 'N/A'),
                    _buildInfoRow('Hazardous', widget.cargo['hazardousStatus'] == true ? 'YES' : 'NO', isAlert: widget.cargo['hazardousStatus'] == true),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text('Current Status: ', style: TextStyle(color: Colors.white54)),
                        StatusBadge(label: widget.cargo['currentStatus'] ?? 'UNKNOWN', color: AppTheme.accentCyan),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Divider(color: Colors.white10),
                    const SizedBox(height: 16),
                    const Text('UPDATE STATUS', style: TextStyle(color: AppTheme.accentCyan, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedStatus,
                      dropdownColor: AppTheme.secondaryNavy,
                      style: const TextStyle(color: Colors.white),
                      items: _validStatuses.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedStatus = val);
                      },
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: AppTheme.secondaryNavy,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _statusLocationController,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                      decoration: const InputDecoration(
                        hintText: 'Location (optional)',
                        hintStyle: TextStyle(color: Colors.white38),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _statusRemarksController,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                      decoration: const InputDecoration(
                        hintText: 'Remarks (optional)',
                        hintStyle: TextStyle(color: Colors.white38),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: AuthService.hasRole(['LOGISTICS_OFFICER', 'STATION_OFFICER']) ? _updateStatus : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentCyan,
                        foregroundColor: AppTheme.primaryNavy,
                      ),
                      child: const Text('UPDATE STATUS'),
                    )
                  ],
                ),
              ),
            ),
            const VerticalDivider(color: Colors.white10, width: 32),
            // Right column: Tracking history
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('TRACKING HISTORY', style: TextStyle(color: AppTheme.accentCyan, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Expanded(
                    child: _isLoadingTracking 
                        ? const Center(child: CircularProgressIndicator())
                        : _trackingEvents.isEmpty 
                            ? const Text('No tracking events found.', style: TextStyle(color: Colors.white54))
                            : ListView.builder(
                                itemCount: _trackingEvents.length,
                                itemBuilder: (context, index) {
                                  final ev = _trackingEvents[index];
                                  return _buildTrackingEvent(ev);
                                },
                              ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('CLOSE'))
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isAlert = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 80, child: Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12))),
          Expanded(child: Text(value, style: TextStyle(color: isAlert ? AppTheme.statusCritical : Colors.white, fontSize: 12, fontWeight: isAlert ? FontWeight.bold : FontWeight.normal))),
        ],
      ),
    );
  }
  
  Widget _buildTrackingEvent(Map<String, dynamic> event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.secondaryNavy,
        borderRadius: BorderRadius.circular(4),
        border: Border(left: BorderSide(color: AppTheme.accentCyan, width: 4))
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(event['newStatus'] ?? 'UNKNOWN', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              Text(event['timestamp'] != null ? event['timestamp'].toString().substring(0, 16).replaceAll('T', ' ') : '', style: const TextStyle(color: Colors.white54, fontSize: 10)),
            ],
          ),
          const SizedBox(height: 4),
          if (event['location'] != null && event['location'].toString().isNotEmpty)
            Text('Loc: ${event['location']}', style: const TextStyle(color: AppTheme.accentCyan, fontSize: 12)),
          if (event['remarks'] != null && event['remarks'].toString().isNotEmpty)
            Text('Notes: ${event['remarks']}', style: const TextStyle(color: Colors.white70, fontSize: 12, fontStyle: FontStyle.italic)),
          const SizedBox(height: 4),
          Text('By: ${event['performedBy'] ?? 'Unknown'}', style: const TextStyle(color: Colors.white38, fontSize: 10)),
        ],
      ),
    );
  }
}
