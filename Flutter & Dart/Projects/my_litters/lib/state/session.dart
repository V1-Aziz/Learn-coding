import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/token_store.dart';

/// Holds the currently signed-in user and exposes auth actions to the UI.
/// Provided at the root of the app via `ChangeNotifierProvider`.
class Session extends ChangeNotifier {
  Session(this._authService);

  final AuthService _authService;

  User? _user;
  bool _initialized = false;

  User? get user => _user;
  bool get isLoggedIn => _user != null;
  bool get isInitialized => _initialized;

  /// Called once at app startup. Tries the stored token; if it works we
  /// land directly on the dashboard, otherwise we fall back to login.
  Future<void> bootstrap() async {
    final token = await TokenStore.read();
    if (token == null || token.isEmpty) {
      _initialized = true;
      notifyListeners();
      return;
    }
    try {
      _user = await _authService.me();
    } catch (_) {
      await TokenStore.clear();
      _user = null;
    } finally {
      _initialized = true;
      notifyListeners();
    }
  }

  Future<void> login(String email, String password) async {
    final result = await _authService.login(email: email, password: password);
    await TokenStore.write(result.token);
    _user = result.user;
    notifyListeners();
  }

  Future<void> signup({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) async {
    final result = await _authService.signup(
      email: email,
      password: password,
      fullName: fullName,
      phone: phone,
    );
    await TokenStore.write(result.token);
    _user = result.user;
    notifyListeners();
  }

  Future<void> logout() async {
    await TokenStore.clear();
    _user = null;
    notifyListeners();
  }

  /// Re-fetches the current user from the backend. Used after a profile
  /// edit so the dashboard / profile screen reflect the new values.
  Future<void> refreshMe() async {
    try {
      _user = await _authService.me();
      notifyListeners();
    } catch (_) {
      // ignore; old user data remains in place
    }
  }
}
