// 📄 lib/bloc/auth/auth_event.dart
// ============================================================
// 🎯 أحداث المصادقة - الرسائل اللي بترسل للـ BLoC
// ============================================================

part of 'auth_bloc.dart';  // ← هذا السطر ضروري عشان يكون جزء من auth_bloc.dart

// ✅ الكلاس الأساسي لكل الأحداث (للمقارنة عبر Equatable)
abstract class AuthEvent {
  const AuthEvent();
}

// 🔐 حدث تسجيل الدخول
class LoginEvent extends AuthEvent {
  final String email;
  final String password;

  const LoginEvent({required this.email, required this.password});
}

// 📝 حدث التسجيل الجديد
class RegisterEvent extends AuthEvent {
  final String name;
  final String email;
  final String password;
  final UserType userType;  // ✅ نوع المستخدم مهم هنا

  const RegisterEvent({
    required this.name,
    required this.email,
    required this.password,
    required this.userType,
  });
}

// 🚪 حدث تسجيل الخروج
class LogoutEvent extends AuthEvent {
  const LogoutEvent();
}

// 🔍 حدث التحقق من الحالة عند فتح التطبيق
class CheckAuthStatusEvent extends AuthEvent {
  const CheckAuthStatusEvent();
}

// ✏️ حدث تحديث بيانات البروفايل
class UpdateProfileEvent extends AuthEvent {
  final String? name;
  final String? phone;
  final String? bio;
  final String? profileImage;

  const UpdateProfileEvent({
    this.name, this.phone, this.bio, this.profileImage,
  });
}