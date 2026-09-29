import 'api_client.dart';

class MissionService {
  static Future<ApiResponse<List<dynamic>>> getMissions() async {
    return ApiClient.get('/missions', parser: (data) => data as List<dynamic>);
  }

  static Future<ApiResponse<Map<String, dynamic>>> getMissionDashboard(String code) async {
    return ApiClient.get('/missions/$code/dashboard', parser: (data) => data as Map<String, dynamic>);
  }

  static Future<ApiResponse<Map<String, dynamic>>> getMission(String code) async {
    return ApiClient.get('/missions/$code', parser: (data) => data as Map<String, dynamic>);
  }

  static Future<ApiResponse<List<dynamic>>> getTeams(String code) async {
    return ApiClient.get('/missions/$code/teams', parser: (data) => data as List<dynamic>);
  }

  static Future<ApiResponse<List<dynamic>>> getMembers(String code) async {
    return ApiClient.get('/missions/$code/personnel', parser: (data) => data as List<dynamic>);
  }

  static Future<ApiResponse<List<dynamic>>> getTargets(String code) async {
    return ApiClient.get('/missions/$code/targets', parser: (data) => data as List<dynamic>);
  }

  static Future<ApiResponse<List<dynamic>>> getAssignments(String code) async {
    return ApiClient.get('/missions/$code/assignments', parser: (data) => data as List<dynamic>);
  }

  static Future<ApiResponse<List<dynamic>>> getLocations(String code) async {
    return ApiClient.get('/missions/$code/locations', parser: (data) => data as List<dynamic>);
  }

  static Future<ApiResponse<dynamic>> submitLocation(String code, int personnelId, double lat, double lng, String status) async {
    final body = {
      'latitude': lat,
      'longitude': lng,
      'movementStatus': status,
      'source': 'DEVICE',
      'recordedAt': DateTime.now().toIso8601String(),
    };
    return ApiClient.post('/missions/$code/personnel/$personnelId/location', body);
  }

  static Future<ApiResponse<dynamic>> updateTargetProgress(String code, int targetId, double completedValue) async {
    final body = {
      'completedValue': completedValue,
    };
    return ApiClient.put('/missions/$code/targets/$targetId', body);
  }

  static Future<ApiResponse<dynamic>> updateAssignmentStatus(String code, int assignmentId, double completedValue, String status) async {
    final body = {
      'completedValue': completedValue,
      'status': status,
    };
    return ApiClient.put('/missions/$code/assignments/$assignmentId', body);
  }
}
