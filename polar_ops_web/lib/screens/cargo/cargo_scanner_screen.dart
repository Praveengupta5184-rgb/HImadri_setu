import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:geolocator/geolocator.dart';
import '../../services/cargo_service.dart';
import '../../theme/app_theme.dart';

class CargoScannerScreen extends StatefulWidget {
  const CargoScannerScreen({Key? key}) : super(key: key);

  @override
  State<CargoScannerScreen> createState() => _CargoScannerScreenState();
}

class _CargoScannerScreenState extends State<CargoScannerScreen> {
  final MobileScannerController _scannerController = MobileScannerController();
  bool _isProcessing = false;
  String _statusMessage = 'Point camera at Cargo QR Code';
  Color _statusColor = Colors.white;

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  Future<void> _handleScan(String? cargoIdString) async {
    if (cargoIdString == null || _isProcessing) return;

    setState(() {
      _isProcessing = true;
      _statusMessage = 'Processing Cargo ID: $cargoIdString...';
      _statusColor = AppTheme.statusWarning;
    });

    try {
      setState(() {
        _statusMessage = 'Looking up cargo...';
      });

      final allCargoRes = await CargoService.getAllCargo();
      if (!allCargoRes.success || allCargoRes.data == null) {
        throw Exception('Failed to look up cargo identity.');
      }

      int? internalId;
      final cargos = allCargoRes.data as List<dynamic>;
      for (var c in cargos) {
        if (c['cargoId'] == cargoIdString || c['qrCode'] == cargoIdString || c['id'].toString() == cargoIdString) {
          internalId = c['id'];
          break;
        }
      }

      if (internalId == null) {
        throw Exception('Cargo not found for QR: $cargoIdString');
      }

      setState(() {
        _statusMessage = 'Cargo identified. Requesting location...';
      });

      // Request location
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      double? lat;
      double? lng;

      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        setState(() {
          _statusMessage = 'Location permission is required to update cargo location automatically.';
          _statusColor = AppTheme.statusCritical;
        });
        // We can still scan but without location
      } else {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 10),
        );
        lat = position.latitude;
        lng = position.longitude;
      }

      setState(() {
        _statusMessage = 'Sending scan data to backend...';
      });

      final response = await CargoService.scanCargo(internalId, lat, lng, 'QR_SCAN', 'Cargo QR scanned');
      
      if (response.success) {
        setState(() {
          _statusMessage = 'Cargo scanned successfully.\n${lat != null ? "Current location captured." : "Location updated without GPS."}';
          _statusColor = AppTheme.statusHealthy;
        });
        
        // Wait 2 seconds then pop back to details
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          Navigator.of(context).pop(internalId);
        }
      } else {
        throw Exception(response.error ?? 'Unknown error');
      }

    } catch (e) {
      setState(() {
        _statusMessage = 'Error: $e';
        _statusColor = AppTheme.statusCritical;
      });
      // allow retry
      await Future.delayed(const Duration(seconds: 3));
      setState(() {
        _isProcessing = false;
        _statusMessage = 'Point camera at Cargo QR Code';
        _statusColor = Colors.white;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('QR Scanner'),
        backgroundColor: Colors.transparent,
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _scannerController,
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                _handleScan(barcode.rawValue);
                break;
              }
            },
          ),
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _statusColor),
              ),
              child: Text(
                _statusMessage,
                textAlign: TextAlign.center,
                style: TextStyle(color: _statusColor, fontSize: 16),
              ),
            ),
          )
        ],
      ),
    );
  }
}
