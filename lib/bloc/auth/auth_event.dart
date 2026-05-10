// 📄 lib/bloc/auth/auth_event.dart
part of 'auth_bloc.dart';

abstract class AuthEvent {
  const AuthEvent();
}

class LoginEvent extends AuthEvent {
  final String email;
  final String password;
  const LoginEvent({required this.email, required this.password});
}

class RegisterEvent extends AuthEvent {
  final String name;
  final String email;
  final String password;
  final UserType userType;
  const RegisterEvent({
    required this.name,
    required this.email,
    required this.password,
    required this.userType,
  });
}

class LogoutEvent extends AuthEvent {
  const LogoutEvent();
}

class CheckAuthStatusEvent extends AuthEvent {
  const CheckAuthStatusEvent();
}

class UpdateProfileEvent extends AuthEvent {
  final String? name;
  final String? phone;
  final String? bio;
  final String? profileImage;
  const UpdateProfileEvent({
    this.name, this.phone, this.bio, this.profileImage,
  });
}