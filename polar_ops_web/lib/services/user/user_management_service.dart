import '../api/api_client.dart';

class UserManagementService {
  static const List<String> systemRoles = [
    'ADMIN',
    'MISSION_OFFICER',
    'LOGISTICS_OFFICER',
    'STATION_OFFICER',
    'FIELD_OPERATOR',
    'ASSET_OFFICER',
    'MEDICAL_OFFICER',
    'PERSONNEL',
  ];

  static Future<ApiResponse<List<dynamic>>> fetchPendingUsers() {
    return ApiClient.get<List>('/auth/users/pending');
  }

  static Future<ApiResponse<List<dynamic>>> fetchAllUsers() {
    return ApiClient.get<List>('/auth/users');
  }

  static Future<ApiResponse<Map>> approveUser(int userId) {
    return ApiClient.put<Map>('/auth/users/$userId/approve', {});
  }

  static Future<ApiResponse<Map>> rejectUser(int userId) {
    return ApiClient.put<Map>('/auth/users/$userId/reject', {});
  }

  static Future<ApiResponse<Map>> assignRole(int userId, String role) {
    return ApiClient.put<Map>('/auth/users/$userId/role', {'role': role});
  }
}
