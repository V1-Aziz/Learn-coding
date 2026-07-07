import '../models/user.dart';
import '../services/user_service.dart';

class ProfileController {
  final UserService _service = UserService();

  Future<User> getUser() => _service.getMe();

  Future<User> updateUser({
    String? fullName,
    String? phone,
    String? nationalId,
  }) =>
      _service.updateMe(
        fullName: fullName,
        phone: phone,
        nationalId: nationalId,
      );
}
