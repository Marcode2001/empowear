// 📄 lib/bloc/auth/auth_state.dart
// ============================================================
// 🎯 حالات المصادقة - الردود اللي بترجع من الـ BLoC
// ============================================================

part of 'auth_bloc.dart';  // ← هذا السطر ضروري

// ✅ الكلاس الأساسي لكل الحالات
abstract class AuthState {
  const AuthState();
}

// 🟡 الحالة الابتدائية (قبل أي حدث)
class AuthInitial extends AuthState {
  const AuthInitial();
}

// 🔄 حالة التحميل (جاري الاتصال بالسيرفر)
class AuthLoading extends AuthState {
  const AuthLoading();
}

// ✅ حالة تسجيل الدخول الناجح (تحمل بيانات المستخدم)
class AuthAuthenticated extends AuthState {
  final User user;  // ← هذا الـ User فيه userType صح

  const AuthAuthenticated({required this.user});
}

// ❌ حالة عدم تسجيل الدخول (ضيف)
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

// 🔴 حالة الخطأ (تحمل رسالة الخطأ)
class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});
}