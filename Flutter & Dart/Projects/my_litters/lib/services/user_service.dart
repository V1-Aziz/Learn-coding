import '../models/user.dart';
import 'api_client.dart';

class UserService {
  UserService([ApiClient? client]) : _api = client ?? ApiClient();
  final ApiClient _api;

  /// Re-fetches the signed-in user.
  Future<User> getMe() async {
    final data = await _api.get('/api/auth/me');
    return User.fromJson((data as Map).cast<String, dynamic>());
  }

  Future<User> updateMe({
    String? fullName,
    String? phone,
    String? nationalId,
  }) async {
    final data = await _api.patch('/api/users/me', body: {
      if (fullName != null) 'fullName': fullName,
      if (phone != null) 'phone': phone,
      if (nationalId != null) 'nationalId': nationalId,
    });
    return User.fromJson((data as Map).cast<String, dynamic>());
  }
}
