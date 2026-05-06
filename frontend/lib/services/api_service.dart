/// API-Service für die Kommunikation mit dem FastAPI-Backend
/// Handles HTTP-Requets, Token-Management und Fehlerbehandlung
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();

  factory ApiService() => _instance;

  late final Dio _dio;
  late final SharedPreferences _prefs;

  ApiService._internal() {
    _init();
  }

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
    _dio = Dio(
      BaseOptions(
        baseUrl: 'http://localhost:8001', // oder deine Backend-URL
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );

    // Interceptor für Token-Management
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = _prefs.getString('auth_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) {
          // Token abgelaufen -> refresh logic hier
          if (error.response?.statusCode == 401) {
            // Token refresh oder logout
          }
          return handler.next(error);
        },
      ),
    );
  }

  // GET Request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw handleError(e);
    }
  }

  // POST Request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
      );
    } on DioException catch (e) {
      throw handleError(e);
    }
  }

  // PATCH Request
  Future<Response> patch(String path, {dynamic data}) async {
    try {
      return await _dio.patch(path, data: data);
    } on DioException catch (e) {
      throw handleError(e);
    }
  }

  // PUT Request
  Future<Response> put(String path, {dynamic data}) async {
    try {
      return await _dio.put(path, data: data);
    } on DioException catch (e) {
      throw handleError(e);
    }
  }

  // DELETE Request
  Future<Response> delete(String path, {dynamic data}) async {
    try {
      return await _dio.delete(path, data: data);
    } on DioException catch (e) {
      throw handleError(e);
    }
  }

  // Hilfsfunktion für Fehlerbehandlung
  Exception handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return Exception('Verbindungszeitüberschreitung');
      case DioExceptionType.badResponse:
        return Exception('Server-Fehler: ${error.response?.statusCode}');
      case DioExceptionType.cancel:
        return Exception('Anfrage abgebrochen');
      case DioExceptionType.connectionError:
        return Exception('Keine Verbindung zum Server');
      default:
        return Exception('Ein unerwarteter Fehler ist aufgetreten');
    }
  }

  // Token-Methoden
  Future<void> saveToken(String token) async {
    await _prefs.setString('auth_token', token);
  }

  String? getToken() {
    return _prefs.getString('auth_token');
  }

  Future<void> clearToken() async {
    await _prefs.remove('auth_token');
  }
}
