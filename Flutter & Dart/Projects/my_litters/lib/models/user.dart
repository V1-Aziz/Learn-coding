/// User as returned by the backend `/api/auth/me` endpoint.
///
/// Fields beyond the backend shape (username, dateOfBirth, age,
/// memberSince) are derived locally so the existing profile screen
/// keeps working until it's redesigned.
class User {
  final String id;
  final String email;
  final String fullName;
  final String phone;
  final String idNumber; // maps to backend `nationalId`
  final String role;
  final DateTime? createdAt;

  // Optional UI-only fields with sane defaults so the screen never NPEs.
  final String dateOfBirth;
  final String age;

  const User({
    this.id = '',
    required this.email,
    required this.fullName,
    this.phone = '',
    this.idNumber = '',
    this.role = 'customer',
    this.createdAt,
    this.dateOfBirth = '—',
    this.age = '—',
  });

  /// Username derived from the email local-part for display.
  String get username => email.contains('@') ? email.split('@').first : email;

  /// Member-since year derived from createdAt.
  String get memberSince {
    if (createdAt == null) return '—';
    return '${createdAt!.year}';
  }

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] as String? ?? '',
        email: json['email'] as String? ?? '',
        fullName: json['fullName'] as String? ?? '',
        phone: (json['phone'] as String?) ?? '',
        idNumber: (json['nationalId'] as String?) ?? '',
        role: json['role'] as String? ?? 'customer',
        createdAt: _parseDate(json['createdAt']),
      );

  static DateTime? _parseDate(dynamic v) {
    if (v is String) return DateTime.tryParse(v);
    return null;
  }

  User copyWith({String? phone, String? idNumber, String? fullName}) => User(
        id: id,
        email: email,
        fullName: fullName ?? this.fullName,
        phone: phone ?? this.phone,
        idNumber: idNumber ?? this.idNumber,
        role: role,
        createdAt: createdAt,
        dateOfBirth: dateOfBirth,
        age: age,
      );
}
