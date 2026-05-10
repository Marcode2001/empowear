// 📄 lib/bloc/auth/auth_bloc.dart
// ============================================================
// 🧠 BLoC إدارة المصادقة - العقل المدبر
// ============================================================

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../models/user_model.dart';
import '../../repositories/auth_repository.dart';

// ✅ استيراد ملفات الأحداث والحالات (Part files)
part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {

  // ✅ إنشاء نسخة من الـ Repository
  final AuthRepository _authRepository = AuthRepository();

  AuthBloc() : super(const AuthInitial()) {
    // ✅ ربط الأحداث بالدوال المعالجة
    on<LoginEvent>(_onLogin);
    on<RegisterEvent>(_onRegister);
    on<LogoutEvent>(_onLogout);
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<UpdateProfileEvent>(_onUpdateProfile);
  }

  // 🔐 معالجة حدث تسجيل الدخول
  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());

    try {
      print('🚀 BLoC: Starting login process...');

      // ✅ 1. استدعاء الـ Repository للاتصال بالباك إند
      final result = await _authRepository.login(
        email: event.email,
        password: event.password,
      );

      // ✅ 2. التحقق من نتيجة الاتصال
      if (result['success']) {
        final user = result['user'] as User;
        print('✅ BLoC: Login successful for ${user.email}');
        emit(AuthAuthenticated(user: user));
      } else {
        print('❌ BLoC: Login failed - ${result['message']}');
        emit(AuthError(message: result['message'] ?? 'فشل تسجيل الدخول'));
      }

    } catch (e) {
      print('🔥 BLoC: Exception occurred: $e');
      emit(AuthError(message: 'خطأ في الاتصال: ${e.toString()}'));
    }
  }

  // 📝 معالجة حدث التسجيل
  Future<void> _onRegister(RegisterEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());

    try {
      final result = await _authRepository.register(
        name: event.name,
        email: event.email,
        password: event.password,
        userType: event.userType,
      );

      if (result['success']) {
        final user = result['user'] as User;
        emit(AuthAuthenticated(user: user));
      } else {
        emit(AuthError(message: result['message'] ?? 'فشل التسجيل'));
      }

    } catch (e) {
      emit(AuthError(message: 'خطأ في الاتصال: ${e.toString()}'));
    }
  }

  // 🚪 معالجة حدث تسجيل الخروج
  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());

    try {
      await _authRepository.logout();
      emit(const AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(message: 'فشل تسجيل الخروج: ${e.toString()}'));
    }
  }

  // 🔍 معالجة حدث التحقق من الحالة (عند فتح التطبيق)
  Future<void> _onCheckAuthStatus(CheckAuthStatusEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());

    try {
      // ✅ التحقق من وجود توكن أولاً
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      if (token != null) {
        // ✅ إذا في توكن، نحاول نجيب بيانات المستخدم من التخزين المحلي
        final user = await _authRepository.getCurrentUser();

        if (user != null) {
          print('✅ BLoC: User session restored: ${user.email}');
          emit(AuthAuthenticated(user: user));
        } else {
          print('⚠️ BLoC: Token exists but user data missing');
          emit(const AuthUnauthenticated());
        }
      } else {
        print('ℹ️ BLoC: No token found, user is guest');
        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      print('❌ BLoC: Error checking auth status: $e');
      emit(const AuthUnauthenticated());
    }
  }

  // ✏️ معالجة حدث تحديث البروفايل
  Future<void> _onUpdateProfile(UpdateProfileEvent event, Emitter<AuthState> emit) async {
    // هذا الحدث يحتاج تطبيق إضافي في الـ Repository إذا لزم
    // حالياً سنقوم بتحديث الواجهة فقط بناءً على البيانات الجديدة
    if (state is AuthAuthenticated) {
      final currentUser = (state as AuthAuthenticated).user;

      final updatedUser = User(
        id: currentUser.id,
        name: event.name ?? currentUser.name,
        email: currentUser.email,
        userType: currentUser.userType,
        phone: event.phone ?? currentUser.phone,
        bio: event.bio ?? currentUser.bio,
        profileImage: event.profileImage ?? currentUser.profileImage,
      );

      // حفظ التحديث محلياً
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_data', json.encode(updatedUser.toJson()));

      emit(AuthAuthenticated(user: updatedUser));
    }
  }
}