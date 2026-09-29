import '../api/api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static String? currentUserRole;
  static String? currentToken;
  static int? currentUserId;
  static String? currentUserName;
  static String? currentUserEmail;

  static const List<String> officerRoles = [
    'ADMIN',
    'MISSION_OFFICER',
    'STATION_OFFICER',
    'LOGISTICS_OFFICER',
    'ASSET_OFFICER',
    'MEDICAL_OFFICER'
  ];

  static Future<AuthResult> login(String email, String password) async {
    final response = await ApiClient.post('/auth/login', {
      'email': email,
      'password': password
    });

    if (response.success && response.data != null) {
      final data = response.data as Map<String, dynamic>;
      currentToken = data['token'] as String?;
      currentUserRole = data['role'] as String?;
      currentUserId = data['userId'] as int?;
      currentUserName = data['name'] as String?;
      currentUserEmail = data['email'] as String?;
      if (currentToken != null) {
        ApiClient.setAuthToken(currentToken!);
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwt_token', currentToken!);
      await prefs.setString('user_role', currentUserRole!);
      await prefs.setString('user_name', currentUserName ?? '');
      await prefs.setString('user_email', currentUserEmail ?? '');
      await prefs.setInt('user_id', currentUserId ?? 0);
      return AuthResult.success(currentToken!, currentUserRole!);
    }
    String errorMessage = response.error ?? 'Invalid credentials.';
    if (response.data is Map) {
      errorMessage = (response.data as Map)['message'] ?? errorMessage;
    }
    return AuthResult.failure(errorMessage);
  }

  static Future<AuthResult> register(String email, String password, String name) async {
    final response = await ApiClient.post('/auth/register', {
      'email': email,
      'password': password,
      'name': name
    });

    if (response.success) {
      final data = response.data as Map<String, dynamic>;
      return AuthResult.registrationPending(
        data['email'] ?? email,
        data['message'] ??
            'Registration successful. Account pending administrator approval.',
      );
    }
    String errorMessage = response.error ?? 'Registration failed.';
    if (response.data is Map) {
      errorMessage = (response.data as Map)['message'] ?? errorMessage;
    }
    return AuthResult.failure(errorMessage);
  }

  static Future<void> logout() async {
    currentToken = null;
    currentUserRole = null;
    currentUserId = null;
    currentUserName = null;
    currentUserEmail = null;
    ApiClient.setAuthToken('');
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    await prefs.remove('user_role');
    await prefs.remove('user_name');
    await prefs.remove('user_email');
    await prefs.remove('user_id');
  }

  static Future<void> loadSavedAuth() async {
    final prefs = await SharedPreferences.getInstance();
    currentToken = prefs.getString('jwt_token');
    currentUserRole = prefs.getString('user_role');
    currentUserId = prefs.getInt('user_id');
    currentUserName = prefs.getString('user_name');
    currentUserEmail = prefs.getString('user_email');
    if (currentToken != null) {
      ApiClient.setAuthToken(currentToken!);
    }
  }

  static bool get isAuthenticated =>
      currentToken != null && currentToken!.isNotEmpty;

  static bool hasRole(List<String> allowedRoles) {
    if (currentUserRole == null) return false;
    if (currentUserRole == 'ADMIN') return true;
    return allowedRoles.contains(currentUserRole);
  }

  static bool get isOfficer =>
      currentUserRole != null && officerRoles.contains(currentUserRole);

  static bool get isAdmin => currentUserRole == 'ADMIN';
}

class AuthResult {
  final bool success;
  final bool registrationPending;
  final String? token;
  final String? role;
  final String? email;
  final String message;

  AuthResult.success(this.token, this.role)
      : success = true,
        registrationPending = false,
        email = null,
        message = 'Login successful.';

  AuthResult.registrationPending(this.email, this.message)
      : success = true,
        registrationPending = true,
        token = null,
        role = null;

  AuthResult.failure(this.message)
      : success = false,
        registrationPending = false,
        token = null,
        role = null,
        email = null;
}
