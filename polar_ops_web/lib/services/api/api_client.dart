import 'dart:convert';
import 'package:http/http.dart' as http;
import '../sync/sync_service.dart';

class ApiResponse<T> {
  final T? data;
  final String? error;
  final bool success;

  ApiResponse({this.data, this.error, required this.success});
}

class ApiClient {
  static const String baseUrl = 'https://himadri-setu.onrender.com/api/v1';
  static String? _authToken;

  static void setAuthToken(String token) {
    _authToken = token;
  }

  static Map<String, String> get _headers {
    final headers = {'Content-Type': 'application/json'};
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  static Future<ApiResponse<T>> get<T>(String endpoint,
      {T Function(dynamic)? parser}) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl$endpoint'), headers: _headers)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = json.decode(response.body);
        return ApiResponse(
          success: true,
          data: parser != null ? parser(decoded) : decoded as T,
        );
      } else {
        dynamic errorData;
        try {
          errorData = json.decode(response.body);
        } catch (_) {}
        final String friendly = _friendlyError(response.statusCode);
        final String? backendMessage =
            errorData is Map ? errorData['message'] as String? : null;
        return ApiResponse(
          success: false,
          error: backendMessage ?? friendly,
          data: errorData,
        );
      }
    } catch (_) {
      return ApiResponse(
          success: false,
          error: 'The command service is currently unreachable.');
    }
  }

  static Future<ApiResponse<T>> post<T>(
      String endpoint, Map<String, dynamic> body,
      {T Function(dynamic)? parser}) async {
    if (!SyncService.isOnline) {
      await SyncService.enqueueOperation('POST', endpoint, body);
      return ApiResponse(success: true, data: null); // Optimistic return
    }

    try {
      final response = await http
          .post(Uri.parse('$baseUrl$endpoint'),
              headers: _headers, body: json.encode(body))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = json.decode(response.body);
        return ApiResponse(
          success: true,
          data: parser != null ? parser(decoded) : decoded as T,
        );
      } else {
        dynamic errorData;
        try {
          errorData = json.decode(response.body);
        } catch (_) {}
        final String friendly = _friendlyError(response.statusCode);
        final String? backendMessage =
            errorData is Map ? errorData['message'] as String? : null;
        return ApiResponse(
          success: false,
          error: backendMessage ?? friendly,
          data: errorData,
        );
      }
    } catch (_) {
      return ApiResponse(
          success: false,
          error: 'The command service is currently unreachable.');
    }
  }

  static Future<ApiResponse<T>> put<T>(
      String endpoint, Map<String, dynamic> body,
      {T Function(dynamic)? parser}) async {
    if (!SyncService.isOnline) {
      await SyncService.enqueueOperation('PUT', endpoint, body);
      return ApiResponse(success: true, data: null); // Optimistic return
    }

    try {
      final response = await http
          .put(Uri.parse('$baseUrl$endpoint'),
              headers: _headers, body: json.encode(body))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = json.decode(response.body);
        return ApiResponse(
          success: true,
          data: parser != null ? parser(decoded) : decoded as T,
        );
      } else {
        dynamic errorData;
        try {
          errorData = json.decode(response.body);
        } catch (_) {}
        final String friendly = _friendlyError(response.statusCode);
        final String? backendMessage =
            errorData is Map ? errorData['message'] as String? : null;
        return ApiResponse(
          success: false,
          error: backendMessage ?? friendly,
          data: errorData,
        );
      }
    } catch (_) {
      return ApiResponse(
          success: false,
          error: 'The command service is currently unreachable.');
    }
  }

  static Future<ApiResponse<T>> patch<T>(
      String endpoint, Map<String, dynamic> body,
      {T Function(dynamic)? parser}) async {
    if (!SyncService.isOnline) {
      await SyncService.enqueueOperation('PATCH', endpoint, body);
      return ApiResponse(success: true, data: null); // Optimistic return
    }

    try {
      final response = await http
          .patch(Uri.parse('$baseUrl$endpoint'),
              headers: _headers, body: json.encode(body))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = json.decode(response.body);
        return ApiResponse(
          success: true,
          data: parser != null ? parser(decoded) : decoded as T,
        );
      } else {
        dynamic errorData;
        try {
          errorData = json.decode(response.body);
        } catch (_) {}
        final String friendly = _friendlyError(response.statusCode);
        final String? backendMessage =
            errorData is Map ? errorData['message'] as String? : null;
        return ApiResponse(
          success: false,
          error: backendMessage ?? friendly,
          data: errorData,
        );
      }
    } catch (_) {
      return ApiResponse(
          success: false,
          error: 'The command service is currently unreachable.');
    }
  }

  static String _friendlyError(int statusCode) {
    if (statusCode == 401 || statusCode == 403)
      return 'Your session does not have access to this operation.';
    if (statusCode == 404) return 'This operational resource is not available.';
    if (statusCode == 409) return 'This mission is closed; operational mutations are not permitted.';
    if (statusCode >= 500)
      return 'The command service could not complete the request.';
    return 'The request could not be completed.';
  }
}
