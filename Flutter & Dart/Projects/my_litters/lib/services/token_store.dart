import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Thin wrapper around [FlutterSecureStorage] for the JWT.
/// On iOS this is the keychain; on Android it's encrypted shared prefs.
class TokenStore {
  TokenStore._();

  static const _key = 'jwt';
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static Future<void> write(String token) => _storage.write(key: _key, value: token);
  static Future<String?> read() => _storage.read(key: _key);
  static Future<void> clear() => _storage.delete(key: _key);
}
