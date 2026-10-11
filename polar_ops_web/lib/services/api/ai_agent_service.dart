import 'api_client.dart';

class AiAgentService {
  static Future<ApiResponse> getOverview({int? missionId}) {
    String url = '/ai/overview';
    if (missionId != null) {
      url += '?missionId=$missionId';
    }
    return ApiClient.get(url);
  }

  static Future<ApiResponse> getRecommendations({int? missionId, String? status}) {
    String url = '/ai/recommendations';
    List<String> queryParams = [];
    if (missionId != null) queryParams.add('missionId=$missionId');
    if (status != null) queryParams.add('status=$status');
    
    if (queryParams.isNotEmpty) {
      url += '?${queryParams.join('&')}';
    }
    return ApiClient.get(url);
  }

  static Future<ApiResponse> approveRecommendation(int id) {
    return ApiClient.post('/ai/recommendations/$id/approve', {});
  }

  static Future<ApiResponse> getMissionRisk({int? missionId}) {
    String url = '/ai/mission-risk';
    if (missionId != null) url += '?missionId=$missionId';
    return ApiClient.get(url);
  }

  static Future<ApiResponse> getCargoRisks({int? missionId}) {
    String url = '/ai/cargo-risks';
    if (missionId != null) url += '?missionId=$missionId';
    return ApiClient.get(url);
  }

  static Future<ApiResponse> getInventoryRisks({int? missionId}) {
    String url = '/ai/inventory-risks';
    if (missionId != null) url += '?missionId=$missionId';
    return ApiClient.get(url);
  }

  static Future<ApiResponse> rejectRecommendation(int id) {
    return ApiClient.post('/ai/recommendations/$id/reject', {});
  }

  static Future<ApiResponse> analyzeMission({int? missionId}) {
    String url = '/ai/analyze';
    if (missionId != null) {
      url += '?missionId=$missionId';
    }
    return ApiClient.post(url, {});
  }
}
