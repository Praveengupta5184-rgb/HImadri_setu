import 'api_client.dart';

class TeamService {
  /// Fetches team data by teamCode.
  /// Backend enforces: JWT auth + active team membership.
  /// Returns 403 if user is not an authorized member.
  static Future<ApiResponse<Map<String, dynamic>>> getTeamMembers(String teamCode) async {
    return ApiClient.get('/teams/$teamCode/members',
        parser: (data) => data as Map<String, dynamic>);
  }

  /// Returns list of team codes/names the current user is an active member of.
  static Future<ApiResponse<List<dynamic>>> getMyTeams() async {
    return ApiClient.get('/teams/mine', parser: (data) => data as List<dynamic>);
  }
}
