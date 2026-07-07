import '../models/user.dart';
import 'api_client.dart';

class AuthResult {
  AuthResult({required this.token, required this.user});
  final String token;
  final User user;
}

class AuthService {
  AuthService([ApiClient? client]) : _api = client ?? ApiClient();
  final ApiClient _api;

  Future<AuthResult> signup({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) async {
    final data = await _api.post('/api/auth/signup', body: {
      'email': email,
      'password': password,
      'fullName': fullName,
      if (phone != null && phone.isNotEmpty) 'phone': phone,
    });
    return AuthResult(
      token: data['token'] as String,
      user: User.fromJson((data['user'] as Map).cast<String, dynamic>()),
    );
  }

  Future<AuthResult> login({required String email, required String password}) async {
    final data = await _api.post('/api/auth/login', body: {
      'email': email,
      'password': password,
    });
    return AuthResult(
      token: data['token'] as String,
      user: User.fromJson((data['user'] as Map).cast<String, dynamic>()),
    );
  }

  Future<User> me() async {
    final data = await _api.get('/api/auth/me');
    return User.fromJson((data as Map).cast<String, dynamic>());
  }
}
