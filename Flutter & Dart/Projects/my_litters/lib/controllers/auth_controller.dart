import '../services/auth_service.dart';

/// Thin wrapper kept for backward compatibility. New screens should
/// prefer the [Session] provider directly (see lib/state/session.dart).
class AuthController {
  AuthController() : _service = AuthService();
  final AuthService _service;

  Future<AuthResult> login(String email, String password) =>
      _service.login(email: email, password: password);

  Future<AuthResult> signup({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) =>
      _service.signup(
        email: email,
        password: password,
        fullName: fullName,
        phone: phone,
      );
}
