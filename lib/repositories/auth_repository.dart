// 📄 lib/repositories/auth_repository.dart
// ============================================================
// 🔐 مستودع المصادقة - الوسيط بين الـ BLoC والـ API
// ============================================================

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

class AuthRepository {

  // 🔐 تسجيل الدخول
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    print('🔐 Attempting login for: $email');

    // ✅ نستخدم الـ ApiService الجاهز
    // ⚠️ جربي 'auth/login/' أولاً، إذا ما اشتغل جربي 'auth/trainee/login/'
    final response = await ApiService.post(
      endpoint: 'auth/login/',
      data: {
        'email': email,
        'password': password,
      },
      requireAuth: false, // تسجيل الدخول لا يحتاج توكن
    );

    print('📡 Login Response: ${response['success']} - ${response['message']}');

    if (response['success']) {
      final data = response['data'];

      // ✅ استخراج التوكن (دعم لـ 'access' أو 'token')
      final token = data['access'] ?? data['token'];
      final role = data['role'] ?? 'trainee';

      // ✅ حفظ التوكن والـ Role في التخزين المحلي
      if (token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', token);
        await prefs.setString('user_role', role);
        print('💾 Token saved successfully');
      }

      // ✅ إنشاء كائن المستخدم من البيانات
      // ملاحظة: إذا الباك إند بيرجع المستخدم داخل حقل 'user'، نستخدمه، иначе نستخدم البيانات الرئيسية
      final userData = data['user'] ?? data;
      final user = User.fromJson(userData);

      // ✅ حفظ بيانات المستخدم كاملة
      await _saveUserData(user);

      return {
        'success': true,
        'user': user,
        'token': token,
      };
    }

    // ❌ إذا فشلت العملية
    return {
      'success': false,
      'message': response['message'] ?? 'فشل تسجيل الدخول',
    };
  }

  // 📝 تسجيل مستخدم جديد
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required UserType userType,
    required String phone,
    required String location,
    required String birthDate,
  }) async {

    final response = await ApiService.post(
      endpoint: 'auth/register/',
      data: {
        'email': email,
        'username': name.toLowerCase().replaceAll(' ', '_'),
        'full_name': name,
        'birth_date': birthDate,
        'phone_number': phone,
        'location': location,
        'role': _userTypeToString(userType),
        'password': password,
      },
      requireAuth: false,
    );

    if (response['success']) {
      final data = response['data'];

      final user = User.fromJson(data['user']);

      final token = data['token'];

      if (token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', token);
      }

      await _saveUserData(user);

      return {
        'success': true,
        'user': user,
        'token': token,
      };
    }

    return {
      'success': false,
      'message': response['message'] ?? 'Registration failed',
    };
  }

  // 🚪 تسجيل الخروج
  Future<bool> logout() async {
    try {
      // محاولة إرسال طلب للخادم (اختياري)
      await ApiService.post(
        endpoint: 'auth/logout/',
        data: {},
        requireAuth: true,
      );
    } catch (e) {
      print('⚠️ Logout server request failed, clearing local data anyway');
    }

    // ✅ مسح البيانات المحلية بغض النظر عن رد السيرفر
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    await prefs.remove('user_role');
    await prefs.remove('user_data');

    return true;
  }

  // 👤 جلب بيانات المستخدم الحالي من التخزين المحلي
  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('user_data');

    if (saved != null && saved.isNotEmpty) {
      try {
        final userData = json.decode(saved);
        return User.fromJson(userData);
      } catch (e) {
        print('❌ Error parsing saved user: $e');
        return null;
      }
    }
    return null;
  }

  // 🛠️ دوال مساعدة خاصة بالكلاس

  String _userTypeToString(UserType type) {
    switch (type) {
      case UserType.trainer: return 'trainer';
      case UserType.admin: return 'admin';
      default: return 'trainee';
    }
  }

  Future<void> _saveUserData(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', json.encode(user.toJson()));
  }
}