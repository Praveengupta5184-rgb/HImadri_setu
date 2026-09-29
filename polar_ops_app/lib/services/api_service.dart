import 'package:dio/dio.dart';

class ApiService {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://localhost:8080/api/v1'));

  Future<dynamic> getCargoDetails(String id) async {
    try {
      final response = await _dio.get('/cargo/$id');
      return response.data;
    } catch (e) {
      print('API Error: $e');
      return null;
    }
  }
}
