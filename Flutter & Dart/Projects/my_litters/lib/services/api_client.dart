import 'package:dio/dio.dart';
import 'token_store.dart';

/// Single Dio instance used by every service. Attaches the JWT to every
/// request once a session is established and unwraps the standard
/// `{ success, data, message }` envelope used by the backend.
class ApiClient {
  ApiClient._(this._dio);

  static ApiClient? _instance;

  /// Override the base URL once at app startup. Defaults to localhost:3000
  /// which works for `flutter run -d chrome` and the iOS Simulator.
  /// On Android emulator, set this to `http://10.0.2.2:3000` instead.
  static String baseUrl = const String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000',
  );

  final Dio _dio;

  factory ApiClient() {
    _instance ??= ApiClient._(_buildDio());
    return _instance!;
  }

  static Dio _buildDio() {
    final dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      contentType: 'application/json',
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await TokenStore.read();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
    ));

    return dio;
  }

  /// Issues a request and returns the unwrapped `data` field.
  /// Throws [ApiException] on non-2xx or non-success responses.
  Future<dynamic> _request(
    String method,
    String path, {
    Object? body,
    Map<String, dynamic>? query,
  }) async {
    try {
      final res = await _dio.request<Map<String, dynamic>>(
        path,
        data: body,
        queryParameters: query,
        options: Options(method: method),
      );
      final json = res.data ?? const {};
      if (json['success'] == true) return json['data'];
      throw ApiException(
        json['message']?.toString() ?? 'Request failed',
        statusCode: res.statusCode ?? 0,
      );
    } on DioException catch (e) {
      final body = e.response?.data;
      final msg = (body is Map && body['message'] is String)
          ? body['message'] as String
          : (e.message ?? 'Network error');
      throw ApiException(msg, statusCode: e.response?.statusCode ?? 0);
    }
  }

  Future<dynamic> get(String path, {Map<String, dynamic>? query}) =>
      _request('GET', path, query: query);
  Future<dynamic> post(String path, {Object? body}) =>
      _request('POST', path, body: body);
  Future<dynamic> patch(String path, {Object? body}) =>
      _request('PATCH', path, body: body);
  Future<dynamic> delete(String path) => _request('DELETE', path);
}

class ApiException implements Exception {
  ApiException(this.message, {this.statusCode = 0});
  final String message;
  final int statusCode;

  @override
  String toString() => 'ApiException($statusCode): $message';
}
