import 'api/api_client.dart';

class CargoService {
  static Future<ApiResponse> getAllCargo() {
    return ApiClient.get('/cargo');
  }

  static Future<ApiResponse> getCargoById(int id) {
    return ApiClient.get('/cargo/$id');
  }

  static Future<ApiResponse> createCargo(Map<String, dynamic> cargoData) {
    return ApiClient.post('/cargo', cargoData);
  }

  static Future<ApiResponse> updateCargo(int id, Map<String, dynamic> cargoData) {
    return ApiClient.put('/cargo/$id', cargoData);
  }

  static Future<ApiResponse> updateStatus(int id, String status, String performedBy, {String? location, String? remarks}) {
    String url = '/cargo/$id/status?status=$status&performedBy=$performedBy';
    if (location != null) url += '&location=$location';
    if (remarks != null) url += '&remarks=$remarks';
    return ApiClient.post(url, {});
  }

  static Future<ApiResponse> getTrackingHistory(int id) {
    return ApiClient.get('/cargo/$id/tracking');
  }

  static Future<ApiResponse> reportException(int id, String type, String performedBy, String remarks, {String? location}) {
    String url = '/cargo/$id/exception?type=$type&performedBy=$performedBy&remarks=$remarks';
    if (location != null) url += '&location=$location';
    return ApiClient.post(url, {});
  }

  static Future<ApiResponse> getRiskProfile(int id, {bool damageDetected = false, String? destinationStation}) {
    String url = '/cargo/$id/risk-profile?damageDetected=$damageDetected';
    if (destinationStation != null) url += '&destinationStation=$destinationStation';
    return ApiClient.get(url);
  }

  static Future<ApiResponse> scanCargo(int id, double? lat, double? lng, String source, String remarks) {
    return ApiClient.post('/cargo/$id/scan', {
      'latitude': lat,
      'longitude': lng,
      'source': source,
      'remarks': remarks
    });
  }
}
