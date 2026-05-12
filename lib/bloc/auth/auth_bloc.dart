// 📄 lib/bloc/auth/auth_bloc.dart
// ============================================================
// 🧠 BLoC إدارة المصادقة - العقل المدبر (النسخة المصححة)
// ============================================================
// الوظيفة:
// - إدارة حالة تسجيل الدخول/الخروج
// - حفظ واستعادة بيانات المستخدم من التخزين المحلي
// - توجيه التطبيق حسب نوع المستخدم (أدمن/مدرب/طالب)

import 'package:flutter_bloc/flutter_bloc.dart';           // مكتبة إدارة الحالة
import 'package:shared_preferences/shared_preferences.dart'; // للتخزين المحلي
import 'dart:convert';                                       // لتحويل الـ JSON
import '../../models/user_model.dart';                      // نموذج المستخدم
import '../../repositories/auth_repository.dart';           // مستودع المصادقة

// ✅ استيراد ملفات الأحداث والحالات (Part files)
part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {

  // ✅ إنشاء نسخة من الـ Repository للاتصال بالباك إند
  final AuthRepository _authRepository = AuthRepository();

  AuthBloc() : super(const AuthInitial()) {
    // ✅ ربط كل حدث بالدالة اللي بتعالجه
    on<LoginEvent>(_onLogin);
    on<RegisterEvent>(_onRegister);
    on<LogoutEvent>(_onLogout);
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<UpdateProfileEvent>(_onUpdateProfile);
  }

  // 🔐 معالجة حدث تسجيل الدخول
  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());  // نعلن إننا بنحمل

    try {
      print('🚀 BLoC: Starting login process for ${event.email}...');

      // ✅ 1. استدعاء الـ Repository للاتصال بالباك إند
      final result = await _authRepository.login(
        email: event.email,
        password: event.password,
      );

      // ✅ 2. التحقق من نتيجة الاتصال
      if (result['success']) {
        final user = result['user'] as User;  // نأخذ كائن المستخدم
        print('✅ BLoC: Login successful for ${user.email}');
        print('✅ BLoC: User type is ${user.userType}');

        // ✅ 3. حفظ التوكن والمستخدم في التخزين المحلي (مهم جداً!)
        await _saveUserData(user, result['token'] as String);

        // ✅ 4. نعلن إن المستخدم مسجل دخول
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

        // ✅ حفظ بيانات المستخدم الجديد
        await _saveUserData(user, result['token'] as String);

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
      // ✅ ننادي الـ Repository عشان يحذف التوكن من الباك إند
      await _authRepository.logout();

      // ✅ نمسح البيانات من التخزين المحلي
      await _clearUserData();

      // ✅ نعلن إن المستخدم طلع بره
      emit(const AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(message: 'فشل تسجيل الخروج: ${e.toString()}'));
    }
  }

  // 🔍 معالجة حدث التحقق من الحالة (عند فتح التطبيق)
  Future<void> _onCheckAuthStatus(CheckAuthStatusEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());

    try {
      // ✅ نجيب نسخة من التخزين المحلي
      final prefs = await SharedPreferences.getInstance();

      // ✅ نحاول نجيب التوكن
      final token = prefs.getString('access_token');

      // ✅ نحاول نجيب بيانات المستخدم المحفوظة كـ JSON
      final userJson = prefs.getString('user_data');

      // ✅ إذا في توكن وبيانات مستخدم، نعيد بناء الجلسة
      if (token != null && userJson != null) {
        // ✅ نحول الـ JSON النصي لكائن User
        // ← هنا الـ fromJson بيرجع userType صح لأننا حفظناه كـ "trainer"
        final user = User.fromJson(jsonDecode(userJson));

        print('✅ BLoC: User session restored: ${user.email}');
        print('✅ BLoC: User type restored: ${user.userType}');

        // ✅ نعلن إن المستخدم مسجل دخول بالبيانات المستعادة
        emit(AuthAuthenticated(user: user));
      } else {
        // ✅ إذا ما في توكن أو بيانات، المستخدم ضيف
        print('ℹ️ BLoC: No saved session found, user is guest');
        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      print('❌ BLoC: Error checking auth status: $e');
      // ✅ في حالة خطأ، نعتبر المستخدم ضيف عشان ما نعلق التطبيق
      emit(const AuthUnauthenticated());
    }
  }

  // ✏️ معالجة حدث تحديث البروفايل
  Future<void> _onUpdateProfile(UpdateProfileEvent event, Emitter<AuthState> emit) async {
    // ✅ نتأكد إن الحالة الحالية فيها مستخدم مسجل
    if (state is AuthAuthenticated) {
      final currentUser = (state as AuthAuthenticated).user;

      // ✅ ننشئ نسخة محدثة من المستخدم مع الحفاظ على الحقول القديمة
      final updatedUser = User(
        id: currentUser.id,
        name: event.name ?? currentUser.name,
        email: currentUser.email,  // الإيميل ما بيتغير
        userType: currentUser.userType,  // نوع المستخدم ما بيتغير
        phone: event.phone ?? currentUser.phone,
        bio: event.bio ?? currentUser.bio,
        profileImage: event.profileImage ?? currentUser.profileImage,
      );

      // ✅ نحفظ التحديثات في التخزين المحلي
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_data', json.encode(updatedUser.toJson()));

      // ✅ نعلن الحالة الجديدة مع المستخدم المحدث
      emit(AuthAuthenticated(user: updatedUser));
    }
  }

  // ============================================================
  // 🔧 دوال مساعدة خاصة (لا تُستخدم خارج الكلاس)
  // ============================================================

  // ✅ دالة لحفظ بيانات المستخدم والتوكن في التخزين المحلي
  Future<void> _saveUserData(User user, String token) async {
    final prefs = await SharedPreferences.getInstance();

    // ✅ نحفظ التوكن عشان نستخدمه في طلبات الـ API
    await prefs.setString('access_token', token);

    // ✅ نحفظ المستخدم كامل كـ JSON
    // ← هذا ضروري عشان نرجع نقرأ userType صح لاحقاً
    await prefs.setString('user_data', json.encode(user.toJson()));

    print('💾 BLoC: User data saved successfully');
    print('💾 BLoC: Saved userType: ${user.userType}');
  }

  // ✅ دالة لمسح بيانات المستخدم عند تسجيل الخروج
  Future<void> _clearUserData() async {
    final prefs = await SharedPreferences.getInstance();

    // ✅ نمسح التوكن
    await prefs.remove('access_token');

    // ✅ نمسح بيانات المستخدم
    await prefs.remove('user_data');

    print('🗑️ BLoC: User data cleared successfully');
  }
}