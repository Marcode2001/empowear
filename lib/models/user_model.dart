enum UserType {
  admin,
  trainer,
  trainee,
}

class UserModel {
  final String id;
  final String name;
  final String email;
  final UserType userType;
  final String? profileImage;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.userType,
    this.profileImage,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'userType': userType.toString(),
      'profileImage': profileImage,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      userType: _stringToUserType(map['userType']),
      profileImage: map['profileImage'],
    );
  }

  static UserType _stringToUserType(String type) {
    switch (type) {
      case 'UserType.admin':
        return UserType.admin;
      case 'UserType.trainer':
        return UserType.trainer;
      default:
        return UserType.trainee;
    }
  }
}