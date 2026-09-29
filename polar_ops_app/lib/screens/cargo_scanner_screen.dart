import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class CargoScannerScreen extends StatefulWidget {
  const CargoScannerScreen({super.key});

  @override
  State<CargoScannerScreen> createState() => _CargoScannerScreenState();
}

class _CargoScannerScreenState extends State<CargoScannerScreen> {
  String? scanResult;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cargo Scanner')),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: MobileScanner(
              onDetect: (capture) {
                final List<Barcode> barcodes = capture.barcodes;
                for (final barcode in barcodes) {
                  if (barcode.rawValue != null && scanResult != barcode.rawValue) {
                    setState(() {
                      scanResult = barcode.rawValue;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Scanned: ${barcode.rawValue}')),
                    );
                  }
                }
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(24),
              width: double.infinity,
              color: Colors.black87,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Scan Cargo Label (QR/Barcode)'),
                  const SizedBox(height: 16),
                  Text(
                    scanResult ?? 'Waiting for scan...',
                    style: TextStyle(
                      fontSize: 18, 
                      color: scanResult != null ? Colors.green : Colors.grey,
                      fontWeight: FontWeight.bold
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
