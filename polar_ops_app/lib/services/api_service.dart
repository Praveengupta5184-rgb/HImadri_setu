import 'package:dio/dio.dart';

import 'dart:io' show Platform;

class ApiService {
  static String get _defaultUrl {
    try {
      if (Platform.isAndroid) return 'http://10.48.32.89:8080/api/v1'; // Physical device IP
    } catch (e) {}
    return 'http://10.48.32.89:8080/api/v1';
  }
  
  static final String baseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: _defaultUrl);
  final Dio _dio = Dio(BaseOptions(baseUrl: baseUrl));
  
  void setToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  Future<dynamic> login(String email, String password) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password
      });
      return response.data;
    } catch (e) {
      print('API Error (Login): $e');
      throw e;
    }
  }

  Future<dynamic> getCargoDetails(String id) async {
    try {
      final response = await _dio.get('/cargo/$id');
      return response.data;
    } catch (e) {
      print('API Error: $e');
      return null;
    }
  }
  
  Future<dynamic> createEmergency(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/emergencies', data: data);
      return response.data;
    } catch (e) {
      print('API Error (Emergency): $e');
      throw e;
    }
  }
}
