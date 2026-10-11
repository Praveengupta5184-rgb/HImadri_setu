import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../services/api_service.dart';

class SosScreen extends StatefulWidget {
  @override
  _SosScreenState createState() => _SosScreenState();
}

class _SosScreenState extends State<SosScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Emergency Response'), backgroundColor: Colors.red),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                if (!_isLoading) _showConfirmDialog(context);
              },
              child: Container(
                width: 200, height: 200,
                decoration: BoxDecoration(
                  color: _isLoading ? Colors.grey : Colors.red,
                  shape: BoxShape.circle,
                  boxShadow: _isLoading ? [] : [BoxShadow(color: Colors.redAccent, blurRadius: 30, spreadRadius: 10)]
                ),
                child: Center(
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('SOS', style: TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
            const SizedBox(height: 48),
            ElevatedButton.icon(
              icon: const Icon(Icons.mic),
              label: const Text('Voice SOS - Prototype'),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Listening... (Voice SOS is a prototype)')));
              },
            )
          ],
        ),
      ),
    );
  }
  
  void _showConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Emergency'),
        content: const Text('Are you sure you want to trigger a station-wide SOS?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(ctx);
              _triggerSos();
            },
            child: const Text('CONFIRM SOS'),
          )
        ],
      )
    );
  }

  Future<void> _triggerSos() async {
    setState(() => _isLoading = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied, we cannot request permissions.');
      }

      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

      final response = await _apiService.createEmergency({
        "type": "GENERAL_EMERGENCY",
        "description": "SOS triggered from Android App",
        "severity": "CRITICAL",
        "reportedBy": "FIELD_OPERATOR_1", // TODO: Get from auth
        "missionId": 1, // TODO: Get from context
        "latitude": position.latitude,
        "longitude": position.longitude
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Emergency ${response['id']} created. Response team dispatched.')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to trigger SOS: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
