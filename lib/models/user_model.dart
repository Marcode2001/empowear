// 📄 lib/models/user_model.dart
// ============================================================
// 🧑 نموذج بيانات المستخدم - موحد للتطبيق
// ============================================================

enum UserType { admin, trainer, trainee, unknown }

class User {
  final String id;
  final String name;
  final String email;
  final UserType userType;
  final String phone;
  final String bio;
  final String profileImage;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.userType,
    this.phone = '',
    this.bio = '',
    this.profileImage = '',
  });

  // ✅ دالة لتحويل بيانات الـ JSON القادمة من الباك إند إلى كائن User
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? json['user_id']?.toString() ?? '',
      name: json['full_name'] ?? json['username'] ?? json['name'] ?? '',
      email: json['email'] ?? '',
      userType: _parseUserType(json['role'] ?? json['user_type']),
      phone: json['phone_number'] ?? json['phone'] ?? '',
      bio: json['location'] ?? json['bio'] ?? '',
      profileImage: json['profile_image'] ?? json['profileImage'] ?? '',
    );
  }

  // ✅ دالة مساعدة لتحويل نص الـ Role إلى Enum
  static UserType _parseUserType(String? role) {
    if (role == null) return UserType.trainee;
    switch (role.toLowerCase()) {
      case 'admin': return UserType.admin;
      case 'trainer': return UserType.trainer;
      case 'trainee': return UserType.trainee;
      default: return UserType.unknown;
    }
  }

  // ✅ دالة لتحويل الـ User إلى Map (للتخزين أو الإرسال)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': _userTypeToString(userType),
      'phone': phone,
      'bio': bio,
      'profileImage': profileImage,
    };
  }

  String _userTypeToString(UserType type) {
    switch (type) {
      case UserType.admin: return 'admin';
      case UserType.trainer: return 'trainer';
      case UserType.trainee: return 'trainee';
      default: return 'trainee';
    }
  }
}